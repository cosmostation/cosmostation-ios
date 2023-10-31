//
//  ChainCelestia.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/31/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCelestia: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CELESTIA_MAIN
    var chainImg = UIImage(named: "chainCelestia")
    var chainInfoImg = UIImage(named: "infoCelestia")
    var chainInfoTitle = "CELESTIA"
    var chainInfoMsg = NSLocalizedString("guide_msg_celestia", comment: "")
    var chainColor = UIColor(named: "celestia")!
    var chainColorBG = UIColor(named: "celestia_bg")!
    var chainTitle = "(Celestia Mainnet)"
    var chainTitle2 = "CELESTIA"
    var chainDBName = CHAIN_CELESTIA_S
    var chainAPIName = "celestia"
    var chainKoreanName = "셀레스티아"
    var chainIdPrefix = "celestia"
    
    var stakeDenomImg = UIImage(named: "tokenCelestia")
    var stakeDenom = "utia"
    var stakeSymbol = "TIA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "celestia")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "celestia"
    var validatorPrefix = "celestiavaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-celestia.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "celestia/"
    var priceUrl = ""
    
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
        return "https://celestia.org/"
    }

    func getInfoLink2() -> String {
        return "https://blog.celestia.org/"
    }
}

