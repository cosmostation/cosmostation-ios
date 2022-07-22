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
    var chainInfoTitle = NSLocalizedString("send_guide_title_iov", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_iov", comment: "")
    var chainColor = UIColor(named: "starname")!
    var chainColorBG = UIColor(named: "starname_bg")!
    var chainTitle = "(Starname Mainnet)"
    var chainTitle2 = "STARNAME"
    var chainDBName = CHAIN_IOV_S
    var chainAPIName = "starname"
    var chainIdPrefix = "iov-"
    
    var stakeDenomImg = UIImage(named: "tokenStarname")
    var stakeDenom = "uiov"
    var stakeSymbol = "IOV"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "starname")!
    
    var addressPrefix = "star"
    let addressHdPath0 = "m/44'/234'/0'/0/X"
    
    let gasRate0 = "0.1uiov"
    let gasRate1 = "1.0uiov"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-iov-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-iov-app.cosmostation.io/"
    var apiUrl = "https://api-iov.cosmostation.io/"
    var explorerUrl = MintscanUrl + "starname/"
    var validatorImgUrl = MonikerUrl + "iov/"
    var relayerImgUrl = RelayerUrl + "starname/relay-starname-unknown.png"
    var priceUrl = CoingeckoUrl + "starname"
    
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
        return "https://www.starname.me/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/iov-internet-of-values"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
