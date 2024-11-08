//
//  ChainNeutron_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/1/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNeutron_T: ChainNeutron {
    
    override init() {
        super.init()
        
        name = "Neutron Testnet"
        tag = "neutron118_T"
        logo1 = "chainNeutron_T"
        isTestnet = true
        apiName = "neutron-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "untrn"
        bechAccountPrefix = "neutron"
        validatorPrefix = "neutronvaloper"
        supportStaking = false
        grpcHost = "grpc-office-neutron.cosmostation.io"
        lcdUrl = "https://rest-falcron.pion-1.ntrn.tech/"
        
        
    }
}
