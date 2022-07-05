//
//  ChainJuno.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainJuno: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.JUNO_MAIN
    var chainImg = UIImage(named: "chainJuno")
    var chainInfoImg = UIImage(named: "infoJuno")
    var chainInfoTitle = NSLocalizedString("send_guide_title_juno", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_juno", comment: "")
    var chainColor = UIColor(named: "juno")!
    var chainColorBG = UIColor(named: "juno_bg")!
    var chainTitle = "(Juno Mainnet)"
    var chainTitle2 = "JUNO"
    var chainDBName = CHAIN_JUNO_S
    var chainAPIName = "juno"
    var chainIdPrefix = "juno-"
    
    var stakeDenomImg = UIImage(named: "tokenJuno")
    var stakeDenom = "ujuno"
    var stakeSymbol = "JUNO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "juno")!
    
    var addressPrefix = "juno"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.0025ujuno"
    let gasRate1 = "0.005ujuno"
    let gasRate2 = "0.025ujuno"
    
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-juno-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-juno-app.cosmostation.io/"
    var apiUrl = "https://api-juno.cosmostation.io/"
    var explorerUrl = MintscanUrl + "juno/"
    var validatorImgUrl = MonikerUrl + "juno/"
    var relayerImgUrl = RelayerUrl + "juno/relay-juno-unknown.png"
    var priceUrl = CoingeckoUrl + "juno-network"
    
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
        return "https://junochain.com/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@JunoNetwork/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
