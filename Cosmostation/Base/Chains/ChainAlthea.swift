//
//  ChainAlthea.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/15.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAlthea: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.ALTHEA_MAIN
    var chainImg = UIImage(named: "chainAlthea")
    var chainInfoImg = UIImage(named: "infoAlthea")
    var chainInfoTitle = NSLocalizedString("send_guide_title_althea", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_althea", comment: "")
    var chainColor = UIColor(named: "althea")!
    var chainColorBG = UIColor(named: "althea_bg")!
    var chainTitle = "(Althea Mainnet)"
    var chainTitle2 = "ALTHEA"
    var chainDBName = CHAIN_ALTHEA_S
    var chainAPIName = "althea"
    var chainIdPrefix = "althea-"
    
    var stakeDenomImg = UIImage(named: "tokenAlthea")
    var stakeDenom = "ualtg"
    var stakeSymbol = "ALTG"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cosmos")!
    
    var addressPrefix = "althea"
    var validatorPrefix = "oper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.0ualtg"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-office.cosmostation.io"
    var grpcPort = 20100
    var lcdUrl = ""
    var apiUrl = ""
    var explorerUrl = ""
    var validatorImgUrl = ""
    var priceUrl = ""
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://www.althea.net/"
    }

    func getInfoLink2() -> String {
        return "https://blog.althea.net/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
