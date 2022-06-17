//
//  ChainCertik.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCertik: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CERTIK_MAIN
    var chainImg = UIImage(named: "certikChainImg")
    var chainInfoImg = UIImage(named: "certikImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_certik", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_certik", comment: "")
    var chainColor = UIColor(named: "certik")!
    var chainColorBG = UIColor(named: "certik_bg")!
    var chainTitle = "(Certik Mainnet)"
    var chainTitle2 = "CERTIK"
    var chainDBName = "SUPPORT_CHAIN_CERTIK_MAIN"
    var chainAPIName = "certik"
    
    var stakeDenomImg = UIImage(named: "certikTokenImg")
    var stakeDenom = "uctk"
    var stakeSymbol = "CTK"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "certik")!
    
    var addressPrefix = "certik"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-certik-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-certik-app.cosmostation.io"
    var apiUrl = "https://api-certik.cosmostation.io/"
    var explorerUrl = MintscanUrl + "certik/"
    var validatorImgUrl = MonikerUrl + "certik/"
    var relayerImgUrl = RelayerUrl + "certik/relay-certik-unknown.png"
    
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
