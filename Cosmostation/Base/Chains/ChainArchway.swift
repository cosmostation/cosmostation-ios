//
//  ChainArchway.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/07/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainArchway: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.ARCHWAY_MAIN
    var chainImg = UIImage(named: "chainArchway")
    var chainInfoImg = UIImage(named: "infoArchway")
    var chainInfoTitle = "ARCHWAY"
    var chainInfoMsg = NSLocalizedString("guide_msg_archway", comment: "")
    var chainColor = UIColor(named: "archway")!
    var chainColorBG = UIColor(named: "archway_bg")!
    var chainTitle = "(Archway Mainnet)"
    var chainTitle2 = "ARCHWAY"
    var chainDBName = CHAIN_ARCHWAY_S
    var chainAPIName = "archway"
    var chainKoreanName = "아치웨이"
    var chainIdPrefix = "archway-"
    
    var stakeDenomImg = UIImage(named: "tokenArchway")
    var stakeDenom = "aarch"
    var stakeSymbol = "ARCH"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "archway")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "archway"
    var validatorPrefix = "archwayvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-archway.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "archway/"
    var priceUrl = GeckoUrl + "archway"
    
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
        return "https://archway.io/"
    }

    func getInfoLink2() -> String {
        return "https://blog.archway.io/"
    }
}
