//
//  ChainCoreum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCoreum: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Coreum"
        tag = "coreum990"
        chainImg = "chainCoreum"
        apiName = "coreum"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/990'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ucore"
        bechAccountPrefix = "core"
        validatorPrefix = "corevaloper"
        grpcHost = "grpc-coreum.cosmostation.io"  
        lcdUrl = "https://lcd-coreum.cosmostation.io/"
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = CoreumFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getCoreumFetcher() -> CoreumFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = CoreumFetcher.init(self)
        }
        return cosmosFetcher as? CoreumFetcher
    }
    
    
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        if (accountKeyType.pubkeyType == .COSMOS_Secp256k1) {
            bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
            
        } else {
            evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
            if (supportCosmos) {
                bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAccountPrefix!)
            }
        }
        
        bechAddress = "core1xkv90l09g3mmu3tt5ts2jydkh8t47ud35cuat4"
        
        if (supportCosmos && isStakeEnabled()) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress!, validatorPrefix)
        }
    }
    
}
