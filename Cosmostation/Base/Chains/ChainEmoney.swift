//
//  ChainEmoney.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainEmoney: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.EMONEY_MAIN
    var chainImg = UIImage(named: "chainEmoney")
    var chainInfoImg = UIImage(named: "infoiconEmoney")
    var chainInfoTitle = NSLocalizedString("send_guide_title_emoney", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_emoney", comment: "")
    var chainColor = UIColor(named: "emoney")!
    var chainColorDark = UIColor(named: "emoney_dark")
    var chainColorBG = UIColor(named: "emoney")!.withAlphaComponent(0.15)
    var chainTitle = "(E-Money Mainnet)"
    var chainTitle2 = "E-MONEY"
    var chainDBName = "SUPPORT_CHAIN_EMONEY"
    var chainAPIName = "emoney"
    
    var stakeDenomImg = UIImage(named: "tokenEmoney")
    var stakeDenom = "ungm"
    var stakeSymbol = "NGM"
    
    var addressPrefix = "emoney"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-emoney-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-emoney-app.cosmostation.io"
    var apiUrl = "https://api-emoney.cosmostation.io/"
    var explorerUrl = MintscanUrl + "emoney/"
    var validatorImgUrl = MonikerUrl + "emoney/"
    var relayerImgUrl = RelayerUrl + "emoney/relay-emoney-unknown.png"
    
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
