//
//  ChainNyx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainNyx: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.NYX_MAIN
    var chainImg = UIImage(named: "chainNym")
    var chainInfoImg = UIImage(named: "infoiconNym")
    var chainInfoTitle = NSLocalizedString("send_guide_title_nyx", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_nyx", comment: "")
    var chainColor = UIColor(named: "nyx")!
    var chainColorBG = UIColor(named: "nyx_bg")!
    var chainTitle = "(Nyx Mainnet)"
    var chainTitle2 = "NYX"
    var chainDBName = "SUPPORT_CHAIN_NYX"
    var chainAPIName = "nyx"
    
    var stakeDenomImg = UIImage(named: "tokenNyx")
    var stakeDenom = "unyx"
    var stakeSymbol = "NYX"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "nyx")!
    
    var addressPrefix = "n"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-nym-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-nym-app.cosmostation.io"
    var apiUrl = "https://api-nym.cosmostation.io/"
    var explorerUrl = MintscanUrl + "nyx/"
    var validatorImgUrl = MonikerUrl + "nyx/"
    var relayerImgUrl = RelayerUrl + "nyx/relay-nyx-unknown.png"
    
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
