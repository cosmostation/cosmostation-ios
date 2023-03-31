//
//  ChainCoreum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCoreum: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.COREUM_MAIN
    var chainImg = UIImage(named: "chainCoreum")
    var chainInfoImg = UIImage(named: "infoCoreum")
    var chainInfoTitle = "COREUM"
    var chainInfoMsg = NSLocalizedString("guide_msg_coreum", comment: "")
    var chainColor = UIColor(named: "coreum")!
    var chainColorBG = UIColor(named: "coreum_bg")!
    var chainTitle = "(Coreum Mainnet)"
    var chainTitle2 = "Coreum"
    var chainDBName = CHAIN_COREUM_S
    var chainAPIName = "coreum"
    var chainKoreanName = "코리움"
    var chainIdPrefix = "coreum-mainnet"
    
    
    var stakeDenomImg = UIImage(named: "tokenCoreum")
    var stakeDenom = "ucore"
    var stakeSymbol = "CORE"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "coreum")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "core"
    var validatorPrefix = "corevaloper"
    var defaultPath = "m/44'/990'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-coreum.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-coreum-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "coreum/"
    var priceUrl = GeckoUrl + "coreum"
    
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
        return "https://www.coreum.com/"
    }

    func getInfoLink2() -> String {
        return "https://www.coreum.com/community#press-&-media"
    }
}
