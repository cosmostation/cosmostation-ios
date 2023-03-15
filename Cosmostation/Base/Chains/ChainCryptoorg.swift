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
    var chainInfoTitle = "CRYPTO.ORG"
    var chainInfoMsg = NSLocalizedString("guide_msg_crypto", comment: "")
    var chainColor = UIColor(named: "cryptoorg")!
    var chainColorBG = UIColor(named: "cryptoorg_bg")!
    var chainTitle = "(Crypto.org Mainnet)"
    var chainTitle2 = "CRYPTO.ORG"
    var chainDBName = CHAIN_CRYPTO_S
    var chainAPIName = "crypto-org"
    var chainKoreanName = "크립토오알지"
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
    var defaultPath = "m/44'/394'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-crypto-org.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-crypto-org-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "crypto-org/"
    var priceUrl = GeckoUrl + "cronos"
    
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
        return "https://crypto.org/"
    }

    func getInfoLink2() -> String {
        return "https://blog.crypto.com/"
    }
}
