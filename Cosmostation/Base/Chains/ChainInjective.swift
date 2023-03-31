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
    var chainInfoTitle = "INJECTIVE"
    var chainInfoMsg = NSLocalizedString("guide_msg_injective", comment: "")
    var chainColor = UIColor(named: "injective")!
    var chainColorBG = UIColor(named: "injective_bg")!
    var chainTitle = "(Injective Mainnet)"
    var chainTitle2 = "INJECTIVE"
    var chainDBName = CHAIN_INJECTIVE_S
    var chainAPIName = "injective"
    var chainKoreanName = "인젝티브"
    var chainIdPrefix = "injective-"
    
    var stakeDenomImg = UIImage(named: "tokenInjective")
    var stakeDenom = "inj"
    var stakeSymbol = "INJ"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "injective")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "inj"
    var validatorPrefix = "injvaloper"
    var defaultPath = "m/44'/60'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = true
    var grpcUrl = "grpc-injective.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "injective/"
    var priceUrl = GeckoUrl + "injective-protocol"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath]
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
}
