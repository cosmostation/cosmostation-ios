//
//  ChainOsmosis.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOsmosis: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.OSMOSIS_MAIN
    var chainImg = UIImage(named: "chainOsmosis")
    var chainInfoImg = UIImage(named: "infoiconOsmosis")
    var chainInfoTitle = NSLocalizedString("send_guide_title_osmosis", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_osmosis", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenOsmosis")
    var stakeDenom = "uosmo"
    var stakeSymbol = "OSMO"
    
    var addressPrefix = "osmo"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var grpcUrl = "lcd-osmosis-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-osmosis-app.cosmostation.io"
    var apiUrl = "https://api-osmosis.cosmostation.io/"
    var explorerUrl = MintscanUrl + "osmosis/"
    var validatorImgUrl = MonikerUrl + "osmosis/"
    var relayerImgUrl = RelayerUrl + "osmosis/relay-osmosis-unknown.png"
    
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
