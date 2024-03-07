//
//  ChainAltheaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAltheaEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Althea"
        tag = "althea60"
        logo1 = "chainAltheaEvm"
        logo2 = "chainAlthea2"
        apiName = "althea"
        stakeDenom = "aalthea"
        
        //for EVM tx and display
        coinSymbol = "ALTG"
        coinGeckoId = "althea"
        coinLogo = "tokenAltg"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "althea"
        validatorPrefix = "altheavaloper"
        
        grpcHost = "grpc-althea.cosmostation.io"
        evmRpcURL = "https://rpc-althea-evm.cosmostation.io"
        explorerURL = "https://www.mintscan.io/althea/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
}
