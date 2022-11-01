//
//  ChainKi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKi: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KI_MAIN
    var chainImg = UIImage(named: "chainKi")
    var chainInfoImg = UIImage(named: "infoKi")
    var chainInfoTitle = NSLocalizedString("guide_title_ki", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_ki", comment: "")
    var chainColor = UIColor(named: "ki")!
    var chainColorBG = UIColor(named: "ki_bg")!
    var chainTitle = "(KiChain Mainnet)"
    var chainTitle2 = "KI"
    var chainDBName = CHAIN_KI_S
    var chainAPIName = "kichain"
    //TODO hardcoing for V3
//    var chainAPIName = "ki-chain"
    var chainIdPrefix = "kichain-"
    
    var stakeDenomImg = UIImage(named: "tokenKi")
    var stakeDenom = "uxki"
    var stakeSymbol = "XKI"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "ki")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "ki"
    var validatorPrefix = "kivaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.025uxki"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var grpcUrl = "lcd-ki-chain-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-ki-chain-app.cosmostation.io/"
    var apiUrl = "https://api-ki-chain.cosmostation.io/"
    var explorerUrl = MintscanUrl + "ki-chain/"
    var validatorImgUrl = MonikerUrl + "ki/"
    var priceUrl = CoingeckoUrl + "ki"
    
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
        return "https://foundation.ki/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/ki-foundation"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
