//
//  ChainMovement.swift
//  Cosmostation
//
//  Created by 권혁준 on 1/12/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainMovement: ChainAptos  {
    
    override init() {
        super.init()
        
        name = "Movement"
        tag = "movementMainnet"
        chainImg = "chainMovement"
        apiName = "movement"
        
        coinSymbol = "MOVE"
        
        apiUrl = "https://mainnet.movementnetwork.xyz/v1/"
        mainUrl = "https://indexer.mainnet.movementnetwork.xyz/v1/graphql"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
}
