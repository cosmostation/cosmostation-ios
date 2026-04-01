//
//  ChainMantraEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainMantraEVM_T: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Mantra Testnet"
        tag = "mantraevm60_T"
        chainImg = "chainMantra_T"
        isTestnet = true
        apiName = "mantra-testnet"
        accountKeyType = AccountKeyType(.COSMOS_EVM_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uom"
        bechAccountPrefix = "mantra"
        validatorPrefix = "mantravaloper"
        grpcHost = "grpc.dukong.mantrachain.io"
        lcdUrl = "https://api.dukong.mantrachain.io/"
        
        supportEvm = true
        coinSymbol = "OM"
        evmRpcURL = "https://evm.dukong.mantrachain.io"
    }
}

