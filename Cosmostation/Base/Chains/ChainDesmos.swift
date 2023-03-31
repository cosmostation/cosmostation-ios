//
//  ChainDesmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainDesmos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.DESMOS_MAIN
    var chainImg = UIImage(named: "chainDesmos")
    var chainInfoImg = UIImage(named: "infoDesmos")
    var chainInfoTitle = "DESMOS"
    var chainInfoMsg = NSLocalizedString("guide_msg_desmos", comment: "")
    var chainColor = UIColor(named: "desmos")!
    var chainColorBG = UIColor(named: "desmos_bg")!
    var chainTitle = "(Desmos Mainnet)"
    var chainTitle2 = "DESMOS"
    var chainDBName = CHAIN_DESMOS_S
    var chainAPIName = "desmos"
    var chainKoreanName = "데스모스"
    var chainIdPrefix = "desmos-"
    
    var stakeDenomImg = UIImage(named: "tokenDesmos")
    var stakeDenom = "udsm"
    var stakeSymbol = "DSM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "desmos")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "desmos"
    var validatorPrefix = "desmosvaloper"
    var defaultPath = "m/44'/852'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-desmos.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "desmos/"
    var priceUrl = GeckoUrl + "desmos"
    
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
        return "https://www.desmos.network/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/desmosnetwork"
    }
}
