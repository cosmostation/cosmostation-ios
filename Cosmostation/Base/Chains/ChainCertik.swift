//
//  ChainCertik.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCertik: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CERTIK_MAIN
    var chainImg = UIImage(named: "chainCertik")
    var chainInfoImg = UIImage(named: "infoCertik")
    var chainInfoTitle = NSLocalizedString("send_guide_title_certik", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_certik", comment: "")
    var chainColor = UIColor(named: "certik")!
    var chainColorBG = UIColor(named: "certik_bg")!
    var chainTitle = "(Shentu Mainnet)"
    var chainTitle2 = "SHENTU"
    var chainDBName = CHAIN_CERTIK_S
    var chainAPIName = "shentu"
    var chainIdPrefix = "shentu-"
    
    var stakeDenomImg = UIImage(named: "tokenCertik")
    var stakeDenom = "uctk"
    var stakeSymbol = "CTK"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "certik")!
    
    var addressPrefix = "certik"
    var validatorPrefix = "certikvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.05uctk"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-shentu-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-shentu-app.cosmostation.io/"
    var apiUrl = "https://api-shentu.cosmostation.io/"
    var explorerUrl = MintscanUrl + "shentu/"
    var validatorImgUrl = MonikerUrl + "shentu/"
    var relayerImgUrl = RelayerUrl + "shentu/relay-shentu-unknown.png"
    var priceUrl = CoingeckoUrl + "shentu"
    
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
        return "https://www.certik.foundation/"
    }

    func getInfoLink2() -> String {
        return "https://www.certik.foundation/blog"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
