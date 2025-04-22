//
//  ChainOkt996Keccak.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChainOkt996Keccak: ChainOktEVM  {
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt996_Keccak"
        isDefault = false
        apiName = "okc"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/996'/0'/0/X")
        isOtherChainImage = true
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "okt"
        bechAccountPrefix = "ex"
        supportStaking = false
        lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
        
        supportEvm = false
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAccountPrefix!)
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let result = await getOktfetcher()?.fetchCosmosData(id)
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let oktFetcher = getOktfetcher(), fetchState == .Success {
                
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                coinsCnt = oktFetcher.valueCoinCnt()
                coinsValue = oktFetcher.allCoinValue()
                coinsUSDValue = oktFetcher.allCoinValue(true)
                mainCoinAmount = oktFetcher.oktAllStakingDenomAmount()
                
                allCoinValue = coinsValue
                allCoinUSDValue = coinsUSDValue
                allTokenValue = tokensValue
                allTokenUSDValue = tokensUSDValue
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.bechAddress ?? "", self.evmAddress ?? "",
                               mainCoinAmount.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
                
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
        
    }
    
    
}
