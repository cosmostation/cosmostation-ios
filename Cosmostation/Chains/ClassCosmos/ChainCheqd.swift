//
//  ChainCheqd.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCheqd: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Cheqd"
        tag = "cheqd118"
        logo1 = "chainCheqd"
        apiName = "cheqd"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ncheq"
        bechAccountPrefix = "cheqd"
        validatorPrefix = "cheqdvaloper"
        grpcHost = "grpc.cheqd.net:443"
        lcdUrl = "https://api.cheqd.net/"
    }
    
}
