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
        id = "binanceBeacon"
        logo1 = "chainBnbBeacon"
        logo2 = "chainBnbBeacon2"
        apiName = ""
        stakeDenom = "BNB"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/714'/0'/0/X")
        accountPrefix = "bnb"
    }
    
    static let lcdUrl = "https://dex.binance.org/"
    static let explorer = "https://explorer.bnbchain.org/"
    static let BNB_GECKO_ID = "binancecoin"
    
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "bnb-beacon-chain/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
    
}
