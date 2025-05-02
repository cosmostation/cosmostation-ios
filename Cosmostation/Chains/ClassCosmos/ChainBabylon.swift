//
//  ChainBabylon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/8/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBabylon: BaseChain {
    var babylonBtcFetcher: BabylonBTCFetcher?
    var babylonFetcher: BabylonFetcher?
    
    override init() {
        super.init()
        
        name = "Babylon"
        tag = "babylon118"
        chainImg = "chainBabylon"
        apiName = "babylon"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ubbn"
        bechAccountPrefix = "bbn"
        validatorPrefix = "bbnvaloper"
        grpcHost = "grpc.mainnet.babylon.cosmostation.io"
        lcdUrl = "https://lcd.mainnet.babylon.cosmostation.io"
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy

        Task {
            coinsCnt = 0
            tokensCnt = 0
            let cosmosResult = await getCosmosfetcher()?.fetchCosmosData(id)
            let btcStakingDataResult = await getBabylonBtcFetcher()?.fetchBtcStakingData()
            
            if (cosmosResult == false || btcStakingDataResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }

            if let cosmosFetcher = getCosmosfetcher(), fetchState == .Success {
                cosmosFetcher.onCheckVesting()
            }

            if (self.fetchState == .Success) {
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                if let cosmosFetcher = getCosmosfetcher() {
                    coinsCnt = cosmosFetcher.valueCoinCnt()
                    coinsValue = cosmosFetcher.allCoinValue()
                    coinsUSDValue = cosmosFetcher.allCoinValue(true)
                    mainCoinAmount = cosmosFetcher.allStakingDenomAmount()
                    tokensCnt = cosmosFetcher.valueTokenCnt(id)
                    tokensValue = cosmosFetcher.allTokenValue(id)
                    tokensUSDValue = cosmosFetcher.allTokenValue(id, true)
                }
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
    
    func getBabylonBtcFetcher() -> BabylonBTCFetcher? {
        if (babylonBtcFetcher != nil) { return babylonBtcFetcher }
        babylonBtcFetcher = BabylonBTCFetcher(self)
        
        return babylonBtcFetcher
    }
    
    func getBabylonFetcher() -> BabylonFetcher? {
        if (babylonFetcher != nil) { return babylonFetcher }
        babylonFetcher = BabylonFetcher(self)
        
        return babylonFetcher
    }
}

