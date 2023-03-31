//
//  ChainQuicksilver.swift
//  Cosmostation
//
//  Created by 권혁준 on 2022/12/16.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainQuicksilver: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.QUICKSILVER_MAIN
    var chainImg = UIImage(named: "chainQuicksilver")
    var chainInfoImg = UIImage(named: "infoQuicksilver")
    var chainInfoTitle = "QUICKSILVER"
    var chainInfoMsg = NSLocalizedString("guide_msg_quicksilver", comment: "")
    var chainColor = UIColor(named: "quicksilver")!
    var chainColorBG = UIColor(named: "quicksilver_bg")!
    var chainTitle = "(Quicksilver Mainnet)"
    var chainTitle2 = "QUICKSILVER"
    var chainDBName = CHAIN_QUICKSILVER_S
    var chainAPIName = "quicksilver"
    var chainKoreanName = "퀵실버"
    var chainIdPrefix = "quicksilver-"
    
    var stakeDenomImg = UIImage(named: "tokenQuicksilver")
    var stakeDenom = "uqck"
    var stakeSymbol = "QCK"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "quicksilver")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "quick"
    var validatorPrefix = "quickvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-quicksilver.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "quicksilver/"
    var priceUrl = GeckoUrl + "quicksilver"
    
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
        return "https://quicksilver.zone/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/quicksilverzone"
    }
}
