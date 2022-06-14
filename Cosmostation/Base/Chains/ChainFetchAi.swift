//
//  ChainFetchAi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainFetchAi: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.FETCH_MAIN
    var chainImg = UIImage(named: "chainfetchai")
    var chainInfoImg = UIImage(named: "fetchaiImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_fetch", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_fetch", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenfetchai")
    var stakeDenom = "afet"
    var stakeSymbol = "FET"
    
    var addressPrefix = "fetch"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    let addressHdPath1 = "m/44'/60'/0'/0/X"
    let addressHdPath2 = "m/44'/60'/X'/0/0"
    let addressHdPath3 = "m/44'/60'/0'/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-fetchai-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-fetchai-app.cosmostation.io"
    var apiUrl = "https://api-fetchai.cosmostation.io/"
    var explorerUrl = MintscanUrl + "fetchai/"
    var validatorImgUrl = MonikerUrl + "fetchai/"
    var relayerImgUrl = RelayerUrl + "fetchai/relay-fetchai-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath1, addressHdPath2, addressHdPath3]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
