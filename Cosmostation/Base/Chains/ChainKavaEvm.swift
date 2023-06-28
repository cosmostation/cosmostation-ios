//
//  ChainKavaEvm.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/06/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKavaEvm: ChainConfig {
    var isGrpc = false
    var chainType = ChainType.KAVA_MAIN
    var chainImg = UIImage(named: "chainKava")
    var chainInfoImg = UIImage(named: "infoKava")
    var chainInfoTitle = "KAVA"
    var chainInfoMsg = NSLocalizedString("guide_msg_kava", comment: "")
    var chainColor = UIColor(named: "kava")!
    var chainColorBG = UIColor(named: "kava_bg")!
    var chainTitle = "(Kava Mainnet)"
    var chainTitle2 = "KAVA"
    var chainDBName = CHAIN_KAVA_EVM_S
    var chainAPIName = "kava"
    var chainKoreanName = "카바"
    var chainIdPrefix = "kava_"
    
    var stakeDenomImg = UIImage(named: "tokenKava")
    var stakeDenom = "ukava"
    var stakeSymbol = "KAVA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "kava")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = ""
    var validatorPrefix = ""
    var defaultPath = "m/44'/60'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = true
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = ""
    var grpcPort = 0
    var rpcUrl = "https://rpc-kava-app.cosmostation.io/"
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "kava/"
    var priceUrl = GeckoUrl + "kava"
    
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
        return "https://www.kava.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/kava-labs"
    }
}

let KAVA_GECKO_ID = "kava"
