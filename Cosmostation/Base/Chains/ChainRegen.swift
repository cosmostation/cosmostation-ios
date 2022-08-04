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
    var chainInfoImg = UIImage(named: "infoRegen")
    var chainInfoTitle = NSLocalizedString("send_guide_title_regen", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_regen", comment: "")
    var chainColor = UIColor(named: "regen")!
    var chainColorBG = UIColor(named: "regen_bg")!
    var chainTitle = "(Regen Mainnet)"
    var chainTitle2 = "REGEN"
    var chainDBName = CHAIN_REGEN_S
    var chainAPIName = "regen"
    var chainIdPrefix = "regen-"
    
    var stakeDenomImg = UIImage(named: "tokenRegen")
    var stakeDenom = "uregen"
    var stakeSymbol = "REGEN"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "regen")!
    
    var addressPrefix = "regen"
    var validatorPrefix = "regenvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.00025uregen"
    let gasRate1 = "0.0025uregen"
    let gasRate2 = "0.025uregen"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-regen-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-regen-app.cosmostation.io/"
    var apiUrl = "https://api-regen.cosmostation.io/"
    var explorerUrl = MintscanUrl + "regen/"
    var validatorImgUrl = MonikerUrl + "regen/"
    var relayerImgUrl = RelayerUrl + "regen/relay-regen-unknown.png"
    var priceUrl = CoingeckoUrl + "regen"
    
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
        return "https://www.regen.network/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/regen-network"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
