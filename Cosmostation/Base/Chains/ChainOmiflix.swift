//
//  ChainOmiflix.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOmniflix: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.OMNIFLIX_MAIN
    var chainImg = UIImage(named: "chainOmniflix")
    var chainInfoImg = UIImage(named: "infoOmniflix")
    var chainInfoTitle = NSLocalizedString("guide_title_omniflix", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_omniflix", comment: "")
    var chainColor = UIColor(named: "omniflix")!
    var chainColorBG = UIColor(named: "omniflix_bg")!
    var chainTitle = "(Omniflix Mainnet)"
    var chainTitle2 = "OMNIFLIX"
    var chainDBName = CHAIN_OMNIFLIX_S
    var chainAPIName = "omniflix"
    var chainIdPrefix = "omniflixhub-"
    
    var stakeDenomImg = UIImage(named: "tokenOmniflix")
    var stakeDenom = "uflix"
    var stakeSymbol = "FLIX"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "omniflix")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "omniflix"
    var validatorPrefix = "omniflixvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.001uflix"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "lcd-omniflix-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-omniflix-app.cosmostation.io/"
    var apiUrl = "https://api-omniflix.cosmostation.io/"
    var explorerUrl = MintscanUrl + "omniflix/"
    var validatorImgUrl = MonikerUrl + "omniflix/"
    var priceUrl = CoingeckoUrl + "omniflix-network"
    
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
        return "https://www.omniflix.network/"
    }

    func getInfoLink2() -> String {
        return "https://blog.omniflix.network/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

