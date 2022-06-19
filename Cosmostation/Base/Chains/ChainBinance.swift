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
    var chainDBName = "SUPPORT_CHAIN_BINANCE_MAIN"
    var chainAPIName = ""
    
    var stakeDenomImg = UIImage(named: "tokenBinance")
    var stakeDenom = "BNB"
    var stakeSymbol = "BNB"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "binance")!
    
    var addressPrefix = "bnb"
    let addressHdPath0 = "m/44'/714'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = ""
    var grpcPort = ""
    var lcdUrl = "https://dex.binance.org/"
    var apiUrl = "https://dex.binance.org/"
    var explorerUrl = "https://binance.mintscan.io/"
    var validatorImgUrl = ""
    var relayerImgUrl = ""
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
}
