//
//  CosmosEvmClass.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/16/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Alamofire
import SwiftyJSON
import web3swift
import BigInt

/*
class CosmosEvmClass: CosmosClass {
    
//    var supportErc20 = false
    
    lazy var rpcURL = ""
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
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    //fetch account onchaindata from grpc
    override func fetchData(_ id: Int64) async {
        if let rawParam = try? await self.fetchChainParam(),
           let erc20s = try? await self.fetchErc20Info() {
            mintscanChainParam = rawParam
            mintscanErc20Tokens = erc20s
        }
        fetchGrpcData(id)
        fetchAllErc20Balance(id)
    }
    
    func getWeb3Connection() -> web3? {
        guard let url = URL(string: rpcURL) else { return  nil }
        if (self.web3 == nil || self.web3?.provider.session == nil) {
            return try? Web3.new(url)
        }
        return web3
    }
    
    deinit {
        web3 = nil
    }
}

extension CosmosEvmClass {
    
    func fetchErc20Info() async throws -> [MintscanToken] {
//        print("fetchErc20Info ", BaseNetWork.msErc20InfoUrl(self))
        return try await AF.request(BaseNetWork.msErc20InfoUrl(self), method: .get).serializingDecodable([MintscanToken].self).value
    }
    
    func fetchAllErc20Balance(_ id: Int64) {
        let group = DispatchGroup()
        mintscanErc20Tokens.forEach { token in
            fetchErc20Balance(group, getWeb3Connection(), EthereumAddress.init(evmAddress)!, token)
        }
        
        group.notify(queue: .main) {
            self.allTokenValue = self.allTokenValue()
            self.allTokenUSDValue = self.allTokenValue(true)
            
            BaseData.instance.updateRefAddressesToken(
                RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                           nil, nil, self.allTokenUSDValue.stringValue, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchTokens"), object: nil, userInfo: nil)
        }
    }
    
    func fetchErc20Balance(_ group: DispatchGroup, _ web3: web3?, _ accountEthAddr: EthereumAddress, _ tokenInfo: MintscanToken) {
        group.enter()
        DispatchQueue.global().async {
            let contractAddress = EthereumAddress.init(tokenInfo.address!)
            let erc20token = ERC20(web3: web3!, provider: web3!.provider, address: contractAddress!)
            if let erc20Balance = try? erc20token.getBalance(account: accountEthAddr) {
                tokenInfo.setAmount(String(erc20Balance))
                group.leave()
            } else {
                group.leave()
            }
        }
    }
}
*/
