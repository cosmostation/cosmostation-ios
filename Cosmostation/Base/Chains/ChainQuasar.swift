//
//  ChainQuasar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainQuasar: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.QUASAR_MAIN
    var chainImg = UIImage(named: "chainQuasar")
    var chainInfoImg = UIImage(named: "infoQuasar")
    var chainInfoTitle = "QUASAR"
    var chainInfoMsg = NSLocalizedString("guide_msg_quasar", comment: "")
    var chainColor = UIColor(named: "quasar")!
    var chainColorBG = UIColor(named: "quasar_bg")!
    var chainTitle = "(Quasar Mainnet)"
    var chainTitle2 = "QUASAR"
    var chainDBName = CHAIN_QUASAR_S
    var chainAPIName = "quasar"
    var chainKoreanName = "퀘이사"
    var chainIdPrefix = "quasar-"
    
    var stakeDenomImg = UIImage(named: "tokenQuasar")
    var stakeDenom = "uqsr"
    var stakeSymbol = "QSR"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "quasar")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "quasar"
    var validatorPrefix = "quasarvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-quasar.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "quasar/"
    var priceUrl = GeckoUrl + "quasar"
    
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
        return "https://www.quasar.fi/"
    }

    func getInfoLink2() -> String {
        return "https://www.quasar.fi/blog"
    }
    
}
