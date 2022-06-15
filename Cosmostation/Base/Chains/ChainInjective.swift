//
//  ChainInjective.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainInjective: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.INJECTIVE_MAIN
    var chainImg = UIImage(named: "chainInjective")
    var chainInfoImg = UIImage(named: "infoiconInjective")
    var chainInfoTitle = NSLocalizedString("send_guide_title_injective", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_injective", comment: "")
    var chainColor = UIColor(named: "injective")!
    var chainColorDark = UIColor(named: "injective_dark")
    var chainColorBG = UIColor(named: "injective")!.withAlphaComponent(0.15)
    var chainTitle = "(Injective Mainnet)"
    var chainTitle2 = "INJECTIVE"
    var chainDBName = "SUPPORT_CHAIN_INJECTIVE"
    var chainAPIName = "injective"
    
    var stakeDenomImg = UIImage(named: "tokenInjective")
    var stakeDenom = "inj"
    var stakeSymbol = "INJ"
    var stakeSendImg = UIImage(named: "btnSendAlthea")
    var stakeSendBg = UIColor(named: "injective")!
    
    var addressPrefix = "inj"
    let addressHdPath0 = "m/44'/60'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-inj-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-inj-app.cosmostation.io"
    var apiUrl = "https://api-inj.cosmostation.io/"
    var explorerUrl = MintscanUrl + "injective/"
    var validatorImgUrl = MonikerUrl + "injective/"
    var relayerImgUrl = RelayerUrl + "injective/relay-injective-unknown.png"
    
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
