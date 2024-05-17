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

let BERA_CONT_BANK = "0x4381dC2aB14285160c808659aEe005D51255adD7"
let BERA_CONT_STAKING = "0xd9A998CaC66092748FfEc7cFBD155Aae1737C2fF"
let BERA_CONT_GOVERNANCE = "0x7b5Fe22B5446f7C62Ea27B8BD71CeF94e03f3dF2"
let BERA_CONT_DISTRIBUTION = "0x0000000000000000000000000000000000000069"

