//
//  ChainKavaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKavaEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Kava"
        tag = "kava60"
        logo1 = "chainKavaEvm"
        logo2 = "chainKava2"
        apiName = "kava"
        stakeDenom = "ukava"
        
        //for EVM tx and display
        coinSymbol = "KAVA"
        coinGeckoId = "kava"
        coinLogo = "tokenKava"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "kava"
        validatorPrefix = "kavavaloper"
        
        grpcHost = "grpc-kava.cosmostation.io"
        evmRpcURL = "https://rpc-kava-evm.cosmostation.io"
    }
    
//    override func getExplorerAccount() -> URL? {
//        if let urlString = getChainListParam()["evm_explorer"]["account"].string,
//           let url = URL(string: urlString.replacingOccurrences(of: "${address}", with: evmAddress)) {
//            return url
//        }
//        return nil
//    }
//    
//    override func getExplorerTx(_ hash: String?) -> URL? {
//        if let urlString = getChainListParam()["evm_explorer"]["tx"].string,
//           let txhash = hash,
//           let url = URL(string: urlString.replacingOccurrences(of: "${hash}", with: txhash)) {
//            return url
//        }
//        return nil
//    }
}
