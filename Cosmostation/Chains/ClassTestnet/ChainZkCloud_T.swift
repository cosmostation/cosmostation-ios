//
//  ChainZkCloud_T.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZkCloud_T: ChainZkCloud {
    
    override init() {
        super.init()
        
        name = "ZkCloud Testnet"
        tag = "zkCloud118_T"
        logo1 = "chainZkCloud_T"
        isTestnet = true
        apiName = "zkcloud-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uproof"
        bechAccountPrefix = "zkcloud"
        validatorPrefix = "zkcloudvaloper"
        grpcHost = "grpc.testnet.zkcloud.com"
        lcdUrl = "https://api.testnet.zkcloud.com/"
    }
}
