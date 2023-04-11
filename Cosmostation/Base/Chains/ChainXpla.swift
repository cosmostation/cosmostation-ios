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
    var chainInfoTitle = "XPLA"
    var chainInfoMsg = NSLocalizedString("guide_msg_xpla", comment: "")
    var chainColor = UIColor(named: "xpla")!
    var chainColorBG = UIColor(named: "xpla_bg")!
    var chainTitle = "(XPLA Mainnet)"
    var chainTitle2 = "XPLA"
    var chainDBName = CHAIN_XPLA_S
    var chainAPIName = "xpla"
    var chainKoreanName = "엑스플라"
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
    var defaultPath = "m/44'/60'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-xpla.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "xpla/"
    var priceUrl = GeckoUrl + "xpla"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath, defaultPath]
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
}
