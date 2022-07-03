//
//  ChainKi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKi: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KI_MAIN
    var chainImg = UIImage(named: "chainKi")
    var chainInfoImg = UIImage(named: "infoKi")
    var chainInfoTitle = NSLocalizedString("send_guide_title_ki", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_ki", comment: "")
    var chainColor = UIColor(named: "ki")!
    var chainColorBG = UIColor(named: "ki_bg")!
    var chainTitle = "(KiChain Mainnet)"
    var chainTitle2 = "KI"
    var chainDBName = CHAIN_KI_S
    var chainAPIName = "kichain"
    
    var stakeDenomImg = UIImage(named: "tokenKi")
    var stakeDenom = "uxki"
    var stakeSymbol = "XKI"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "ki")!
    
    var addressPrefix = "ki"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.025uxki"
    
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-kichain-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-kichain-app.cosmostation.io/"
    var apiUrl = "https://api-kichain.cosmostation.io/"
    var explorerUrl = MintscanUrl + "ki-chain/"
    var validatorImgUrl = MonikerUrl + "ki/"
    var relayerImgUrl = RelayerUrl + "ki/relay-kichain-unknown.png"
    var priceUrl = CoingeckoUrl + "ki"
    
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
        return "https://foundation.ki/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/ki-foundation"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
