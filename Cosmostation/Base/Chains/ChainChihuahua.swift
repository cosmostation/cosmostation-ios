//
//  ChainChihuahua.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainChihuahua: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CHIHUAHUA_MAIN
    var chainImg = UIImage(named: "chainChihuahua")
    var chainInfoImg = UIImage(named: "infoChihuahua")
    var chainInfoTitle = "CHIHUAHUA"
    var chainInfoMsg = NSLocalizedString("guide_msg_chihuahua", comment: "")
    var chainColor = UIColor(named: "chihuahua")!
    var chainColorBG = UIColor(named: "chihuahua_bg")!
    var chainTitle = "(Chihuahua Mainnet)"
    var chainTitle2 = "CHIHUAHUA"
    var chainDBName = CHAIN_CHIHUAHUA_S
    var chainAPIName = "chihuahua"
    var chainKoreanName = "치와와"
    var chainIdPrefix = "chihuahua-"
    
    var stakeDenomImg = UIImage(named: "tokenChihuahua")
    var stakeDenom = "uhuahua"
    var stakeSymbol = "HUAHUA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "chihuahua")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "chihuahua"
    var validatorPrefix = "chihuahuavaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-chihuahua.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "chihuahua/"
    var priceUrl = GeckoUrl + "chihuahua-chain"
    
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
        return "https://chi.huahua.wtf/"
    }

    func getInfoLink2() -> String {
        return "https://chihuahuachain.medium.com/"
    }
}
