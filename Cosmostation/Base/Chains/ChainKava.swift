//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKava: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KAVA_MAIN
    var chainImg = UIImage(named: "kavaImg")
    var chainInfoImg = UIImage(named: "kavamainImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_kava", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_kava", comment: "")
    
    var stakeDenomImg = UIImage(named: "kavaTokenImg")
    var stakeDenom = "ukava"
    var stakeSymbol = "KAVA"
    
    var addressPrefix = "kava"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    var addressaddressHdPath1 = "m/44'/459'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-kava-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-kava-app.cosmostation.io"
    var apiUrl = "https://api-kava.cosmostation.io/"
    var explorerUrl = MintscanUrl + "kava/"
    var validatorImgUrl = MonikerUrl + "kava/"
    var relayerImgUrl = RelayerUrl + "kava/relay-kava-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressaddressHdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
