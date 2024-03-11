//
//  evmClass.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import web3swift
import Alamofire
import BigInt

class EvmClass: CosmosClass {
    
    var supportCosmos = false
    
    var coinSymbol = ""
    var coinGeckoId = ""
    var coinLogo = ""
    
    lazy var evmRpcURL = ""
    lazy var explorerURL = ""
    lazy var addressURL = ""
    lazy var txURL = ""
    
    var web3: web3?
    var evmBalances = NSDecimalNumber.zero
    
    lazy var mintscanErc20Tokens = [MintscanToken]()
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        if (supportCosmos) {
            bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
        }
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        if (supportCosmos) {
            bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
        }
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    override func fetchData(_ id: Int64) {
        let group = DispatchGroup()
        fetchChainParam2(group)
        fetchErc20Info2(group)
        fetchEvmBalance(group)
        
        if (supportCosmos) {
            let channel = getConnection()
            cosmosAuth = nil
            cosmosBalances = nil
            cosmosVestings.removeAll()
            cosmosDelegations.removeAll()
            cosmosUnbondings.removeAll()
            cosmosRewards.removeAll()
            cosmosCommissions.removeAll()
            fetchAuth(group, channel)
            fetchBalance(group, channel)
            
            group.notify(queue: .main) {
                try? channel.close()
                WUtils.onParseVestingAccount(self)
                self.fetched = true
                self.allCoinValue = self.allCoinValue()
                self.allCoinUSDValue = self.allCoinValue(true)
                self.fetchAllErc20Balance(id)
                
                BaseData.instance.updateRefAddressesCoinValue(
                    RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                               self.allStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                               nil, self.cosmosBalances?.filter({ BaseData.instance.getAsset(self.apiName, $0.denom) != nil }).count))
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            }
            
        } else {
            group.notify(queue: .main) {
                self.fetched = true
                self.allCoinValue = self.allCoinValue()
                self.allCoinUSDValue = self.allCoinValue(true)
                self.fetchAllErc20Balance(id)
                
                BaseData.instance.updateRefAddressesCoinValue(
                    RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                               self.evmBalances.stringValue, self.allCoinUSDValue.stringValue,
                               nil, (self.evmBalances != NSDecimalNumber.zero ? 1 : 0) ))
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            }
        }
    }
    
    //fetch only balance for add account check
    override func fetchPreCreate() {
        //Do not using Task, only DispatchQueue : make slow
        DispatchQueue.global().async {
            if let balance = try? self.getWeb3Connection()?.eth.getBalance(address: EthereumAddress.init(self.evmAddress)!) {
                self.evmBalances = NSDecimalNumber(string: String(balance ?? "0"))
            }
            DispatchQueue.main.async(execute: {
                self.fetched = true
                NotificationCenter.default.post(name: Notification.Name("FetchPreCreate"), object: self.tag, userInfo: nil)
            });
        }
    }
    
    //check account payable with lowest fee
    override func isTxFeePayable() -> Bool {
        if (supportCosmos) {
            return super.isTxFeePayable()
        }
        return evmBalances.compare(EVM_BASE_FEE).rawValue > 0
    }
    
    func getWeb3Connection() -> web3? {
        if (self.web3 != nil && self.web3?.provider.session != nil) {
            return web3
        } else {
            guard let url = URL(string: getEvmRpc()) else { return  nil }
            self.web3 = try? Web3.new(url)
            return web3
        }
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if (supportCosmos) {
            return super.allCoinValue(usd)
        } else {
            let msPrice = BaseData.instance.getPrice(coinGeckoId, usd)
            return evmBalances.multiplying(by: msPrice).multiplying(byPowerOf10: -18, withBehavior: handler6)
        }
    }
    
    override func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let tokenInfo = mintscanErc20Tokens.filter({ $0.address == address }).first {
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    override func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        mintscanErc20Tokens.forEach { tokenInfo in
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
            result = result.adding(value)
        }
        return result
    }
    
    deinit {
        web3 = nil
    }
    
    func getEvmRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_EVM_RPC_ENDPOINT +  " : " + self.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return evmRpcURL
    }
}

extension EvmClass {
    
    func fetchErc20Info() async throws -> [MintscanToken] {
//        print("fetchErc20Info ", BaseNetWork.msErc20InfoUrl(self))
        return try await AF.request(BaseNetWork.msErc20InfoUrl(self), method: .get).serializingDecodable([MintscanToken].self).value
    }
    
    func fetchErc20Info2(_ group: DispatchGroup) {
//        print("fetchErc20Info2 ", BaseNetWork.msErc20InfoUrl(self))
        group.enter()
        AF.request(BaseNetWork.msErc20InfoUrl(self), method: .get)
            .responseDecodable(of: [MintscanToken].self) { response in
                switch response.result {
                case .success(let value):
                    self.mintscanErc20Tokens = value
                case .failure:
                    print("fetchErc20Info2 error")
                }
                group.leave()
            }
    }
    
    func fetchEvmBalance(_ group: DispatchGroup) {
        DispatchQueue(label: "evmBalance", attributes: .concurrent).async(group: group) {
            if let balance = try? self.getWeb3Connection()?.eth.getBalance(address: EthereumAddress.init(self.evmAddress)!) {
                self.evmBalances = NSDecimalNumber(string: String(balance ?? "0"))
            }
        }
    }
}

extension EvmClass {
    func fetchAllErc20Balance(_ id: Int64) {
        let group = DispatchGroup()
        let userDisplaytoken = BaseData.instance.getDisplayErc20s(id, tag)
        mintscanErc20Tokens.forEach { token in
            if (supportCosmos) {
                fetchErc20Balance(group, EthereumAddress.init(evmAddress)!, token)
                
            } else {
                if (userDisplaytoken == nil) {
                    if (token.isdefault == true) {
                        fetchErc20Balance(group, EthereumAddress.init(evmAddress)!, token)
                    }
                } else {
                    if (userDisplaytoken?.contains(token.address!) == true) {
                        fetchErc20Balance(group, EthereumAddress.init(evmAddress)!, token)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.allTokenValue = self.allTokenValue()
            self.allTokenUSDValue = self.allTokenValue(true)
            
            BaseData.instance.updateRefAddressesTokenValue(
                RefAddress(id, self.tag, "", self.evmAddress,
                           nil, nil, self.allTokenUSDValue.stringValue, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchTokens"), object: self.tag, userInfo: nil)
        }
    }
    
    func fetchErc20Balance(_ group: DispatchGroup, _ accountEthAddr: EthereumAddress, _ tokenInfo: MintscanToken) {
        group.enter()
        DispatchQueue.global().async {
            let contractAddress = EthereumAddress.init(tokenInfo.address!)
            if let connection = self.getWeb3Connection() {
                let erc20token = ERC20(web3: connection, provider: connection.provider, address: contractAddress!)
                if let erc20Balance = try? erc20token.getBalance(account: accountEthAddr) {
                    tokenInfo.setAmount(String(erc20Balance))
                }
            }
            group.leave()
        }
    }
}


func ALLEVMCLASS() -> [EvmClass] {
    var result = [EvmClass]()
    result.append(ChainEthereum())
//    result.append(ChainAltheaEVM())
    result.append(ChainCantoEVM())
    result.append(ChainDymensionEVM())
    result.append(ChainEvmosEVM())
    result.append(ChainHumansEVM())
    result.append(ChainKavaEVM())
    result.append(ChainOktEVM())
    result.append(ChainOptimism())
    result.append(ChainPolygon())
    result.append(ChainXplaEVM())
    
    //Add cosmos chain id for ibc
    result.forEach { chain in
        if let chainId = BaseData.instance.mintscanChains?["chains"].arrayValue.filter({ $0["chain"].stringValue == chain.apiName }).first?["chain_id"].stringValue {
            chain.chainId = chainId
        }
    }
    return result
}

let DEFUAL_DISPALY_EVM = ["ethereum60", "dymension60", "kava60"]

let EVM_BASE_FEE = NSDecimalNumber.init(string: "588000000000000")
