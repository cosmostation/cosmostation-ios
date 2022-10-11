//
//  ChainBinance.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBinance: ChainConfig {
    var isGrpc = false
    var chainType = ChainType.BINANCE_MAIN
    var chainImg = UIImage(named: "chainBinance")
    var chainInfoImg = UIImage(named: "infoBinanace")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bnb", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bnb", comment: "")
    var chainColor = UIColor(named: "binance")!
    var chainColorBG = UIColor(named: "binance_bg")!
    var chainTitle = "(Binance Mainnet)"
    var chainTitle2 = "BINANCE"
    var chainDBName = CHAIN_BINANCE_S
    var chainAPIName = ""
    var chainIdPrefix = "binance-chain-tigris"
    
    var stakeDenomImg = UIImage(named: "tokenBinance")
    var stakeDenom = "BNB"
    var stakeSymbol = "BNB"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "binance")!
    var divideDecimal: Int16 = 0
    var displayDecimal: Int16 = 8
    
    var addressPrefix = "bnb"
    var validatorPrefix = ""
    let addressHdPath0 = "m/44'/714'/0'/0/X"
    
    let gasRate0 = "0.0BNB"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = ""
    var grpcPort = -1
    var lcdUrl = "https://dex.binance.org/"
    var apiUrl = "https://dex.binance.org/"
    var explorerUrl = "https://binance.mintscan.io/"
    var validatorImgUrl = ""
    var priceUrl = CoingeckoUrl + "binancecoin"
    
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
        return "https://www.bnbchain.org/en"
    }

    func getInfoLink2() -> String {
        return "https://www.bnbchain.org/en/blog/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

let BNB_MAIN_DENOM = "BNB"
