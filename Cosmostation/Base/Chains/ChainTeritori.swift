//
//  ChainTeritori.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainTeritori: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.TERITORI_MAIN
    var chainImg = UIImage(named: "chainTeritori")
    var chainInfoImg = UIImage(named: "infoTerotori")
    var chainInfoTitle = NSLocalizedString("guide_title_teritori", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_teritori", comment: "")
    var chainColor = UIColor(named: "teritori")!
    var chainColorBG = UIColor(named: "teritori_bg")!
    var chainTitle = "(Teritori Mainnet)"
    var chainTitle2 = "TERITORI"
    var chainDBName = CHAIN_TERITORI_S
    var chainAPIName = "teritori"
    var chainIdPrefix = "teritori-"
    
    var stakeDenomImg = UIImage(named: "tokenTeritori")
    var stakeDenom = "utori"
    var stakeSymbol = "TORI"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "teritori")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "tori"
    var validatorPrefix = "torivaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0utori"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-teritori-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-teritori-app.cosmostation.io/"
    var apiUrl = "https://api-teritori.cosmostation.io/"
    var explorerUrl = MintscanUrl + "teritori/"
    var validatorImgUrl = MonikerUrl + "teritori/"
    var priceUrl = CoingeckoUrl + "teritori"
    
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
        return "https://teritori.com/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/teritori"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

