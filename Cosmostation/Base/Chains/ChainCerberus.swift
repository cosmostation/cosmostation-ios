//
//  ChainCerberus.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCerberus: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CERBERUS_MAIN
    var chainImg = UIImage(named: "chainCerberus")
    var chainInfoImg = UIImage(named: "infoCerberus")
    var chainInfoTitle = "CERBERUS"
    var chainInfoMsg = NSLocalizedString("guide_msg_cerberus", comment: "")
    var chainColor = UIColor(named: "cerberus")!
    var chainColorBG = UIColor(named: "cerberus_bg")!
    var chainTitle = "(Cerberus Mainnet)"
    var chainTitle2 = "CERBERUS"
    var chainDBName = CHAIN_CERBERUS_S
    var chainAPIName = "cerberus"
    var chainKoreanName = "케르베로스"
    var chainIdPrefix = "cerberus-"
    
    var stakeDenomImg = UIImage(named: "tokenCerberus")
    var stakeDenom = "ucrbrus"
    var stakeSymbol = "CRBRUS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cerberus")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "cerberus"
    var validatorPrefix = "cerberusvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-cerberus.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "cerberus/"
    var priceUrl = GeckoUrl + "cerberus"
    
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
        return "https://cerberus.zone/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@cerberus_zone"
    }
}
