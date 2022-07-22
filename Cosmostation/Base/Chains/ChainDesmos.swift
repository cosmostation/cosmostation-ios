//
//  ChainDesmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainDesmos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.DESMOS_MAIN
    var chainImg = UIImage(named: "chainDesmos")
    var chainInfoImg = UIImage(named: "infoDesmos")
    var chainInfoTitle = NSLocalizedString("send_guide_title_desmos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_desmos", comment: "")
    var chainColor = UIColor(named: "desmos")!
    var chainColorBG = UIColor(named: "desmos_bg")!
    var chainTitle = "(Desmos Mainnet)"
    var chainTitle2 = "DESMOS"
    var chainDBName = CHAIN_DESMOS_S
    var chainAPIName = "desmos"
    var chainIdPrefix = "desmos-"
    
    var stakeDenomImg = UIImage(named: "tokenDesmos")
    var stakeDenom = "udsm"
    var stakeSymbol = "DSM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "desmos")!
    
    var addressPrefix = "desmos"
    let addressHdPath0 = "m/44'/852'/0'/0/X"
    
    let gasRate0 = "0.001udsm"
    let gasRate1 = "0.01udsm"
    let gasRate2 = "0.025udsm"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-desmos-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-desmos-app.cosmostation.io/"
    var apiUrl = "https://api-desmos.cosmostation.io/"
    var explorerUrl = MintscanUrl + "desmos/"
    var validatorImgUrl = MonikerUrl + "desmos/"
    var relayerImgUrl = RelayerUrl + "desmos/relay-desmos-unknown.png"
    var priceUrl = CoingeckoUrl + "desmos"
    
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
        return "https://www.desmos.network/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/desmosnetwork"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
