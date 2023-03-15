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
    var chainInfoTitle = "OKC"
    var chainInfoMsg = NSLocalizedString("guide_msg_ok", comment: "")
    var chainColor = UIColor(named: "okc")!
    var chainColorBG = UIColor(named: "okc_bg")!
    var chainTitle = "(OKC Mainnet)"
    var chainTitle2 = "OKC"
    var chainDBName = CHAIN_OKEX_S
    var chainAPIName = "okc"
    var chainKoreanName = "오케이씨"
    var chainIdPrefix = "exchain-"
    
    var stakeDenomImg = UIImage(named: "tokenOkc")
    var stakeDenom = "okt"
    var stakeSymbol = "OKT"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "okc")!
    var divideDecimal: Int16 = 0
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "ex"
    var validatorPrefix = "ex"
    let addressHdPath = "m/44'/996'/0'/0/X"
    var defaultPath = "m/44'/60'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = true
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = ""
    var grpcPort = -1
    var rpcUrl = "https://exchainrpc.okex.org"
    var lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
    var explorerUrl = "https://www.oklink.com/okexchain/"
    var priceUrl = GeckoUrl + "okc-token"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath, addressHdPath, defaultPath]
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
}

let OKT_MAIN_DENOM = "okt"
let OKT_OKB = "okb"
let OKT_GECKO_ID = "oec-token"
