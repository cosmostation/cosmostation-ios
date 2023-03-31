//
//  ChainStarname.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainStarname: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.IOV_MAIN
    var chainImg = UIImage(named: "chainStarname")
    var chainInfoImg = UIImage(named: "infoStarname")
    var chainInfoTitle = "STARNAME"
    var chainInfoMsg = NSLocalizedString("guide_msg_iov", comment: "")
    var chainColor = UIColor(named: "starname")!
    var chainColorBG = UIColor(named: "starname_bg")!
    var chainTitle = "(Starname Mainnet)"
    var chainTitle2 = "STARNAME"
    var chainDBName = CHAIN_IOV_S
    var chainAPIName = "starname"
    var chainKoreanName = "스타네임"
    var chainIdPrefix = "iov-"
    
    var stakeDenomImg = UIImage(named: "tokenStarname")
    var stakeDenom = "uiov"
    var stakeSymbol = "IOV"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "starname")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "star"
    var validatorPrefix = "starvaloper"
    var defaultPath = "m/44'/234'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-starname.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "starname/"
    var priceUrl = GeckoUrl + "starname"
    
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
        return "https://www.starname.me/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/iov-internet-of-values"
    }
}
