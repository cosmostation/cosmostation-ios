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
    var chainDBName = "SUPPORT_CHAIN_BITCANA"
    var chainAPIName = "bitcanna"
    
    var stakeDenomImg = UIImage(named: "tokenBitcanna")
    var stakeDenom = "ubcna"
    var stakeSymbol = "BCNA"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "bitcanna")!
    
    var addressPrefix = "bcna"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-bitcanna-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-bitcanna-app.cosmostation.io"
    var apiUrl = "https://api-bitcanna.cosmostation.io/"
    var explorerUrl = MintscanUrl + "bitcanna/"
    var validatorImgUrl = MonikerUrl + "bitcanna/"
    var relayerImgUrl = RelayerUrl + "bitcanna/relay-bitcanna-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}

