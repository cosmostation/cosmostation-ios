//
//  ChainImuaEVM_T.swift
//  Cosmostation
//
//  Created by 차소민 on 4/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainImuaEVM_T: ChainImuaEVM {
    
    override init() {
        super.init()
        
        name = "Imua Testnet"
        tag = "imua60_T"
        chainImg = "chainImua_T"
        isTestnet = true
        apiName = "imua-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")

        
        cosmosEndPointType = .UseLCD
        stakeDenom = "hua"
        bechAccountPrefix = "im"
        validatorPrefix = "imvaloper"
        grpcHost = "grpc.testnet.imua.cosmostation.io"
        lcdUrl = "https://lcd.testnet.imua.cosmostation.io/"
        
        
        supportEvm = true
        coinSymbol = "IMUA"
        evmRpcURL = "https://rpc-office-evm.cosmostation.io/imua-testnet/"
    }
}
