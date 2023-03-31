//
//  ChainBitcana.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBitcana: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.BITCANA_MAIN
    var chainImg = UIImage(named: "chainBitcanna")
    var chainInfoImg = UIImage(named: "infoBitcanna")
    var chainInfoTitle = "BITCANNA"
    var chainInfoMsg = NSLocalizedString("guide_msg_bitcanna", comment: "")
    var chainColor = UIColor(named: "bitcanna")!
    var chainColorBG = UIColor(named: "bitcanna_bg")!
    var chainTitle = "(Bitcanna Mainnet)"
    var chainTitle2 = "BITCANNA"
    var chainDBName = CHAIN_BITCANA_S
    var chainAPIName = "bitcanna"
    var chainKoreanName = "비트카나"
    var chainIdPrefix = "bitcanna-"
    
    var stakeDenomImg = UIImage(named: "tokenBitcanna")
    var stakeDenom = "ubcna"
    var stakeSymbol = "BCNA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "bitcanna")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "bcna"
    var validatorPrefix = "bcnavaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-bitcanna.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "bitcanna/"
    var priceUrl = GeckoUrl + "bitcanna"
    
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
        return "https://www.bitcanna.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@BitCannaGlobal"
    }
}

