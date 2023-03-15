//
//  ChainJuno.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainJuno: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.JUNO_MAIN
    var chainImg = UIImage(named: "chainJuno")
    var chainInfoImg = UIImage(named: "infoJuno")
    var chainInfoTitle = "JUNO"
    var chainInfoMsg = NSLocalizedString("guide_msg_juno", comment: "")
    var chainColor = UIColor(named: "juno")!
    var chainColorBG = UIColor(named: "juno_bg")!
    var chainTitle = "(Juno Mainnet)"
    var chainTitle2 = "JUNO"
    var chainDBName = CHAIN_JUNO_S
    var chainAPIName = "juno"
    var chainKoreanName = "주노"
    var chainIdPrefix = "juno-"
    
    var stakeDenomImg = UIImage(named: "tokenJuno")
    var stakeDenom = "ujuno"
    var stakeSymbol = "JUNO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "juno")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "juno"
    var validatorPrefix = "junovaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = true
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = true
    var grpcUrl = "grpc-juno.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-juno-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "juno/"
    var priceUrl = GeckoUrl + "juno-network"
    
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
        return "https://junochain.com/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@JunoNetwork/"
    }
}
