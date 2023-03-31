//
//  ChainRegen.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainRegen: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.REGEN_MAIN
    var chainImg = UIImage(named: "chainRegen")
    var chainInfoImg = UIImage(named: "infoRegen")
    var chainInfoTitle = "REGEN"
    var chainInfoMsg = NSLocalizedString("guide_msg_regen", comment: "")
    var chainColor = UIColor(named: "regen")!
    var chainColorBG = UIColor(named: "regen_bg")!
    var chainTitle = "(Regen Mainnet)"
    var chainTitle2 = "REGEN"
    var chainDBName = CHAIN_REGEN_S
    var chainAPIName = "regen"
    var chainKoreanName = "리젠"
    var chainIdPrefix = "regen-"
    
    var stakeDenomImg = UIImage(named: "tokenRegen")
    var stakeDenom = "uregen"
    var stakeSymbol = "REGEN"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "regen")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "regen"
    var validatorPrefix = "regenvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-regen.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "regen/"
    var priceUrl = GeckoUrl + "regen"
    
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
        return "https://www.regen.network/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/regen-network"
    }
}
