//
//  ChainSentinel.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSentinel: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SENTINEL_MAIN
    var chainImg = UIImage(named: "chainSentinel")
    var chainInfoImg = UIImage(named: "infoSentinel")
    var chainInfoTitle = "SENTINEL"
    var chainInfoMsg = NSLocalizedString("guide_msg_sentinel", comment: "")
    var chainColor = UIColor(named: "sentinel")!
    var chainColorBG = UIColor(named: "sentinel_bg")!
    var chainTitle = "(Sentinel Mainnet)"
    var chainTitle2 = "SENTINEL"
    var chainDBName = CHAIN_SENTINEL_S
    var chainAPIName = "sentinel"
    var chainKoreanName = "센티넬"
    var chainIdPrefix = "sentinelhub-"
    
    var stakeDenomImg = UIImage(named: "tokenSentinel")
    var stakeDenom = "udvpn"
    var stakeSymbol = "DVPN"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "sentinel")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "sent"
    var validatorPrefix = "sentvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-sentinel.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "sentinel/"
    var priceUrl = GeckoUrl + "sentinel"
    
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
        return "https://sentinel.co/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/sentinel"
    }
}
