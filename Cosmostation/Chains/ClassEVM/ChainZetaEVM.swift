//
//  ChainZetaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainZetaEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "ZetaChain"
        tag = "zeta60"
        chainImg = "chainZeta_E"
        apiName = "zeta"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "azeta"
        bechAccountPrefix = "zeta"
        validatorPrefix = "zetavaloper"
        grpcHost = "grpc-zeta.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-zeta.mainnet.cosmoslabs.kr/"
    
        supportEvm = true
        coinSymbol = "ZETA"
        evmRpcURL = "https://zetachain-mainnet.g.allthatnode.com/archive/evm"
    }
}

