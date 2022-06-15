//
//  ChainRegen.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainRegen: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.REGEN_MAIN
    var chainImg = UIImage(named: "chainRegen")
    var chainInfoImg = UIImage(named: "infoiconRegen")
    var chainInfoTitle = NSLocalizedString("send_guide_title_regen", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_regen", comment: "")
    var chainColor = UIColor(named: "regen")!
    var chainColorDark = UIColor(named: "regen_dark")
    var chainColorBG = UIColor(named: "regen")!.withAlphaComponent(0.15)
    var chainTitle = "(Regen Mainnet)"
    var chainTitle2 = "REGEN"
    var chainDBName = "SUPPORT_CHAIN_REGEN"
    var chainAPIName = "regen"
    
    var stakeDenomImg = UIImage(named: "tokenRegen")
    var stakeDenom = "uregen"
    var stakeSymbol = "REGEN"
    
    var addressPrefix = "regen"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-regen-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-regen-app.cosmostation.io"
    var apiUrl = "https://api-regen.cosmostation.io/"
    var explorerUrl = MintscanUrl + "regen/"
    var validatorImgUrl = MonikerUrl + "regen/"
    var relayerImgUrl = RelayerUrl + "regen/relay-regen-unknown.png"
    
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
