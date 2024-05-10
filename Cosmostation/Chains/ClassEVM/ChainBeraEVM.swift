//
//  ChainBeraEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/8/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBeraEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Bera"
        tag = "bera60-test"
        logo1 = "chainBera"
        logo2 = "chainBera2"
        apiName = "berachain-testnet"
        stakeDenom = "abgt"
        
        //for EVM tx and display
        coinSymbol = "BERA"
        coinGeckoId = ""
        coinLogo = "tokenBera"

        accountKeyType = AccountKeyType(.BERA_Secp256k1, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "bera"
        validatorPrefix = "beravaloper"
        
        grpcHost = "grpc-office-berachain.cosmostation.io"
        evmRpcURL = "https://rpc-office-evm.cosmostation.io/berachain-testnet/"
    }
}
