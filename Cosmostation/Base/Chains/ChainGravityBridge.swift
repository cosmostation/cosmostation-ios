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
    var chainInfoTitle = "G-BRIDGE"
    var chainInfoMsg = NSLocalizedString("guide_msg_gbridge", comment: "")
    var chainColor = UIColor(named: "gravitybridge")!
    var chainColorBG = UIColor(named: "gravitybridge_bg")!
    var chainTitle = "(G-Bridge Mainnet)"
    var chainTitle2 = "G-BRIDGE"
    var chainDBName = CHAIN_GRAVITY_BRIDGE_S
    var chainAPIName = "gravity-bridge"
    var chainKoreanName = "그래비티브릿지"
    var chainIdPrefix = "gravity-bridge-"
    
    var stakeDenomImg = UIImage(named: "tokenGravityBridge")
    var stakeDenom = "ugraviton"
    var stakeSymbol = "GRAVITON"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "gravitybridge")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "gravity"
    var validatorPrefix = "gravityvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-gravity-bridge.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "gravity-bridge/"
    var priceUrl = GeckoUrl + "graviton"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath]
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
}
