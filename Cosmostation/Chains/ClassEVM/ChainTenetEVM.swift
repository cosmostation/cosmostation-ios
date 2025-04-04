//
//  ChainTenetEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainTenetEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Tenet"
        tag = "tenet60"
        logo1 = "chainTenet"
        apiName = "tenet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "atenet"
        bechAccountPrefix = "tenet"
        validatorPrefix = "tenetvaloper"
        grpcHost = "tenet-grpc.publicnode.com:443"
        lcdUrl = "https://app.rpc.tenet.org/"
        
        supportEvm = true
        coinSymbol = "TENET"
        evmRpcURL = "https://eth-dataseed.aioz.network"
    }
}
