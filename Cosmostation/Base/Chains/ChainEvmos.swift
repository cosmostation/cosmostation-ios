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
    var chainInfoImg = UIImage(named: "infoEvmos")
    var chainInfoTitle = NSLocalizedString("send_guide_title_evmos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_evmos", comment: "")
    var chainColor = UIColor(named: "evmos")!
    var chainColorBG = UIColor(named: "evmos_bg")!
    var chainTitle = "(Evmos Mainnet)"
    var chainTitle2 = "EVMOS"
    var chainDBName = CHAIN_EVMOS_S
    var chainAPIName = "evmos"
    var chainIdPrefix = "evmos_"
    
    var stakeDenomImg = UIImage(named: "tokenEvmos")
    var stakeDenom = "aevmos"
    var stakeSymbol = "EVMOS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "evmos")!
    
    var addressPrefix = "evmos"
    let addressHdPath0 = "m/44'/60'/0'/0/X"
    
    let gasRate0 = "20000000000aevmos"
    
    var pushSupport = false
    var wcSupoort = true
    var grpcUrl = "lcd-evmos-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-evmos-app.cosmostation.io/"
    var apiUrl = "https://api-evmos.cosmostation.io/"
    var explorerUrl = MintscanUrl + "evmos/"
    var validatorImgUrl = MonikerUrl + "evmos/"
    var relayerImgUrl = RelayerUrl + "evmos/relay-evmos-unknown.png"
    var priceUrl = CoingeckoUrl + "evmos"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://evmos.org/"
    }

    func getInfoLink2() -> String {
        return "https://evmos.blog/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
