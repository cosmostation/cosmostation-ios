//
//  ChainAxelar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAxelar: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.AXELAR_MAIN
    var chainImg = UIImage(named: "chainAxelar")
    var chainInfoImg = UIImage(named: "infoiconAxelar")
    var chainInfoTitle = NSLocalizedString("send_guide_title_axelar", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_axelar", comment: "")
    var chainColor = UIColor(named: "axelar")!
    var chainColorDark = UIColor(named: "axelar_dark")
    var chainColorBG = UIColor(named: "axelar")!.withAlphaComponent(0.15)
    
    var stakeDenomImg = UIImage(named: "tokenAxelar")
    var stakeDenom = "uaxl"
    var stakeSymbol = "AXL"
    
    var addressPrefix = "axelar"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-axelar-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-axelar-app.cosmostation.io"
    var apiUrl = "https://api-axelar.cosmostation.io/"
    var explorerUrl = MintscanUrl + "axelar/"
    var validatorImgUrl = MonikerUrl + "axelar/"
    var relayerImgUrl = RelayerUrl + "axelar/relay-axelar-unknown.png"
    
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
