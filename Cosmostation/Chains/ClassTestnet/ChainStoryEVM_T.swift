//
//  ChainStory_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/19/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainStoryEVM_T: ChainStoryEVM  {
    
    override init() {
        super.init()
        
        name = "Story Testnet"
        tag = "story_T"
        isTestnet = true
        apiName = "story-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "IP"
        evmRpcURL = "https://rpc-office-evm.cosmostation.io/story-testnet/"
        
//        bechAccountPrefix = "story"
//        validatorPrefix = "storyvaloper"
//        mainUrl = "https://lcd-office.cosmostation.io/story-testnet"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
}
