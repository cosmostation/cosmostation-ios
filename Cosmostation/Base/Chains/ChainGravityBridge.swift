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
    var chainImg = UIImage(named: "chainGravitybridge")
    var chainInfoImg = UIImage(named: "infoiconGravitybridge")
    var chainInfoTitle = NSLocalizedString("send_guide_title_gbridge", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_gbridge", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenGravitybridge")
    var stakeDenom = "ugraviton"
    var stakeSymbol = "GRAVITON"
    
    var addressPrefix = "gravity"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-gravity-bridge-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-gravity-bridge-app.cosmostation.io"
    var apiUrl = "https://api-gravity-bridge.cosmostation.io/"
    var explorerUrl = MintscanUrl + "gravity-bridge/"
    var validatorImgUrl = MonikerUrl + "gravity-bridge/"
    var relayerImgUrl = RelayerUrl + "gravity-bridge/relay-gravitybridge-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
