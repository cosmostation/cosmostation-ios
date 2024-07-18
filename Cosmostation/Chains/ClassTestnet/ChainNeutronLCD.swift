//
//  ChainNeutronLCD.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/18/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNeutronLCD: BaseChain {
    
    override init() {
        super.init()
        
        name = "NeutronLCD"
        tag = "neutroncdsdc"
        logo1 = "chainNeutron"
        apiName = "neutron"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosLcd = true
        stakeDenom = "untrn"
        bechAccountPrefix = "neutron"
        validatorPrefix = "neutronvaloper"
        supportStaking = false
        supportCw20 = true
        lcdUrl = "https://lcd-neutron.cosmostation.io/"
        
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher != nil) { return cosmosFetcher }
        if (supportCosmosGrpc) {
            cosmosFetcher = NeutronGrpcFetcher(self)
        } else if (supportCosmosLcd) {
            cosmosFetcher = NeutronLcdFetcher(self)
        }
        return cosmosFetcher
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
            
            if let neutronFetcher = getCosmosfetcher(), fetchState == .Success {
                neutronFetcher.onCheckCosmosVesting()
                
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                coinsCnt = neutronFetcher.valueCoinCnt()
                coinsValue = neutronFetcher.allCoinValue()
                coinsUSDValue = neutronFetcher.allCoinValue(true)
                mainCoinAmount = neutronFetcher.allStakingDenomAmount()
                tokensCnt = neutronFetcher.valueTokenCnt()
                tokensValue = neutronFetcher.allTokenValue()
                tokensUSDValue = neutronFetcher.allTokenValue(true)
                
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
