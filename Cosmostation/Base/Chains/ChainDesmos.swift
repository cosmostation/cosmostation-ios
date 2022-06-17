//
//  ChainDesmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainDesmos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.DESMOS_MAIN
    var chainImg = UIImage(named: "chainDesmos")
    var chainInfoImg = UIImage(named: "infoiconDesmos")
    var chainInfoTitle = NSLocalizedString("send_guide_title_desmos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_desmos", comment: "")
    var chainColor = UIColor(named: "desmos")!
    var chainColorBG = UIColor(named: "desmos_bg")!
    var chainTitle = "(Desmos Mainnet)"
    var chainTitle2 = "DESMOS"
    var chainDBName = "SUPPORT_CHAIN_DESMOS"
    var chainAPIName = "desmos"
    
    var stakeDenomImg = UIImage(named: "tokenDesmos")
    var stakeDenom = "udsm"
    var stakeSymbol = "DSM"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "desmos")!
    
    var addressPrefix = "desmos"
    let addressHdPath0 = "m/44'/852'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-desmos-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-desmos-app.cosmostation.io"
    var apiUrl = "https://api-desmos.cosmostation.io/"
    var explorerUrl = MintscanUrl + "desmos/"
    var validatorImgUrl = MonikerUrl + "desmos/"
    var relayerImgUrl = RelayerUrl + "desmos/relay-desmos-unknown.png"
    
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
