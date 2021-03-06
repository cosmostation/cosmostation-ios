//
//  ChainChihuahua.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainChihuahua: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CHIHUAHUA_MAIN
    var chainImg = UIImage(named: "chainChihuahua")
    var chainInfoImg = UIImage(named: "infoChihuahua")
    var chainInfoTitle = NSLocalizedString("send_guide_title_chihuahua", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_chihuahua", comment: "")
    var chainColor = UIColor(named: "chihuahua")!
    var chainColorBG = UIColor(named: "chihuahua_bg")!
    var chainTitle = "(Chihuahua Mainnet)"
    var chainTitle2 = "CHIHUAHUA"
    var chainDBName = CHAIN_CHIHUAHUA_S
    var chainAPIName = "chihuahua"
    var chainIdPrefix = "chihuahua-"
    
    var stakeDenomImg = UIImage(named: "tokenChihuahua")
    var stakeDenom = "uhuahua"
    var stakeSymbol = "HUAHUA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "chihuahua")!
    
    var addressPrefix = "chihuahua"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.00035uhuahua"
    let gasRate1 = "0.0035uhuahua"
    let gasRate2 = "0.035uhuahua"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-chihuahua-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-chihuahua-app.cosmostation.io/"
    var apiUrl = "https://api-chihuahua.cosmostation.io/"
    var explorerUrl = MintscanUrl + "chihuahua/"
    var validatorImgUrl = MonikerUrl + "chihuahua/"
    var relayerImgUrl = RelayerUrl + "chihuahua/relay-chihuahua-unknown.png"
    var priceUrl = CoingeckoUrl + "chihuahua-chain"
    
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
        return "https://chi.huahua.wtf/"
    }

    func getInfoLink2() -> String {
        return "https://chi.huahua.wtf/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
