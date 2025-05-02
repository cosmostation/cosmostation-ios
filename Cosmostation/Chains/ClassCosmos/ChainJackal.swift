//
//  ChainJackal.swift
//  Cosmostation
//
//  Created by 차소민 on 10/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainJackal: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Jackal"
        tag = "jackal118"
        chainImg = "chainJackal"
        apiName = "jackal"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ujkl"
        bechAccountPrefix = "jkl"
        validatorPrefix = "jklvaloper"
        grpcHost = "grpc.jackal.silentvalidator.com"
        lcdUrl = "https://api.jackalprotocol.com/"
    }
}
