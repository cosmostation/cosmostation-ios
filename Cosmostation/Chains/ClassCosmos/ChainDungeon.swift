//
//  ChainDungeon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/3/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainDungeon: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Dungeon"
        tag = "dungeon"
        logo1 = "chainDungeon"
        apiName = "dungeon"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "udgn"
        bechAccountPrefix = "dungeon"
        validatorPrefix = "dungeonvaloper"
        grpcHost = "dungeon.grpc.quasarstaking.ai:80"
        lcdUrl = "https://dungeon-wallet.api.quasarstaking.ai"
    }
    
}
