//
//  ChainOnomy.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/29.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOnomy: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.ONOMY_MAIN
    var chainImg = UIImage(named: "chainOnomy")
    var chainInfoImg = UIImage(named: "infoOnomy")
    var chainInfoTitle = "ONOMY"
    var chainInfoMsg = NSLocalizedString("guide_msg_onomy", comment: "")
    var chainColor = UIColor(named: "onomy")!
    var chainColorBG = UIColor(named: "onomy_bg")!
    var chainTitle = "(Onomy Mainnet)"
    var chainTitle2 = "ONOMY"
    var chainDBName = CHAIN_ONOMY_S
    var chainAPIName = "onomy-protocol"
    var chainKoreanName = "오노미"
    var chainIdPrefix = "onomy-"
    
    var stakeDenomImg = UIImage(named: "tokenOnomy")
    var stakeDenom = "anom"
    var stakeSymbol = "NOM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "onomy")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "onomy"
    var validatorPrefix = "onomyvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-onomy-protocol.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-onomy-protocol-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "onomy-protocol/"
    var priceUrl = GeckoUrl + "onomy-protocol"
    
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
        return "https://onomy.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/onomy-protocol"
    }
}
