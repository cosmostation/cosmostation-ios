//
//  ChainFetchAi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainFetchAi: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.FETCH_MAIN
    var chainImg = UIImage(named: "chainFetchAi")
    var chainInfoImg = UIImage(named: "infoFetchAi")
    var chainInfoTitle = NSLocalizedString("send_guide_title_fetch", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_fetch", comment: "")
    var chainColor = UIColor(named: "fetchai")!
    var chainColorBG = UIColor(named: "fetchai_bg")!
    var chainTitle = "(Fetch.Ai Mainnet)"
    var chainTitle2 = "FETCH.AI"
    var chainDBName = "SUPPORT_CHAIN_FETCH_MAIN"
    var chainAPIName = "fetchai"
    
    var stakeDenomImg = UIImage(named: "tokenFetchAi")
    var stakeDenom = "afet"
    var stakeSymbol = "FET"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "fetchai")!
    
    var addressPrefix = "fetch"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    let addressHdPath1 = "m/44'/60'/0'/0/X"
    let addressHdPath2 = "m/44'/60'/X'/0/0"
    let addressHdPath3 = "m/44'/60'/0'/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-fetchai-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-fetchai-app.cosmostation.io"
    var apiUrl = "https://api-fetchai.cosmostation.io/"
    var explorerUrl = MintscanUrl + "fetchai/"
    var validatorImgUrl = MonikerUrl + "fetchai/"
    var relayerImgUrl = RelayerUrl + "fetchai/relay-fetchai-unknown.png"
    var priceUrl = CoingeckoUrl + "fetch-ai"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath1, addressHdPath2, addressHdPath3]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://fetch.ai/"
    }

    func getInfoLink2() -> String {
        return "https://fetch.ai/blog/"
    }
}
