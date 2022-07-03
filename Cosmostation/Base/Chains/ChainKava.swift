//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKava: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KAVA_MAIN
    var chainImg = UIImage(named: "chainKava")
    var chainInfoImg = UIImage(named: "infoKava")
    var chainInfoTitle = NSLocalizedString("send_guide_title_kava", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_kava", comment: "")
    var chainColor = UIColor(named: "kava")!
    var chainColorBG = UIColor(named: "kava_bg")!
    var chainTitle = "(Kava Mainnet)"
    var chainTitle2 = "KAVA"
    var chainDBName = CHAIN_KAVA_S
    var chainAPIName = "kava"
    
    var stakeDenomImg = UIImage(named: "tokenKava")
    var stakeDenom = "ukava"
    var stakeSymbol = "KAVA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "kava")!
    
    var addressPrefix = "kava"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    var addressaddressHdPath1 = "m/44'/459'/0'/0/X"
    
    let gasRate0 = "0.001ukava"
    let gasRate1 = "0.0025ukava"
    let gasRate2 = "0.025ukava"
    
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-kava-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-kava-app.cosmostation.io/"
    var apiUrl = "https://api-kava.cosmostation.io/"
    var explorerUrl = MintscanUrl + "kava/"
    var validatorImgUrl = MonikerUrl + "kava/"
    var relayerImgUrl = RelayerUrl + "kava/relay-kava-unknown.png"
    var priceUrl = CoingeckoUrl + "kava"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressaddressHdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://www.kava.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/kava-labs"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}


let KAVA_MAIN_DENOM = "ukava"
let KAVA_HARD_DENOM = "hard"
let KAVA_USDX_DENOM = "usdx"
let KAVA_SWAP_DENOM = "swp"
