//
//  ChainOkt60Keccak.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOkt60Keccak: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "OKT"
        chainId = "exchain-66"
        tag = "okt60_Keccak"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        apiName = ""
        stakeDenom = "okt"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        accountPrefix = "ex"
        supportStaking = false
        evmCompatible = true
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        address = KeyFac.convertEvmToBech32(evmAddress!, accountPrefix!)
        
//        print("", tag, " ", address, "  ", evmAddress)
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        address = KeyFac.convertEvmToBech32(evmAddress!, accountPrefix!)
    }
    
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "okc/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
}

let OKT_LCD = "https://exchainrpc.okex.org/okexchain/v1/"
let OKT_EXPLORER = "https://www.oklink.com/oktc/"
let OKT_BASE_FEE = "0.00005"
let OKT_GECKO_ID = "oec-token"
