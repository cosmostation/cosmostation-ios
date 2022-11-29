//
//  ChainComdex.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainComdex: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.COMDEX_MAIN
    var chainImg = UIImage(named: "chainComdex")
    var chainInfoImg = UIImage(named: "infoComdex")
    var chainInfoTitle = NSLocalizedString("guide_title_comdex", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_comdex", comment: "")
    var chainColor = UIColor(named: "comdex")!
    var chainColorBG = UIColor(named: "comdex_bg")!
    var chainTitle = "(Comdex Mainnet)"
    var chainTitle2 = "COMDEX"
    var chainDBName = CHAIN_COMDEX_S
    var chainAPIName = "comdex"
    var chainIdPrefix = "comdex-"
    
    var stakeDenomImg = UIImage(named: "tokenComdex")
    var stakeDenom = "ucmdx"
    var stakeSymbol = "CMDX"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "comdex")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "comdex"
    var validatorPrefix = "comdexvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-comdex.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-comdex-app.cosmostation.io/"
    var apiUrl = "https://api-comdex.cosmostation.io/"
    var explorerUrl = MintscanUrl + "comdex/"
    var validatorImgUrl = MonikerUrl + "comdex/"
    var priceUrl = CoingeckoUrl + "comdex"
    
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
        return "https://comdex.one/"
    }

    func getInfoLink2() -> String {
        return "https://blog.comdex.one/"
    }
}
