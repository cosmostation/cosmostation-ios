//
//  ChainBeraEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/8/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBeraEVM_T: ChainBeraEVM {
    
    override init() {
        super.init()
        
        name = "Bera Testnet"
        tag = "bera60_T"
        chainImg = "chainBera_T"
        isTestnet = true
        apiName = "berachain-testnet"
        accountKeyType = AccountKeyType(.BERA_Secp256k1, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = "abgt"
        bechAccountPrefix = "bera"
        validatorPrefix = "beravaloper"
        grpcHost = ""
        lcdUrl = ""
        
        
        supportEvm = true
        coinSymbol = "BERA"
        evmRpcURL = "https://bartio.rpc.berachain.com/"
    }
}

//let BERA_CONT_BANK = "0x4381dC2aB14285160c808659aEe005D51255adD7"
//let BERA_CONT_STAKING = "0xd9A998CaC66092748FfEc7cFBD155Aae1737C2fF"
//let BERA_CONT_GOVERNANCE = "0x7b5Fe22B5446f7C62Ea27B8BD71CeF94e03f3dF2"
//let BERA_CONT_DISTRIBUTION = "0x0000000000000000000000000000000000000069"

