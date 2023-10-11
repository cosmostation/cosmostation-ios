//
//  ChainBinanceBeacon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/05.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBinanceBeacon: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "BNB Beacon"
        tag = "binanceBeacon"
        chainId = "Binance-Chain-Tigris"
        logo1 = "chainBnbBeacon"
        logo2 = "chainBnbBeacon2"
        apiName = ""
        stakeDenom = "BNB"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/714'/0'/0/X")
        accountPrefix = "bnb"
        supportStaking = false
    }
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "bnb-beacon-chain/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
    
}

let BNB_BEACON_LCD = "https://dex.binance.org/"
let BNB_BEACON_EXPLORER = "https://explorer.bnbchain.org/"
let BNB_BEACON_BASE_FEE = "0.000075"
let BNB_GECKO_ID = "binancecoin"
