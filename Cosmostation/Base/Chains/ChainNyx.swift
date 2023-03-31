//
//  ChainNyx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainNyx: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.NYX_MAIN
    var chainImg = UIImage(named: "chainNyx")
    var chainInfoImg = UIImage(named: "infoNyx")
    var chainInfoTitle = "NYX"
    var chainInfoMsg = NSLocalizedString("guide_msg_nyx", comment: "")
    var chainColor = UIColor(named: "nyx")!
    var chainColorBG = UIColor(named: "nyx_bg")!
    var chainTitle = "(Nyx Mainnet)"
    var chainTitle2 = "NYX"
    var chainDBName = CHAIN_NYX_S
    var chainAPIName = "nyx"
    var chainKoreanName = "닉스"
    var chainIdPrefix = "nyx"
    
    var stakeDenomImg = UIImage(named: "tokenNyx")
    var stakeDenom = "unyx"
    var stakeSymbol = "NYX"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "nyx")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "n"
    var validatorPrefix = "nvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-nyx.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "nyx/"
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
        return "https://nymtech.net/"
    }

    func getInfoLink2() -> String {
        return "https://nymtech.net/blog/"
    }
}

let NYX_NYM_DENOM = "unym"
