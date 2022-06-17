//
//  ChainLum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainLum: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.LUM_MAIN
    var chainImg = UIImage(named: "chainLum")
    var chainInfoImg = UIImage(named: "infoLum")
    var chainInfoTitle = NSLocalizedString("send_guide_title_lum", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_lum", comment: "")
    var chainColor = UIColor(named: "lum")!
    var chainColorBG = UIColor(named: "lum_bg")!
    var chainTitle = "(Lum Mainnet)"
    var chainTitle2 = "LUM"
    var chainDBName = "SUPPORT_CHAIN_LUM"
    var chainAPIName = "lum"
    
    var stakeDenomImg = UIImage(named: "tokenLum")
    var stakeDenom = "ulum"
    var stakeSymbol = "LUM"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "lum")!
    
    var addressPrefix = "lum"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    let addressHdPath1 = "m/44'/459'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-lum-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-lum-app.cosmostation.io"
    var apiUrl = "https://api-lum.cosmostation.io/"
    var explorerUrl = MintscanUrl + "lum/"
    var validatorImgUrl = MonikerUrl + "lum-network/"
    var relayerImgUrl = RelayerUrl + "lum-network/relay-lum-unknown.png"
    var priceUrl = CoingeckoUrl + "lum-network"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://lum.network/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/lum-network"
    }
}
