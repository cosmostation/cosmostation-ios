//
//  ChainUmee.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainUmee: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.UMEE_MAIN
    var chainImg = UIImage(named: "chainUmee")
    var chainInfoImg = UIImage(named: "infoUmee")
    var chainInfoTitle = "UMEE"
    var chainInfoMsg = NSLocalizedString("guide_msg_umee", comment: "")
    var chainColor = UIColor(named: "umee")!
    var chainColorBG = UIColor(named: "umee_bg")!
    var chainTitle = "(Umee Mainnet)"
    var chainTitle2 = "UMEE"
    var chainDBName = CHAIN_UMEE_S
    var chainAPIName = "umee"
    var chainKoreanName = "우미"
    var chainIdPrefix = "umee-"
    
    var stakeDenomImg = UIImage(named: "tokenUmee")
    var stakeDenom = "uumee"
    var stakeSymbol = "UMEE"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "umee")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "umee"
    var validatorPrefix = "umeevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-umee.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "umee/"
    var priceUrl = GeckoUrl + "umee"
    
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
        return "https://www.umee.cc/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/umeeblog"
    }
}
