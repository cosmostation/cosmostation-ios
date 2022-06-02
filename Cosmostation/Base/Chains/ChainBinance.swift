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
    var chainImg = UIImage(named: "binanceChImg")
    var chainInfoImg = UIImage(named: "binanceImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bnb", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bnb", comment: "")
    
    var stakeDenomImg = UIImage(named: "bnbTokenImg")
    var stakeDenom = "BNB"
    var stakeSymbol = "BNB"
    
    var addressPrefix = "bnb"
    let addressHdPath0 = "m/44'/714'/0'/0/X"
    
    var grpcUrl = ""
    var grpcPort = ""
    var lcdUrl = "https://dex.binance.org/"
    var apiUrl = "https://dex.binance.org/"
    var explorerUrl = "https://binance.mintscan.io/"
    var validatorImgUrl = ""
    var relayerImgUrl = ""
    
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
