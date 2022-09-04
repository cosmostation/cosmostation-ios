//
//  ChainPersistence.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainPersistence: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.PERSIS_MAIN
    var chainImg = UIImage(named: "chainPersistence")
    var chainInfoImg = UIImage(named: "infoPersistence")
    var chainInfoTitle = NSLocalizedString("send_guide_title_persis", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_persis", comment: "")
    var chainColor = UIColor(named: "persistence")!
    var chainColorBG = UIColor(named: "persistence_bg")!
    var chainTitle = "(Persistence Mainnet)"
    var chainTitle2 = "PERSISTENCE"
    var chainDBName = CHAIN_PERSIS_S
    var chainAPIName = "persistence"
    var chainIdPrefix = "core-"
    
    var stakeDenomImg = UIImage(named: "tokenPersistence")
    var stakeDenom = "uxprt"
    var stakeSymbol = "XPRT"
    var stakeSendImg = UIImage(named: "btnSendPersistence")!
    var stakeSendBg = UIColor.init(hexString: "171718")
    
    var addressPrefix = "persistence"
    var validatorPrefix = "persistencevaloper"
    let addressHdPath0 = "m/44'/750'/0'/0/X"
    
    let gasRate0 = "0.0uxprt"
    let gasRate1 = "0.025uxprt"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-persistence-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-persistence-app.cosmostation.io/"
    var apiUrl = "https://api-persistence.cosmostation.io/"
    var explorerUrl = MintscanUrl + "persistence/"
    var validatorImgUrl = MonikerUrl + "persistence/"
    var relayerImgUrl = RelayerUrl + "persistence/relay-persistence-unknown.png"
    var priceUrl = CoingeckoUrl + "persistence"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://persistence.one/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/persistence-blog"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
