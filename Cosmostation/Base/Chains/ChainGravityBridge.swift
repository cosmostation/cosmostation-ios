//
//  ChainGravityBridge.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainGravityBridge: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.GRAVITY_BRIDGE_MAIN
    var chainImg = UIImage(named: "chainGravityBridge")
    var chainInfoImg = UIImage(named: "infoGravityBridge")
    var chainInfoTitle = NSLocalizedString("send_guide_title_gbridge", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_gbridge", comment: "")
    var chainColor = UIColor(named: "gravitybridge")!
    var chainColorBG = UIColor(named: "gravitybridge_bg")!
    var chainTitle = "(G-Bridge Mainnet)"
    var chainTitle2 = "G-BRIDGE"
    var chainDBName = CHAIN_GRAVITY_BRIDGE_S
    var chainAPIName = "gravity-bridge"
    var chainIdPrefix = "gravity-bridge-"
    
    var stakeDenomImg = UIImage(named: "tokenGravityBridge")
    var stakeDenom = "ugraviton"
    var stakeSymbol = "GRAVITON"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "gravitybridge")!
    
    var addressPrefix = "gravity"
    var validatorPrefix = "gravityvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.0ugraviton"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var grpcUrl = "lcd-gravity-bridge-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-gravity-bridge-app.cosmostation.io/"
    var apiUrl = "https://api-gravity-bridge.cosmostation.io/"
    var explorerUrl = MintscanUrl + "gravity-bridge/"
    var validatorImgUrl = MonikerUrl + "gravity-bridge/"
    var relayerImgUrl = RelayerUrl + "gravity-bridge/relay-gravitybridge-unknown.png"
    var priceUrl = CoingeckoUrl + "graviton"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://www.gravitybridge.net/"
    }

    func getInfoLink2() -> String {
        return "https://www.gravitybridge.net/blog"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
