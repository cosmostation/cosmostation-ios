//
//  ChainSommelier.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/05.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSommelier: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SOMMELIER_MAIN
    var chainImg = UIImage(named: "chainSommelier")
    var chainInfoImg = UIImage(named: "infoSommelier")
    var chainInfoTitle = NSLocalizedString("guide_title_sommelier", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_sommelier", comment: "")
    var chainColor = UIColor(named: "sommelier")!
    var chainColorBG = UIColor(named: "sommelier_bg")!
    var chainTitle = "(SOMMELIER Mainnet)"
    var chainTitle2 = "SOMMELIER"
    var chainDBName = CHAIN_SOMMELIER_S
    var chainAPIName = "sommelier"
    var chainIdPrefix = "sommelier-"
    
    var stakeDenomImg = UIImage(named: "tokenSommelier")
    var stakeDenom = "usomm"
    var stakeSymbol = "SOMM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "sommelier")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "somm"
    var validatorPrefix = "sommvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.0usomm"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "lcd-sommelier-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-sommelier-app.cosmostation.io/"
    var apiUrl = "https://api-sommelier.cosmostation.io/"
    var explorerUrl = MintscanUrl + "sommelier/"
    var validatorImgUrl = MonikerUrl + "sommelier/"
    var priceUrl = CoingeckoUrl + "sommelier"
    
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
        return "https://www.sommelier.finance/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@sommelierfinance"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
