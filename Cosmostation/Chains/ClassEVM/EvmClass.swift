//
//  evmClass.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import web3swift

class EvmClass: BaseChain  {
    
    var coinGeckoId = ""
    var evmAddress = ""
    
    lazy var rpcURL = ""
    var Web3Networks: Networks?
    var evmBalances = NSDecimalNumber.zero
    
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
        guard let url = URL(string: rpcURL) else { return }
        guard let web3 = try? Web3.new(url) else { return }
        
        Web3Networks = web3.provider.network
        if let balance = try? web3.eth.getBalance(address: EthereumAddress.init(evmAddress)!) {
            evmBalances = NSDecimalNumber(string: balance.description)
        }
        DispatchQueue.main.async {
            self.fetched = true
            self.allCoinValue = self.allCoinValue()
            self.allCoinUSDValue = self.allCoinValue(true)
            
            BaseData.instance.updateRefAddressesMain(
                RefAddress(id, self.tag, "", self.evmAddress,
                           self.evmBalances.stringValue, self.allCoinUSDValue.stringValue, nil, 1))
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
        }
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(coinGeckoId, usd)
        return evmBalances.multiplying(by: msPrice).multiplying(byPowerOf10: -18, withBehavior: handler6)
    }
}


func ALLEVMCLASS() -> [EvmClass] {
    var result = [EvmClass]()
    result.append(ChainEthereum())
    result.append(ChainKava_EVM())
    
    return result
}

let DEFUAL_DISPALY_EVM = ["ethereum60"]

