//
//  ChainOsmosis.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOsmosis: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.OSMOSIS_MAIN
    var chainImg = UIImage(named: "chainOsmosis")
    var chainInfoImg = UIImage(named: "infoOsmosis")
    var chainInfoTitle = NSLocalizedString("send_guide_title_osmosis", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_osmosis", comment: "")
    var chainColor = UIColor(named: "osmosis")!
    var chainColorBG = UIColor(named: "osmosis_bg")!
    var chainTitle = "(Osmosis Mainnet)"
    var chainTitle2 = "OSMOSIS"
    var chainDBName = CHAIN_OSMOSIS_S
    var chainAPIName = "osmosis"
    var chainIdPrefix = "osmosis-"
    
    var stakeDenomImg = UIImage(named: "tokenOsmosis")
    var stakeDenom = "uosmo"
    var stakeSymbol = "OSMO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "osmosis")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "osmo"
    var validatorPrefix = "osmovaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.0025uosmo"
    let gasRate1 = "0.025uosmo"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = false
    var grpcUrl = "lcd-osmosis-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-osmosis-app.cosmostation.io/"
    var apiUrl = "https://api-osmosis.cosmostation.io/"
    var explorerUrl = MintscanUrl + "osmosis/"
    var validatorImgUrl = MonikerUrl + "osmosis/"
    var priceUrl = CoingeckoUrl + "osmosis"
    
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
        return "https://osmosis.zone/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/osmosis"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

let OSMOSIS_MAIN_DENOM = "uosmo"
let OSMOSIS_ION_DENOM = "uion"
