//
//  ChainInitia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainInitia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Initia"
        tag = "initia"
        logo1 = "chainInitia"
        apiName = "initia"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uinit"
        bechAccountPrefix = "init"
        validatorPrefix = "initvaloper"
        grpcHost = ""
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = InitiaFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getInitiaFetcher() -> InitiaFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = InitiaFetcher.init(self)
        }
        return cosmosFetcher as? InitiaFetcher
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            tokensCnt = 0
            
            let result = await getCosmosfetcher()?.fetchCosmosData(id)
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let initiaFetcher = getCosmosfetcher(), fetchState == .Success {
                initiaFetcher.onCheckVesting()
                
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                coinsCnt = initiaFetcher.valueCoinCnt()
                coinsValue = initiaFetcher.allCoinValue()
                coinsUSDValue = initiaFetcher.allCoinValue(true)
                mainCoinAmount = initiaFetcher.allStakingDenomAmount()
                tokensCnt = initiaFetcher.valueTokenCnt()
                tokensValue = initiaFetcher.allTokenValue()
                tokensUSDValue = initiaFetcher.allTokenValue(true)
                
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
