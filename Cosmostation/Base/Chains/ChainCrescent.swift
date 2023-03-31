//
//  ChainCrescent.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCrescent: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CRESCENT_MAIN
    var chainImg = UIImage(named: "chainCrescent")
    var chainInfoImg = UIImage(named: "infoCrescent")
    var chainInfoTitle = "CRESCENT"
    var chainInfoMsg = NSLocalizedString("guide_msg_crescent", comment: "")
    var chainColor = UIColor(named: "crescent")!
    var chainColorBG = UIColor(named: "crescent_bg")!
    var chainTitle = "(Crescent Mainnet)"
    var chainTitle2 = "CRESCENT"
    var chainDBName = CHAIN_CRESENT_S
    var chainAPIName = "crescent"
    var chainKoreanName = "크레센트"
    var chainIdPrefix = "crescent-"
    
    var stakeDenomImg = UIImage(named: "tokenCrescent")
    var stakeDenom = "ucre"
    var stakeSymbol = "CRE"
    var stakeSendImg = UIImage(named: "btnSendCrescent")!
    var stakeSendBg = UIColor.init(hexString: "452318")
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "cre"
    var validatorPrefix = "crevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-crescent.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "crescent/"
    var priceUrl = GeckoUrl + "crescent-network"
    
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
        return "https://crescent.network/"
    }

    func getInfoLink2() -> String {
        return "https://crescentnetwork.medium.com/"
    }
}

let CRESCENT_BCRE_DENOM = "ubcre"
