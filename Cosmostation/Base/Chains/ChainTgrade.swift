//
//  ChainTgrade.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/08.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainTgrade: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.TGRADE_MAIN
    var chainImg = UIImage(named: "chainTgrade")
    var chainInfoImg = UIImage(named: "infoTgrade")
    var chainInfoTitle = "TGRADE"
    var chainInfoMsg = NSLocalizedString("guide_msg_tgrade", comment: "")
    var chainColor = UIColor(named: "tgrade")!
    var chainColorBG = UIColor(named: "tgrade_bg")!
    var chainTitle = "(Tgrade Mainnet)"
    var chainTitle2 = "TGRADE"
    var chainDBName = CHAIN_TGRADE_S
    var chainAPIName = "tgrade"
    var chainKoreanName = "티그레이드"
    var chainIdPrefix = "tgrade-"
    
    
    var stakeDenomImg = UIImage(named: "tokenTgrade")
    var stakeDenom = "utgd"
    var stakeSymbol = "TGD"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "tgrade")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "tgrade"
    var validatorPrefix = "tgrade"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-tgrade.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-tgrade-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "tgrade/"
    var priceUrl = GeckoUrl + "tgrade"
    
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
        return "https://tgrade.finance/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@k-martin-worner"
    }
}

