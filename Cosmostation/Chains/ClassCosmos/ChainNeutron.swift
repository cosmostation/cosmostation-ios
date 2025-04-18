//
//  ChainNeutron.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNeutron: BaseChain {
    
    override init() {
        super.init()
        
        name = "Neutron"
        tag = "neutron118"
        logo1 = "chainNeutron"
        apiName = "neutron"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "untrn"
        bechAccountPrefix = "neutron"
        validatorPrefix = "neutronvaloper"
        supportStaking = false
        grpcHost = "grpc-neutron.cosmostation.io"
        lcdUrl = "https://lcd-neutron.cosmostation.io/"
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = NeutronFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getNeutronFetcher() -> NeutronFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = NeutronFetcher.init(self)
        }
        return cosmosFetcher as? NeutronFetcher
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
                neutronFetcher.onCheckVesting()
                
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                coinsCnt = neutronFetcher.valueCoinCnt()
                coinsValue = neutronFetcher.allCoinValue()
                coinsUSDValue = neutronFetcher.allCoinValue(true)
                mainCoinAmount = neutronFetcher.allStakingDenomAmount()
                tokensCnt = neutronFetcher.valueTokenCnt(id)
                tokensValue = neutronFetcher.allTokenValue(id)
                tokensUSDValue = neutronFetcher.allTokenValue(id, true)
                
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

let NEUTRON_VESTING_CONTRACT_ADDRESS = "neutron1h6828as2z5av0xqtlh4w9m75wxewapk8z9l2flvzc29zeyzhx6fqgp648z"
