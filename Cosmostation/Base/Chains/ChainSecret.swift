//
//  ChainSecret.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSecret: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SECRET_MAIN
    var chainImg = UIImage(named: "secretChainImg")
    var chainInfoImg = UIImage(named: "secretImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_secret", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_secret", comment: "")
    var chainColor = UIColor(named: "secret")!
    var chainColorDark = UIColor(named: "secret_dark")
    var chainColorBG = UIColor(named: "secret")!.withAlphaComponent(0.15)
    var chainTitle = "(Secret Mainnet)"
    var chainTitle2 = "SECRET"
    var chainDBName = "SUPPORT_CHAIN_SECRET_MAIN"
    var chainAPIName = "secret"
    
    var stakeDenomImg = UIImage(named: "secretTokenImg")
    var stakeDenom = "uscrt"
    var stakeSymbol = "SCRT"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "secret_dark")!
    
    var addressPrefix = "secret"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    let addressHdPath1 = "m/44'/529'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-secret-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-secret.cosmostation.io"
    var apiUrl = "https://api-secret.cosmostation.io/"
    var explorerUrl = MintscanUrl + "secret/"
    var validatorImgUrl = MonikerUrl + "secret/"
    var relayerImgUrl = RelayerUrl + "secret/relay-secret-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
