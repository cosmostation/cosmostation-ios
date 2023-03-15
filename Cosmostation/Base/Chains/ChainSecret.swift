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
    var chainImg = UIImage(named: "chainSecret")
    var chainInfoImg = UIImage(named: "infoSecret")
    var chainInfoTitle = "SECRET"
    var chainInfoMsg = NSLocalizedString("guide_msg_secret", comment: "")
    var chainColor = UIColor(named: "secret")!
    var chainColorBG = UIColor(named: "secret_bg")!
    var chainTitle = "(Secret Mainnet)"
    var chainTitle2 = "SECRET"
    var chainDBName = CHAIN_SECRET_S
    var chainAPIName = "secret"
    var chainKoreanName = "시크릿"
    var chainIdPrefix = "secret-"
    
    var stakeDenomImg = UIImage(named: "tokenSecret")
    var stakeDenom = "uscrt"
    var stakeSymbol = "SCRT"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "secret")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "secret"
    var validatorPrefix = "secretvaloper"
    let addressHdPath = "m/44'/118'/0'/0/X"
    var defaultPath = "m/44'/529'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-secret.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-secret.cosmostation.io/"
    var explorerUrl = MintscanUrl + "secret/"
    var priceUrl = GeckoUrl + "secret"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath, defaultPath]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://scrt.network"
    }

    func getInfoLink2() -> String {
        return "https://blog.scrt.network"
    }
}
