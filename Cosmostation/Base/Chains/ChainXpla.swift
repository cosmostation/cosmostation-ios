//
//  ChainXpla.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/31.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainXpla: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.XPLA_MAIN
    var chainImg = UIImage(named: "chainXpla")
    var chainInfoImg = UIImage(named: "infoXpla")
    var chainInfoTitle = NSLocalizedString("guide_title_xpla", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_xpla", comment: "")
    var chainColor = UIColor(named: "xpla")!
    var chainColorBG = UIColor(named: "xpla_bg")!
    var chainTitle = "(XPLA Mainnet)"
    var chainTitle2 = "XPLA"
    var chainDBName = CHAIN_XPLA_S
    var chainAPIName = "xpla"
    var chainIdPrefix = "dimension_"
    
    var stakeDenomImg = UIImage(named: "tokenXpla")
    var stakeDenom = "axpla"
    var stakeSymbol = "XPLA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "xpla")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "xpla"
    var validatorPrefix = "xplavaloper"
    let addressHdPath0 = "m/44'/60'/0'/0/X"
    
    let gasRate0 = "850000000000axpla"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-xpla-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-xpla-app.cosmostation.io/"
    var apiUrl = "https://api-xpla.cosmostation.io/"
    var explorerUrl = MintscanUrl + "xpla/"
    var validatorImgUrl = MonikerUrl + "xpla/"
    var priceUrl = CoingeckoUrl + "xpla"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://xpla.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@XPLA_Official"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
