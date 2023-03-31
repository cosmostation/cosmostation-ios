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
    var chainInfoTitle = "FETCH.AI"
    var chainInfoMsg = NSLocalizedString("guide_msg_fetch", comment: "")
    var chainColor = UIColor(named: "fetchai")!
    var chainColorBG = UIColor(named: "fetchai_bg")!
    var chainTitle = "(Fetch.Ai Mainnet)"
    var chainTitle2 = "FETCH.AI"
    var chainDBName = CHAIN_FETCH_S
    var chainAPIName = "fetchai"
    var chainKoreanName = "페치에이아이"
    var chainIdPrefix = "fetchhub-"
    
    var stakeDenomImg = UIImage(named: "tokenFetchAi")
    var stakeDenom = "afet"
    var stakeSymbol = "FET"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "fetchai")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "fetch"
    var validatorPrefix = "fetchvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    let addressHdPath1 = "m/44'/60'/0'/0/X"
    let addressHdPath2 = "m/44'/60'/X'/0/0"
    let addressHdPath3 = "m/44'/60'/0'/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-fetchai.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "fetchai/"
    var priceUrl = GeckoUrl + "fetch-ai"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath, addressHdPath1, addressHdPath2, addressHdPath3]
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
