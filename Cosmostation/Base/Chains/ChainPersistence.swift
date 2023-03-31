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
    var chainInfoTitle = "PERSISTENCE"
    var chainInfoMsg = NSLocalizedString("guide_msg_persis", comment: "")
    var chainColor = UIColor(named: "persistence")!
    var chainColorBG = UIColor(named: "persistence_bg")!
    var chainTitle = "(Persistence Mainnet)"
    var chainTitle2 = "PERSISTENCE"
    var chainDBName = CHAIN_PERSIS_S
    var chainAPIName = "persistence"
    var chainKoreanName = "퍼시스턴스"
    var chainIdPrefix = "core-"
    
    var stakeDenomImg = UIImage(named: "tokenPersistence")
    var stakeDenom = "uxprt"
    var stakeSymbol = "XPRT"
    var stakeSendImg = UIImage(named: "btnSendPersistence")!
    var stakeSendBg = UIColor.init(hexString: "171718")
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "persistence"
    var validatorPrefix = "persistencevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    let addressHdPath1 = "m/44'/750'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-persistence.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "persistence/"
    var priceUrl = GeckoUrl + "persistence"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath, addressHdPath1]
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
}
