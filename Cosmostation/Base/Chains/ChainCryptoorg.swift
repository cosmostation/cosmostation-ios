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
    var chainImg = UIImage(named: "chaincrypto")
    var chainInfoImg = UIImage(named: "cryptochainImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_crypto", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_crypto", comment: "")
    var chainColor = UIColor(named: "cryptoorg")!
    var chainColorDark = UIColor(named: "cryptoorg_dark")
    var chainColorBG = UIColor(named: "cryptoorg")!.withAlphaComponent(0.15)
    var chainTitle = "(Crypto.org Mainnet)"
    var chainTitle2 = "CRYPTO.ORG"
    var chainDBName = "SUPPORT_CHAIN_CRYTO_MAIN"
    var chainAPIName = "cryptoorg"
    
    var stakeDenomImg = UIImage(named: "tokencrypto")
    var stakeDenom = "basecro"
    var stakeSymbol = "CRO"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "cryptoorg_dark")!
    
    var addressPrefix = "cro"
    let addressHdPath0 = "m/44'/394'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-cryptocom-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-cryptocom-app.cosmostation.io"
    var apiUrl = "https://api-cryptocom.cosmostation.io/"
    var explorerUrl = MintscanUrl + "crypto-org/"
    var validatorImgUrl = MonikerUrl + "cryto/"
    var relayerImgUrl = RelayerUrl + "cryptoorg/relay-cryptoorg-unknown.png"
    
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
