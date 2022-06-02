//
//  ChainPersistence.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainPersistence: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.PERSIS_MAIN
    var chainImg = UIImage(named: "chainpersistence")
    var chainInfoImg = UIImage(named: "persistenceImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_persis", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_persis", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenpersistence")
    var stakeDenom = "uxprt"
    var stakeSymbol = "XPRT"
    
    var addressPrefix = "persistence"
    let addressHdPath0 = "m/44'/750'/0'/0/X"
    
    var grpcUrl = "lcd-persistence-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-persistence-app.cosmostation.io"
    var apiUrl = "https://api-persistence.cosmostation.io/"
    var explorerUrl = MintscanUrl + "persistence/"
    var validatorImgUrl = MonikerUrl + "persistence/"
    var relayerImgUrl = RelayerUrl + "persistence/relay-persistence-unknown.png"
    
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
