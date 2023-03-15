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
    var chainInfoTitle = "BINANCE"
    var chainInfoMsg = NSLocalizedString("guide_msg_bnb", comment: "")
    var chainColor = UIColor(named: "binance")!
    var chainColorBG = UIColor(named: "binance_bg")!
    var chainTitle = "(Binance Mainnet)"
    var chainTitle2 = "BINANCE"
    var chainDBName = CHAIN_BINANCE_S
    var chainAPIName = "binance"
    var chainKoreanName = "바이낸스"
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
    var defaultPath = "m/44'/714'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = true
    var kadoMoneySupoort = false
    var grpcUrl = ""
    var grpcPort = -1
    var rpcUrl = ""
    var lcdUrl = "https://dex.binance.org/"
    var explorerUrl = "https://binance.mintscan.io/"
    var priceUrl = GeckoUrl + "binancecoin"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath]
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
}


let BNB_MAIN_DENOM = "BNB"
let BNB_GECKO_ID = "binancecoin"
