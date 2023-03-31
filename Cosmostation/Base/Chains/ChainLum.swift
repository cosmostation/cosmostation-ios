//
//  ChainLum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainLum: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.LUM_MAIN
    var chainImg = UIImage(named: "chainLum")
    var chainInfoImg = UIImage(named: "infoLum")
    var chainInfoTitle = "LUM"
    var chainInfoMsg = NSLocalizedString("guide_msg_lum", comment: "")
    var chainColor = UIColor(named: "lum")!
    var chainColorBG = UIColor(named: "lum_bg")!
    var chainTitle = "(Lum Mainnet)"
    var chainTitle2 = "LUM"
    var chainDBName = CHAIN_LUM_S
    var chainAPIName = "lum"
    var chainKoreanName = "룸"
    var chainIdPrefix = "lum-"
    
    var stakeDenomImg = UIImage(named: "tokenLum")
    var stakeDenom = "ulum"
    var stakeSymbol = "LUM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "lum")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "lum"
    var validatorPrefix = "lumvaloper"
    let addressHdPath = "m/44'/118'/0'/0/X"
    var defaultPath = "m/44'/880'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-lum.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "lum/"
    var priceUrl = GeckoUrl + "lum-network"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath, defaultPath]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://lum.network/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/lum-network"
    }
}
