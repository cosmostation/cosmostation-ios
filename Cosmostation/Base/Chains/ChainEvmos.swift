//
//  ChainEvmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainEvmos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.EVMOS_MAIN
    var chainImg = UIImage(named: "chainEvmos")
    var chainInfoImg = UIImage(named: "infoiconEvmos")
    var chainInfoTitle = NSLocalizedString("send_guide_title_evmos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_evmos", comment: "")
    var chainColor = UIColor(named: "evmos")!
    var chainColorDark = UIColor(named: "evmos_dark")
    var chainColorBG = UIColor(named: "evmos")!.withAlphaComponent(0.15)
    var chainTitle = "(Evmos Mainnet)"
    var chainTitle2 = "EVMOS"
    var chainDBName = "SUPPORT_CHAIN_EVMOS"
    var chainAPIName = "evmos"
    
    var stakeDenomImg = UIImage(named: "tokenEvmos")
    var stakeDenom = "aevmos"
    var stakeSymbol = "EVMOS"
    var stakeSendImg = UIImage(named: "btnSendEvmos")
    var stakeSendBg = UIColor.black
    
    var addressPrefix = "evmos"
    let addressHdPath0 = "m/44'/60'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-evmos-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-evmos-app.cosmostation.io"
    var apiUrl = "https://api-evmos.cosmostation.io/"
    var explorerUrl = MintscanUrl + "evmos/"
    var validatorImgUrl = MonikerUrl + "evmos/"
    var relayerImgUrl = RelayerUrl + "evmos/relay-evmos-unknown.png"
    
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
