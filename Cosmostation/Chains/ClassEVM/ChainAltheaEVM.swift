//
//  ChainAltheaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAltheaEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Althea"
        tag = "althea60"
        chainImg = "chainAlthea_E"
        apiName = "althea"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "aalthea"
        bechAccountPrefix = "althea"
        validatorPrefix = "altheavaloper"
        grpcHost = "grpc-althea.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-althea.mainnet.cosmoslabs.kr/"
        
        supportEvm = true
        coinSymbol = "ALTHEA"
        evmRpcURL = "https://rpc.althea.zone"
    }
}
