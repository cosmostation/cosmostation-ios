//
//  ChainSentinel.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSentinel: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SENTINEL_MAIN
    var chainImg = UIImage(named: "chainSentinel")
    var chainInfoImg = UIImage(named: "infoSentinel")
    var chainInfoTitle = NSLocalizedString("guide_title_sentinel", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_sentinel", comment: "")
    var chainColor = UIColor(named: "sentinel")!
    var chainColorBG = UIColor(named: "sentinel_bg")!
    var chainTitle = "(Sentinel Mainnet)"
    var chainTitle2 = "SENTINEL"
    var chainDBName = CHAIN_SENTINEL_S
    var chainAPIName = "sentinel"
    var chainIdPrefix = "sentinelhub-"
    
    var stakeDenomImg = UIImage(named: "tokenSentinel")
    var stakeDenom = "udvpn"
    var stakeSymbol = "DVPN"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "sentinel")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "sent"
    var validatorPrefix = "sentvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.01udvpn"
    let gasRate1 = "0.1udvpn"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "lcd-sentinel-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-sentinel-app.cosmostation.io/"
    var apiUrl = "https://api-sentinel.cosmostation.io/"
    var explorerUrl = MintscanUrl + "sentinel/"
    var validatorImgUrl = MonikerUrl + "sentinel/"
    var priceUrl = CoingeckoUrl + "sentinel"
    
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
        return "https://sentinel.co/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/sentinel"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
