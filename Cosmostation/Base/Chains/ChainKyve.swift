//
//  ChainKyve.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/03/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKyve: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KYVE_MAIN
    var chainImg = UIImage(named: "chainKyve")
    var chainInfoImg = UIImage(named: "infoKyve")
    var chainInfoTitle = "KYVE"
    var chainInfoMsg = NSLocalizedString("guide_msg_kyve", comment: "")
    var chainColor = UIColor(named: "kyve")!
    var chainColorBG = UIColor(named: "kyve_bg")!
    var chainTitle = "(KYVE Mainnet)"
    var chainTitle2 = "KYVE"
    var chainDBName = CHAIN_KYVE_S
    var chainAPIName = "kyve"
    var chainKoreanName = "카이브"
    var chainIdPrefix = "kyve-"
    
    var stakeDenomImg = UIImage(named: "tokenKyve")
    var stakeDenom = "ukyve"
    var stakeSymbol = "KYVE"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "kyve")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "kyve"
    var validatorPrefix = "kyvevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-kyve.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "kyve/"
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
        return "https://www.kyve.network/"
    }

    func getInfoLink2() -> String {
        return "https://blog.kyve.network/"
    }
}
