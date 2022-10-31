//
//  ChainTgrade.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/08.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainTgrade: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.TGRADE_MAIN
    var chainImg = UIImage(named: "chainTgrade")
    var chainInfoImg = UIImage(named: "infoTgrade")
    var chainInfoTitle = NSLocalizedString("guide_title_tgrade", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_tgrade", comment: "")
    var chainColor = UIColor(named: "tgrade")!
    var chainColorBG = UIColor(named: "tgrade_bg")!
    var chainTitle = "(Tgrade Mainnet)"
    var chainTitle2 = "TGRADE"
    var chainDBName = CHAIN_TGRADE_S
    var chainAPIName = "tgrade"
    var chainIdPrefix = "tgrade-"
    
    
    var stakeDenomImg = UIImage(named: "tokenTgrade")
    var stakeDenom = "utgd"
    var stakeSymbol = "TGD"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "tgrade")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "tgrade"
    var validatorPrefix = "tgrade"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.05utgd"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-tgrade-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-tgrade-app.cosmostation.io/"
    var apiUrl = "https://api-tgrade.cosmostation.io/"
    var explorerUrl = MintscanUrl + "tgrade/"
    var validatorImgUrl = MonikerUrl + "tgrade/"
    var priceUrl = CoingeckoUrl + "tgrade"
    
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
        return "https://tgrade.finance/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@k-martin-worner"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

