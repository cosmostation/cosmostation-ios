//
//  ChainNeutron.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNeutron: BaseChain {
    
    var neutronFetcher: NeutronFetcher?
    
    override init() {
        super.init()
        
        name = "Neutron"
        tag = "neutron118"
        logo1 = "chainNeutron"
        apiName = "neutron"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "untrn"
        bechAccountPrefix = "neutron"
        validatorPrefix = "neutronvaloper"
        supportStaking = false
        supportCw20 = true
        grpcHost = "grpc-neutron.cosmostation.io"
        
//        grpcHost = "grpc-office-neutron.cosmostation.io"
//        grpcHost = "grpc-office-neutron2.cosmostation.io"
        
    }
    
    override func getGrpcfetcher() -> NeutronFetcher? {
        if (neutronFetcher == nil) {
            neutronFetcher = NeutronFetcher.init(self)
        }
        return neutronFetcher
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let result = await getGrpcfetcher()?.fetchGrpcData(id)
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let neutronFetcher = getGrpcfetcher(), fetchState == .Success {
                neutronFetcher.onCheckVesting()
                allCoinValue = neutronFetcher.allCoinValue()
                allCoinUSDValue = neutronFetcher.allCoinValue(true)
                allTokenValue = neutronFetcher.allTokenValue()
                allTokenUSDValue = neutronFetcher.allTokenValue(true)
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.bechAddress!, self.evmAddress ?? "",
                               neutronFetcher.allStakingDenomAmount().stringValue, allCoinUSDValue.stringValue,
                               allTokenUSDValue.stringValue, neutronFetcher.cosmosBalances?.filter({ BaseData.instance.getAsset(self.apiName, $0.denom) != nil }).count))
                
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
}

let NEUTRON_VESTING_CONTRACT_ADDRESS = "neutron1h6828as2z5av0xqtlh4w9m75wxewapk8z9l2flvzc29zeyzhx6fqgp648z"
