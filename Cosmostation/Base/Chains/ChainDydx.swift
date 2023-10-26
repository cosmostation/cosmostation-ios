//
//  ChainDydx.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/26/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainDydx: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.DYDX_MAIN
    var chainImg = UIImage(named: "chainDydx")
    var chainInfoImg = UIImage(named: "infoDydx")
    var chainInfoTitle = "DYDX"
    var chainInfoMsg = NSLocalizedString("guide_msg_dydx", comment: "")
    var chainColor = UIColor(named: "dydx")!
    var chainColorBG = UIColor(named: "dydx_bg")!
    var chainTitle = "(dYdX Mainnet)"
    var chainTitle2 = "DYDX"
    var chainDBName = CHAIN_DYDX_S
    var chainAPIName = "dydx"
    var chainKoreanName = "디와이디엑스"
    var chainIdPrefix = "dydx-mainnet-"
    
    var stakeDenomImg = UIImage(named: "tokenDydx")
    var stakeDenom = "adydx"
    var stakeSymbol = "DYDX"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "dydx")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "dydx"
    var validatorPrefix = "dydxvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-dydx.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "dydx/"
    var priceUrl = GeckoUrl + "dydx"
    
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
        return "https://dydx.exchange/"
    }

    func getInfoLink2() -> String {
        return "https://dydx.exchange/blog/"
    }
}
