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
        
        initFetcher()
    }
    
    override func initFetcher() {
        neutronFetcher = NeutronFetcher.init(self)
    }
    
    override func getGrpcfetcher() -> FetcherGrpc? {
        return neutronFetcher
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let result = await neutronFetcher?.fetchGrpcData(id)
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let neutronFetcher = neutronFetcher, fetchState == .Success {
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

//Neutron Contract Address
let NEUTRON_VAULT_ADDRESS = "neutron1qeyjez6a9dwlghf9d6cy44fxmsajztw257586akk6xn6k88x0gus5djz4e"
let NEUTRON_VESTING_CONTRACT_ADDRESS = "neutron1h6828as2z5av0xqtlh4w9m75wxewapk8z9l2flvzc29zeyzhx6fqgp648z"
