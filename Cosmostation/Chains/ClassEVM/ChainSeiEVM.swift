//
//  ChainSeiEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/5/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSeiEVM: ChainSei {
    
    override init() {
        super.init()
        
        name = "Sei"
        tag = "sei60"
        chainImg = "chainSei_E"
        isDefault = true
        apiName = "sei"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "usei"
        bechAccountPrefix = "sei"
        validatorPrefix = "seivaloper"
        grpcHost = "grpc-sei.cosmostation.io"
        lcdUrl = "https://lcd-sei.cosmostation.io/"
        
        supportEvm = true
        coinSymbol = "SEI"
        evmRpcURL = "https://evm-rpc.sei-apis.com"
    }
    
    //2025.08.05 SEI make address with custom style
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        bechAddress = KeyFac.getAddressFromPubKey(publicKey!, .COSMOS_Secp256k1, bechAccountPrefix)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, .ETH_Keccak256, nil)
        bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress!, validatorPrefix)
    }
}
