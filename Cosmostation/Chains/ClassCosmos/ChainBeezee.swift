//
//  ChainBeezee.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBeezee: BaseChain  {
    
    override init() {
        super.init()
        
        name = "BeeZee"
        tag = "beezee118"
        chainImg = "chainBeezee"
        apiName = "beezee"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubze"
        bechAccountPrefix = "bze"
        validatorPrefix = "bzevaloper"
        grpcHost = "grpc.getbze.com:9099"
        lcdUrl = "https://rest.getbze.com/"
    }
    
}
