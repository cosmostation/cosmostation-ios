//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCosmos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.COSMOS_MAIN
    var chainImg = UIImage(named: "chainCosmos")
    var chainInfoImg = UIImage(named: "infoCosmos")
    var chainInfoTitle = "COSMOS HUB"
    var chainInfoMsg = NSLocalizedString("guide_msg_cosmos", comment: "")
    var chainColor = UIColor(named: "cosmos")!
    var chainColorBG = UIColor(named: "cosmos_bg")!
    var chainTitle = "(Cosmos Mainnet)"
    var chainTitle2 = "COSMOS"
    var chainDBName = CHAIN_COSMOS_S
    var chainAPIName = "cosmos"
    var chainKoreanName = "코스모스"
    var chainIdPrefix = "cosmoshub-"
    
    
    var stakeDenomImg = UIImage(named: "tokenCosmos")
    var stakeDenom = "uatom"
    var stakeSymbol = "ATOM"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cosmos")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "cosmos"
    var validatorPrefix = "cosmosvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var moonPaySupoort = true
    var kadoMoneySupoort = true
    var grpcUrl = "grpc-cosmos.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-cosmos-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "cosmos/"
    var priceUrl = GeckoUrl + "cosmos"
    
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
        return "https://cosmos.network/"
    }

    func getInfoLink2() -> String {
        return "https://blog.cosmos.network/"
    }
}
