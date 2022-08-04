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
    var chainInfoImg = UIImage(named: "infoInjective")
    var chainInfoTitle = NSLocalizedString("send_guide_title_injective", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_injective", comment: "")
    var chainColor = UIColor(named: "injective")!
    var chainColorBG = UIColor(named: "injective_bg")!
    var chainTitle = "(Injective Mainnet)"
    var chainTitle2 = "INJECTIVE"
    var chainDBName = CHAIN_INJECTIVE_S
    var chainAPIName = "injective"
    var chainIdPrefix = "injective-"
    
    var stakeDenomImg = UIImage(named: "tokenInjective")
    var stakeDenom = "inj"
    var stakeSymbol = "INJ"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "injective")!
    
    var addressPrefix = "inj"
    var validatorPrefix = "injvaloper"
    let addressHdPath0 = "m/44'/60'/0'/0/X"
    
    let gasRate0 = "500000000inj"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-inj-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-inj-app.cosmostation.io/"
    var apiUrl = "https://api-inj.cosmostation.io/"
    var explorerUrl = MintscanUrl + "injective/"
    var validatorImgUrl = MonikerUrl + "injective/"
    var relayerImgUrl = RelayerUrl + "injective/relay-injective-unknown.png"
    var priceUrl = CoingeckoUrl + "injective-protocol"
    
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
        return "https://injectiveprotocol.com/"
    }

    func getInfoLink2() -> String {
        return "https://blog.injectiveprotocol.com/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
