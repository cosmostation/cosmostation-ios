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
    var chainInfoTitle = "ALTHEA"
    var chainInfoMsg = NSLocalizedString("guide_msg_althea", comment: "")
    var chainColor = UIColor(named: "althea")!
    var chainColorBG = UIColor(named: "althea_bg")!
    var chainTitle = "(Althea Mainnet)"
    var chainTitle2 = "ALTHEA"
    var chainDBName = CHAIN_ALTHEA_S
    var chainAPIName = "althea"
    var chainKoreanName = "알테아"
    var chainIdPrefix = "althea-"
    
    var stakeDenomImg = UIImage(named: "tokenAlthea")
    var stakeDenom = "ualtg"
    var stakeSymbol = "ALTG"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cosmos")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "althea"
    var validatorPrefix = "oper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "lcd-office.cosmostation.io"
    var grpcPort = 20100
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = ""
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
        return "https://www.althea.net/"
    }

    func getInfoLink2() -> String {
        return "https://blog.althea.net/"
    }
}
