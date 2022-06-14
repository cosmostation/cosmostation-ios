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
    var chainInfoImg = UIImage(named: "iovImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_iov", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_iov", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenStarname")
    var stakeDenom = "uiov"
    var stakeSymbol = "IOV"
    
    var addressPrefix = "star"
    let addressHdPath0 = "m/44'/234'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-iov-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-iov-app.cosmostation.io"
    var apiUrl = "https://api-iov.cosmostation.io/"
    var explorerUrl = MintscanUrl + "starname/"
    var validatorImgUrl = MonikerUrl + "iov/"
    var relayerImgUrl = RelayerUrl + "starname/relay-starname-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
