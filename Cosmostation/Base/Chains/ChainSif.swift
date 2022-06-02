//
//  ChainSif.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSif: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SIF_MAIN
    var chainImg = UIImage(named: "chainsifchain")
    var chainInfoImg = UIImage(named: "sifchainImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_sif", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_sif", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokensifchain")
    var stakeDenom = "rowan"
    var stakeSymbol = "ROWAN"
    
    var addressPrefix = "sif"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var grpcUrl = "lcd-sifchain-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-sifchain-app.cosmostation.io"
    var apiUrl = "https://api-sifchain.cosmostation.io/"
    var explorerUrl = MintscanUrl + "sifchain/"
    var validatorImgUrl = MonikerUrl + "sif/"
    var relayerImgUrl = RelayerUrl + "sifchain/relay-sifchain-unknown.png"
    
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
