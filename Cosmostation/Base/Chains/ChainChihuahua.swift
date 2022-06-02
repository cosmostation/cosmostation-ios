//
//  ChainChihuahua.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainChihuahua: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CHIHUAHUA_MAIN
    var chainImg = UIImage(named: "chainChihuahua")
    var chainInfoImg = UIImage(named: "infoiconChihuahua")
    var chainInfoTitle = NSLocalizedString("send_guide_title_chihuahua", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_chihuahua", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenHuahua")
    var stakeDenom = "uhuahua"
    var stakeSymbol = "HUAHUA"
    
    var addressPrefix = "chihuahua"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var grpcUrl = "lcd-chihuahua-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-chihuahua-app.cosmostation.io"
    var apiUrl = "https://api-chihuahua.cosmostation.io/"
    var explorerUrl = MintscanUrl + "chihuahua/"
    var validatorImgUrl = MonikerUrl + "chihuahua/"
    var relayerImgUrl = RelayerUrl + "chihuahua/relay-chihuahua-unknown.png"
    
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
