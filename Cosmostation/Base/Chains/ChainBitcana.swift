//
//  ChainBitcana.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBitcana: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.BITCANA_MAIN
    var chainImg = UIImage(named: "chainBitcanna")
    var chainInfoImg = UIImage(named: "infoBitcanna")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bitcanna", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bitcanna", comment: "")
    var chainColor = UIColor(named: "bitcanna")!
    var chainColorBG = UIColor(named: "bitcanna_bg")!
    var chainTitle = "(Bitcanna Mainnet)"
    var chainTitle2 = "BITCANNA"
    var chainDBName = CHAIN_BITCANA_S
    var chainAPIName = "bitcanna"
    var chainIdPrefix = "bitcanna-"
    
    var stakeDenomImg = UIImage(named: "tokenBitcanna")
    var stakeDenom = "ubcna"
    var stakeSymbol = "BCNA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "bitcanna")!
    
    var addressPrefix = "bcna"
    var validatorPrefix = "bcnavaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.025ubcna"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-bitcanna-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-bitcanna-app.cosmostation.io/"
    var apiUrl = "https://api-bitcanna.cosmostation.io/"
    var explorerUrl = MintscanUrl + "bitcanna/"
    var validatorImgUrl = MonikerUrl + "bitcanna/"
    var relayerImgUrl = RelayerUrl + "bitcanna/relay-bitcanna-unknown.png"
    var priceUrl = CoingeckoUrl + "bitcanna"
    
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
        return "https://www.bitcanna.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@BitCannaGlobal"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

