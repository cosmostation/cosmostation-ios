//
//  ChainHumans.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/09/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainHumans: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.HUMANS_MAIN
    var chainImg = UIImage(named: "chainHumans")
    var chainInfoImg = UIImage(named: "infoHumans")
    var chainInfoTitle = "HUMANS.AI"
    var chainInfoMsg = NSLocalizedString("guide_msg_humans", comment: "")
    var chainColor = UIColor(named: "humans")!
    var chainColorBG = UIColor(named: "humans_bg")!
    var chainTitle = "(Humans Mainnet)"
    var chainTitle2 = "HUMANS.AI"
    var chainDBName = CHAIN_HUMANS_S
    var chainAPIName = "humans"
    var chainKoreanName = "휴먼스"
    var chainIdPrefix = "humans_"
    
    var stakeDenomImg = UIImage(named: "tokenHumans")
    var stakeDenom = "aheart"
    var stakeSymbol = "HEART"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "humans")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "human"
    var validatorPrefix = "humanvaloper"
    var defaultPath = "m/44'/60'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = true
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-humans.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "humans/"
    var priceUrl = GeckoUrl + "humans-ai"
    
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
        return "https://humans.ai/"
    }

    func getInfoLink2() -> String {
        return "https://blog.humans.ai/"
    }
}

