//
//  ChainStargaze.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainStargaze: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.STARGAZE_MAIN
    var chainImg = UIImage(named: "chainStargaze")
    var chainInfoImg = UIImage(named: "infoiconStargaze")
    var chainInfoTitle = NSLocalizedString("send_guide_title_stargaze", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_stargaze", comment: "")
    var chainColor = UIColor(named: "stargaze")!
    var chainColorDark = UIColor(named: "stargaze_dark")
    var chainColorBG = UIColor(named: "stargaze")!.withAlphaComponent(0.15)
    var chainTitle = "(Stargaze Mainnet)"
    var chainTitle2 = "STARGAZE"
    var chainDBName = "SUPPORT_CHAIN_STARGAZE"
    var chainAPIName = "stargaze"
    
    var stakeDenomImg = UIImage(named: "tokenStargaze")
    var stakeDenom = "ustars"
    var stakeSymbol = "STARS"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "stargaze")!
    
    var addressPrefix = "stars"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-stargaze-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-stargaze-app.cosmostation.io"
    var apiUrl = "https://api-stargaze.cosmostation.io/"
    var explorerUrl = MintscanUrl + "stargaze/"
    var validatorImgUrl = MonikerUrl + "stargaze/"
    var relayerImgUrl = RelayerUrl + "stargaze/relay-stargaze-unknown.png"
    
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
