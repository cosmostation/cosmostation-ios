//
//  ChainAkash.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAkash: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.AKASH_MAIN
    var chainImg = UIImage(named: "chainAkash")
    var chainInfoImg = UIImage(named: "infoAkash")
    var chainInfoTitle = "AKASH"
    var chainInfoMsg = NSLocalizedString("guide_msg_akash", comment: "")
    var chainColor = UIColor(named: "akash")!
    var chainColorBG = UIColor(named: "akash_bg")!
    var chainTitle = "(Akash Mainnet)"
    var chainTitle2 = "AKASH"
    var chainDBName = CHAIN_AKASH_S
    var chainAPIName = "akash"
    var chainKoreanName = "아카시"
    var chainIdPrefix = "akashnet-"
    
    var stakeDenomImg = UIImage(named: "tokenAkash")
    var stakeDenom = "uakt"
    var stakeSymbol = "AKT"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "akash")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "akash"
    var validatorPrefix = "akashvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-akash.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-akash-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "akash/"
    var priceUrl = GeckoUrl + "akash-network"
    
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
        return "https://akash.network/"
    }

    func getInfoLink2() -> String {
        return "https://akash.network/blog/"
    }
}
