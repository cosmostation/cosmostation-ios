//
//  ChainRizon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainRizon: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.RIZON_MAIN
    var chainImg = UIImage(named: "chainRizon")
    var chainInfoImg = UIImage(named: "infoRizon")
    var chainInfoTitle = NSLocalizedString("send_guide_title_rizon", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_rizon", comment: "")
    var chainColor = UIColor(named: "rizon")!
    var chainColorBG = UIColor(named: "rizon_bg")!
    var chainTitle = "(Rizon Mainnet)"
    var chainTitle2 = "RIZON"
    var chainDBName = CHAIN_RIZON_S
    var chainAPIName = "rizon"
    var chainIdPrefix = "titan-"
    
    var stakeDenomImg = UIImage(named: "tokenRizon")
    var stakeDenom = "uatolo"
    var stakeSymbol = "ATOLO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "rizon")!
    
    var addressPrefix = "rizon"
    var validatorPrefix = "rizonvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.00025uatolo"
    let gasRate1 = "0.0025uatolo"
    let gasRate2 = "0.025uatolo"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-rizon-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-rizon-app.cosmostation.io/"
    var apiUrl = "https://api-rizon.cosmostation.io/"
    var explorerUrl = MintscanUrl + "rizon/"
    var validatorImgUrl = MonikerUrl + "rizon/"
    var priceUrl = CoingeckoUrl + "rizon"
    
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
        return "https://rizon.world/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@hdac-rizon"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
