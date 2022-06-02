//
//  ChainProvenance.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainProvenance: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.PROVENANCE_MAIN
    var chainImg = UIImage(named: "chainProvenance")
    var chainInfoImg = UIImage(named: "infoiconProvenance")
    var chainInfoTitle = NSLocalizedString("send_guide_title_provenance", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_provenance", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenHash")
    var stakeDenom = "nhash"
    var stakeSymbol = "HASH"
    
    var addressPrefix = "pb"
    let addressHdPath0 = "m/44'/505'/0'/0/X"
    
    var grpcUrl = "lcd-provenance-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-provenance-app.cosmostation.io"
    var apiUrl = "https://api-provenance.cosmostation.io/"
    var explorerUrl = MintscanUrl + "provenance/"
    var validatorImgUrl = MonikerUrl + "provenance/"
    var relayerImgUrl = RelayerUrl + "provenance/relay-provenance-unknown.png"
    
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
