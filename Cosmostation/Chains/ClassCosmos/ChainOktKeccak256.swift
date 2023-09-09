//
//  ChainOktKeccak256.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOktKeccak256: CosmosClass  {
    
    override init() {
        super.init()
        
        isDefault = false
        name = "OKT"
        id = "oktKeccak256"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        apiName = ""
        stakeDenom = "okt"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/996'/0'/0/X")
        accountPrefix = "ex"
    }
    
    static let lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
    static let explorer = "https://www.oklink.com/oktc/"
    static let OKT_GECKO_ID = "oec-token"
    
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "okc/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        let evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        address = KeyFac.convertEvmToBech32(evmAddress, accountPrefix!)
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        let evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        address = KeyFac.convertEvmToBech32(evmAddress, accountPrefix!)
    }
    
}
