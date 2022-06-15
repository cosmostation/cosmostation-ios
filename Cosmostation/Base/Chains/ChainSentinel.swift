//
//  ChainSentinel.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSentinel: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SENTINEL_MAIN
    var chainImg = UIImage(named: "chainsentinel")
    var chainInfoImg = UIImage(named: "sentinelImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_sentinel", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_sentinel", comment: "")
    var chainColor = UIColor(named: "sentinel")!
    var chainColorDark = UIColor(named: "sentinel_dark")
    var chainColorBG = UIColor(named: "sentinel")!.withAlphaComponent(0.15)
    
    var stakeDenomImg = UIImage(named: "tokensentinel")
    var stakeDenom = "udvpn"
    var stakeSymbol = "DVPN"
    
    var addressPrefix = "sent"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-sentinel-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-sentinel-app.cosmostation.io"
    var apiUrl = "https://api-sentinel.cosmostation.io/"
    var explorerUrl = MintscanUrl + "sentinel/"
    var validatorImgUrl = MonikerUrl + "sentinel/"
    var relayerImgUrl = RelayerUrl + "sentinel/relay-sentinel-unknown.png"
    
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
