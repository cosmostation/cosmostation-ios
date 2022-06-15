//
//  ChainComdex.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainComdex: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.COMDEX_MAIN
    var chainImg = UIImage(named: "chainComdex")
    var chainInfoImg = UIImage(named: "infoiconComdex")
    var chainInfoTitle = NSLocalizedString("send_guide_title_comdex", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_comdex", comment: "")
    var chainColor = UIColor(named: "comdex")!
    var chainColorDark = UIColor(named: "comdex_dark")
    var chainColorBG = UIColor.init(hexString: "005ac5").withAlphaComponent(0.15)
    var chainTitle = "(Comdex Mainnet)"
    var chainTitle2 = "COMDEX"
    var chainDBName = "SUPPORT_CHAIN_COMDEX"
    var chainAPIName = "comdex"
    
    var stakeDenomImg = UIImage(named: "tokenComdex")
    var stakeDenom = "ucmdx"
    var stakeSymbol = "CMDX"
    var stakeSendImg = UIImage(named: "btnSendComdex")
    var stakeSendBg = UIColor.init(hexString: "03264a")
    
    var addressPrefix = "comdex"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-comdex-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-comdex-app.cosmostation.io"
    var apiUrl = "https://api-comdex.cosmostation.io/"
    var explorerUrl = MintscanUrl + "comdex/"
    var validatorImgUrl = MonikerUrl + "comdex/"
    var relayerImgUrl = RelayerUrl + "comdex/relay-comdex-unknown.png"
    
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
