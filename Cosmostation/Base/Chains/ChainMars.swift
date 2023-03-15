//
//  ChainMars.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/01/31.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainMars: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.MARS_MAIN
    var chainImg = UIImage(named: "chainMars")
    var chainInfoImg = UIImage(named: "infoMars")
    var chainInfoTitle = "MARS"
    var chainInfoMsg = NSLocalizedString("guide_msg_mars", comment: "")
    var chainColor = UIColor(named: "mars")!
    var chainColorBG = UIColor(named: "mars_bg")!
    var chainTitle = "(Mars Mainnet)"
    var chainTitle2 = "MARS"
    var chainDBName = CHAIN_MARS_S
    var chainAPIName = "mars-protocol"
    var chainKoreanName = "마스"
    var chainIdPrefix = "mars-"
    
    var stakeDenomImg = UIImage(named: "tokenMars")
    var stakeDenom = "umars"
    var stakeSymbol = "MARS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "mars")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "mars"
    var validatorPrefix = "marsvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-mars-protocol.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "mars-protocol/"
    var priceUrl = GeckoUrl + "mars-protocol"
    
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
        return "https://marsprotocol.io/"
    }

    func getInfoLink2() -> String {
        return "https://blog.marsprotocol.io/"
    }
}

