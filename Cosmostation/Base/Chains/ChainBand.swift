//
//  ChainBand.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBand: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.BAND_MAIN
    var chainImg = UIImage(named: "chainBand")
    var chainInfoImg = UIImage(named: "infoBand")
    var chainInfoTitle = NSLocalizedString("send_guide_title_band", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_band", comment: "")
    var chainColor = UIColor(named: "band")!
    var chainColorBG = UIColor(named: "band_bg")!
    var chainTitle = "(Band Mainnet)"
    var chainTitle2 = "BAND"
    var chainDBName = "SUPPORT_CHAIN_BAND_MAIN"
    var chainAPIName = "band"
    
    var stakeDenomImg = UIImage(named: "tokenBand")
    var stakeDenom = "uband"
    var stakeSymbol = "Band"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "band")!
    
    var addressPrefix = "band"
    let addressHdPath0 = "m/44'/494'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-band-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-band-app.cosmostation.io"
    var apiUrl = "https://api-band.cosmostation.io/"
    var explorerUrl = MintscanUrl + "band/"
    var validatorImgUrl = MonikerUrl + "bandprotocol/"
    var relayerImgUrl = RelayerUrl + "band/relay-band-unknown.png"
    
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
