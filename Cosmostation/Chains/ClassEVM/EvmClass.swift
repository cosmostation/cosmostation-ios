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

class EvmClass: BaseChain  {
    
    var coinSymbol = ""
    var coinGeckoId = ""
    var coinLogo = ""
    var evmAddress = ""
    
    lazy var rpcURL = ""
    var web3: web3?
    var evmBalances = NSDecimalNumber.zero
    
    lazy var mintscanErc20Tokens = [MintscanToken]()
    
    //get bech style info from seed
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    //get bech style info from privatekey
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    //fetch account onchaindata from web3 info
    override func fetchData(_ id: Int64) {
        Task {
            if let erc20s = try? await self.fetchErc20Info(),
                let balance = try? await fetchBalance() {
                mintscanErc20Tokens = erc20s
//                print("mintscanErc20Tokens ", mintscanErc20Tokens.count)
                
                evmBalances = NSDecimalNumber(string: balance.description)
//                print("evmBalances ", evmBalances)
            }
            
            DispatchQueue.main.async {
                self.fetched = true
                self.allCoinValue = self.allCoinValue()
                self.allCoinUSDValue = self.allCoinValue(true)
                
                BaseData.instance.updateRefAddressesMain(
                    RefAddress(id, self.tag, "", self.evmAddress,
                               self.evmBalances.stringValue, self.allCoinUSDValue.stringValue, nil, 1))
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                
                self.fetchAllErc20Balance(id)
            }
        }
    }
    
    func getWeb3Connection() -> web3? {
        guard let url = URL(string: rpcURL) else { return  nil }
        if (self.web3 == nil || self.web3?.provider.session == nil) {
            return try? Web3.new(url)
        }
        return web3
    }
    
    func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let tokenInfo = mintscanErc20Tokens.filter({ $0.address == address }).first {
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        mintscanErc20Tokens.forEach { tokenInfo in
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
            result = result.adding(value)
        }
        return result
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(coinGeckoId, usd)
        return evmBalances.multiplying(by: msPrice).multiplying(byPowerOf10: -18, withBehavior: handler6)
    }
    
    deinit {
        web3 = nil
    }
}

extension EvmClass {
    
    func fetchErc20Info() async throws -> [MintscanToken] {
        print("fetchErc20Info ", BaseNetWork.msErc20InfoUrl(self))
        return try await AF.request(BaseNetWork.msErc20InfoUrl(self), method: .get).serializingDecodable([MintscanToken].self).value
    }
    
    func fetchBalance() async throws -> NSDecimalNumber {
        if let balance = try? getWeb3Connection()?.eth.getBalance(address: EthereumAddress.init(evmAddress)!) {
            return NSDecimalNumber(string: balance?.description)
        }
        return NSDecimalNumber.zero
    }
}

extension EvmClass {
    func fetchAllErc20Balance(_ id: Int64) {
        let group = DispatchGroup()
        mintscanErc20Tokens.forEach { token in
            if (token.isdefault == true) {
                fetchErc20Balance(group, EthereumAddress.init(evmAddress)!, token)
            }
        }
        
        group.notify(queue: .main) {
            self.allTokenValue = self.allTokenValue()
            self.allTokenUSDValue = self.allTokenValue(true)
            
            BaseData.instance.updateRefAddressesToken(
                RefAddress(id, self.tag, "", self.evmAddress,
                           nil, nil, self.allTokenUSDValue.stringValue, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchTokens"), object: nil, userInfo: nil)
        }
    }
    
    func fetchErc20Balance(_ group: DispatchGroup, _ accountEthAddr: EthereumAddress, _ tokenInfo: MintscanToken) {
        group.enter()
        DispatchQueue.global().async {
            let contractAddress = EthereumAddress.init(tokenInfo.address!)
            let erc20token = ERC20(web3: self.getWeb3Connection()!, provider: self.getWeb3Connection()!.provider, address: contractAddress!)
            if let erc20Balance = try? erc20token.getBalance(account: accountEthAddr) {
                tokenInfo.setAmount(String(erc20Balance))
//                print("erc20Balance ", tokenInfo.symbol, "  ", erc20Balance)
                group.leave()
            } else {
                group.leave()
            }
        }
    }
}


func ALLEVMCLASS() -> [EvmClass] {
    var result = [EvmClass]()
    result.append(ChainEthereum())
    result.append(ChainKava_EVM())
    
    return result
}

let DEFUAL_DISPALY_EVM = ["ethereum60"]

