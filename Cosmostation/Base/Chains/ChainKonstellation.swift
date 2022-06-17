//
//  ChainKonstellation.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKonstellation: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KONSTELLATION_MAIN
    var chainImg = UIImage(named: "chainKonstellation")
    var chainInfoImg = UIImage(named: "infoiconKonstellation")
    var chainInfoTitle = NSLocalizedString("send_guide_title_konstellation", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_konstellation", comment: "")
    var chainColor = UIColor(named: "konstellation")!
    var chainColorBG = UIColor(named: "konstellation_bg")!
    var chainTitle = "(Konstellation Mainnet)"
    var chainTitle2 = "KONSTELLATION"
    var chainDBName = "SUPPORT_CHAIN_KONSTELLATION"
    var chainAPIName = "konstellation"
    
    var stakeDenomImg = UIImage(named: "tokenKonstellation")
    var stakeDenom = "udarc"
    var stakeSymbol = "DARC"
    var stakeSendImg = UIImage(named: "btnSendKonstellation")
    var stakeSendBg = UIColor.init(hexString: "122951")
    
    var addressPrefix = "darc"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-konstellation-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-konstellation-app.cosmostation.io"
    var apiUrl = "https://api-konstellation.cosmostation.io/"
    var explorerUrl = MintscanUrl + "konstellation/"
    var validatorImgUrl = MonikerUrl + "konstellation/"
    var relayerImgUrl = RelayerUrl + "konstellation/relay-konstellation-unknown.png"
    
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
