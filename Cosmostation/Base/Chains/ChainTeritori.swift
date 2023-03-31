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
    var chainInfoTitle = "TERITORI"
    var chainInfoMsg = NSLocalizedString("guide_msg_teritori", comment: "")
    var chainColor = UIColor(named: "teritori")!
    var chainColorBG = UIColor(named: "teritori_bg")!
    var chainTitle = "(Teritori Mainnet)"
    var chainTitle2 = "TERITORI"
    var chainDBName = CHAIN_TERITORI_S
    var chainAPIName = "teritori"
    var chainKoreanName = "테리토리"
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
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-teritori.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "teritori/"
    var priceUrl = GeckoUrl + "teritori"
    
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
        return "https://teritori.com/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/teritori"
    }
}

