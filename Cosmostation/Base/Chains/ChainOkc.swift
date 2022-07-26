//
//  ChainOkc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOkc: ChainConfig {
    var isGrpc = false
    var chainType = ChainType.OKEX_MAIN
    var chainImg = UIImage(named: "chainOkc")
    var chainInfoImg = UIImage(named: "infoOkc")
    var chainInfoTitle = NSLocalizedString("send_guide_title_ok", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_ok", comment: "")
    var chainColor = UIColor(named: "okc")!
    var chainColorBG = UIColor(named: "okc_bg")!
    var chainTitle = "(OKC Mainnet)"
    var chainTitle2 = "OKC"
    var chainDBName = CHAIN_OKEX_S
    var chainAPIName = ""
    var chainIdPrefix = "exchain-"
    
    var stakeDenomImg = UIImage(named: "tokenOkc")
    var stakeDenom = "okt"
    var stakeSymbol = "OKT"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "okc")!
    
    var addressPrefix = "ex"
    let addressHdPath0 = "m/44'/996'/0'/0/X"
    let addressHdPath1 = "m/44'/60'/0'/0/X"
    
    let gasRate0 = "0.0000000001okt"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = ""
    var grpcPort = -1
    var lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
    var apiUrl = "https://www.oklink.com/api/explorer/v1/"
    var explorerUrl = "https://www.oklink.com/okexchain/"
    var validatorImgUrl = MonikerUrl + "okex/"
    var relayerImgUrl = ""
    var priceUrl = CoingeckoUrl + "okc-token"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath0, addressHdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://www.okx.com"
    }

    func getInfoLink2() -> String {
        return "https://www.okx.com/academy/en/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

let OKEX_MAIN_DENOM = "okt"
let OKEX_MAIN_OKB = "okb"
