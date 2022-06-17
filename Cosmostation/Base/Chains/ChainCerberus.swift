//
//  ChainCerberus.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCerberus: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CERBERUS_MAIN
    var chainImg = UIImage(named: "chainCerberus")
    var chainInfoImg = UIImage(named: "infoCerberus")
    var chainInfoTitle = NSLocalizedString("send_guide_title_cerberus", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_cerberus", comment: "")
    var chainColor = UIColor(named: "cerberus")!
    var chainColorBG = UIColor(named: "cerberus_bg")!
    var chainTitle = "(Cerberus Mainnet)"
    var chainTitle2 = "CERBERUS"
    var chainDBName = "SUPPORT_CHAIN_CERBERUS"
    var chainAPIName = "cerberus"
    
    var stakeDenomImg = UIImage(named: "tokenCerberus")
    var stakeDenom = "ucrbrus"
    var stakeSymbol = "CRBRUS"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "cerberus")!
    
    var addressPrefix = "cerberus"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-cerberus-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-cerberus-app.cosmostation.io"
    var apiUrl = "https://api-cerberus.cosmostation.io/"
    var explorerUrl = MintscanUrl + "cerberus/"
    var validatorImgUrl = MonikerUrl + "cerberus/"
    var relayerImgUrl = RelayerUrl + "cerberus/relay-cerberus-unknown.png"
    
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
