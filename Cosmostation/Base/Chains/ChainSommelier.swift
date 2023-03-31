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
    var chainInfoTitle = "SOMMELIER"
    var chainInfoMsg = NSLocalizedString("guide_msg_sommelier", comment: "")
    var chainColor = UIColor(named: "sommelier")!
    var chainColorBG = UIColor(named: "sommelier_bg")!
    var chainTitle = "(SOMMELIER Mainnet)"
    var chainTitle2 = "SOMMELIER"
    var chainDBName = CHAIN_SOMMELIER_S
    var chainAPIName = "sommelier"
    var chainKoreanName = "소믈리에"
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
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-sommelier.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "sommelier/"
    var priceUrl = GeckoUrl + "sommelier"
    
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
}
