//
//  ChainCryptoorg.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCryptoorg: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CRYPTO_MAIN
    var chainImg = UIImage(named: "chainCryptoorg")
    var chainInfoImg = UIImage(named: "infoCryptoorg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_crypto", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_crypto", comment: "")
    var chainColor = UIColor(named: "cryptoorg")!
    var chainColorBG = UIColor(named: "cryptoorg_bg")!
    var chainTitle = "(Crypto.org Mainnet)"
    var chainTitle2 = "CRYPTO.ORG"
    var chainDBName = CHAIN_CRYPTO_S
    var chainAPIName = "cryptoorg"
    var chainIdPrefix = "crypto-org-"
    
    var stakeDenomImg = UIImage(named: "tokenCryptoorg")
    var stakeDenom = "basecro"
    var stakeSymbol = "CRO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cryptoorg")!
    var divideDecimal: Int16 = 8
    var displayDecimal: Int16 = 8
    
    var addressPrefix = "cro"
    var validatorPrefix = "crocncl"
    let addressHdPath0 = "m/44'/394'/0'/0/X"
    
    let gasRate0 = "0.025basecro"
    let gasRate1 = "0.05basecro"
    let gasRate2 = "0.075basecro"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-cryptocom-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-cryptocom-app.cosmostation.io/"
    var apiUrl = "https://api-cryptocom.cosmostation.io/"
    var explorerUrl = MintscanUrl + "crypto-org/"
    var validatorImgUrl = MonikerUrl + "cryto/"
    var priceUrl = CoingeckoUrl + "cronos"
    
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
        return "https://crypto.org/"
    }

    func getInfoLink2() -> String {
        return "https://blog.crypto.com/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
