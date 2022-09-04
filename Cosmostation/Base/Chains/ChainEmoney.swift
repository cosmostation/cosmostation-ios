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
    var chainInfoImg = UIImage(named: "infoEmoney")
    var chainInfoTitle = NSLocalizedString("send_guide_title_emoney", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_emoney", comment: "")
    var chainColor = UIColor(named: "emoney")!
    var chainColorBG = UIColor(named: "emoney_bg")!
    var chainTitle = "(E-Money Mainnet)"
    var chainTitle2 = "E-MONEY"
    var chainDBName = CHAIN_EMONEY_S
    var chainAPIName = "emoney"
    var chainIdPrefix = "emoney-"
    
    var stakeDenomImg = UIImage(named: "tokenEmoney")
    var stakeDenom = "ungm"
    var stakeSymbol = "NGM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "emoney")!
    
    var addressPrefix = "emoney"
    var validatorPrefix = "emoneyvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.1ungm"
    let gasRate1 = "0.3ungm"
    let gasRate2 = "1ungm"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-emoney-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-emoney-app.cosmostation.io/"
    var apiUrl = "https://api-emoney.cosmostation.io/"
    var explorerUrl = MintscanUrl + "emoney/"
    var validatorImgUrl = MonikerUrl + "emoney/"
    var relayerImgUrl = RelayerUrl + "emoney/relay-emoney-unknown.png"
    var priceUrl = CoingeckoUrl + "e-money"
    
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
        return "https://e-money.com/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/e-money-com"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}


let EMONEY_MAIN_DENOM = "ungm"
let EMONEY_EUR_DENOM = "eeur"
let EMONEY_CHF_DENOM = "echf"
let EMONEY_DKK_DENOM = "edkk"
let EMONEY_NOK_DENOM = "enok"
let EMONEY_SEK_DENOM = "esek"

let EMONEY_COIN_IMG_URL = ResourceBase + "coin_image/emoney/";
