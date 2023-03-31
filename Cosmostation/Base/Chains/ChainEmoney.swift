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
    var chainInfoTitle = "E-MONEY"
    var chainInfoMsg = NSLocalizedString("guide_msg_emoney", comment: "")
    var chainColor = UIColor(named: "emoney")!
    var chainColorBG = UIColor(named: "emoney_bg")!
    var chainTitle = "(E-Money Mainnet)"
    var chainTitle2 = "E-MONEY"
    var chainDBName = CHAIN_EMONEY_S
    var chainAPIName = "emoney"
    var chainKoreanName = "이머니"
    var chainIdPrefix = "emoney-"
    
    var stakeDenomImg = UIImage(named: "tokenEmoney")
    var stakeDenom = "ungm"
    var stakeSymbol = "NGM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "emoney")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "emoney"
    var validatorPrefix = "emoneyvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-emoney.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "emoney/"
    var priceUrl = GeckoUrl + "e-money"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath]
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
}


let EMONEY_MAIN_DENOM = "ungm"
let EMONEY_EUR_DENOM = "eeur"
let EMONEY_CHF_DENOM = "echf"
let EMONEY_DKK_DENOM = "edkk"
let EMONEY_NOK_DENOM = "enok"
let EMONEY_SEK_DENOM = "esek"

