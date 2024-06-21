//
//  ChainKavaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKavaEVM: BaseChain  {
    
    var kavaFetcher: KavaFetcher?
    
    override init() {
        super.init()
        
        name = "Kava"
        tag = "kava60"
        logo1 = "chainKavaEVM"
        apiName = "kava"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "ukava"
        bechAccountPrefix = "kava"
        validatorPrefix = "kavavaloper"
        grpcHost = "grpc-kava.cosmostation.io"
        
        
        supportEvm = true
        coinSymbol = "KAVA"
        coinGeckoId = "kava"
        coinLogo = "tokenKava"
        evmRpcURL = "https://rpc-kava-evm.cosmostation.io"
        
        initFetcher()
    }
    
    override func initFetcher() {
        evmFetcher = FetcherEvmrpc.init(self)
        kavaFetcher = KavaFetcher.init(self)
    }
    
    override func getGrpcfetcher() -> FetcherGrpc? {
        return kavaFetcher
    }
    
//    override func getExplorerAccount() -> URL? {
//        if let urlString = getChainListParam()["evm_explorer"]["account"].string,
//           let url = URL(string: urlString.replacingOccurrences(of: "${address}", with: evmAddress!)) {
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

let KAVA_MAIN_DENOM = "ukava"
let KAVA_HARD_DENOM = "hard"
let KAVA_USDX_DENOM = "usdx"
let KAVA_SWAP_DENOM = "swp"

let KAVA_CDP_IMG_URL        = ResourceBase + "kava/module/mint/";
let KAVA_HARD_POOL_IMG_URL  = ResourceBase + "kava/module/lend/";
