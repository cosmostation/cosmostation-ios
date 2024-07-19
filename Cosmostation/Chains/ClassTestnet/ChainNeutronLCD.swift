//
//  ChainNeutronLCD.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/18/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNeutronLCD: ChainNeutron {
    
    override init() {
        super.init()
        
        name = "NeutronLCD"
        tag = "neutroncdsdc"
        logo1 = "chainNeutron"
        apiName = "neutron"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = false
        supportCosmosLcd = true
        stakeDenom = "untrn"
        bechAccountPrefix = "neutron"
        validatorPrefix = "neutronvaloper"
        supportStaking = false
        supportCw20 = true
        lcdUrl = "https://lcd-neutron.cosmostation.io/"
        
    }
}
