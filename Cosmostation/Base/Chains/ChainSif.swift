//
//  ChainSif.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSif: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SIF_MAIN
    var chainImg = UIImage(named: "chainSif")
    var chainInfoImg = UIImage(named: "infoSif")
    var chainInfoTitle = "SIF"
    var chainInfoMsg = NSLocalizedString("guide_msg_sif", comment: "")
    var chainColor = UIColor(named: "sif")!
    var chainColorBG = UIColor(named: "sif_bg")!
    var chainTitle = "(SifChain Mainnet)"
    var chainTitle2 = "SIF"
    var chainDBName = CHAIN_SIF_S
    var chainAPIName = "sifchain"
    var chainKoreanName = "시프"
    var chainIdPrefix = "sifchain-"
    
    var stakeDenomImg = UIImage(named: "tokenSif")
    var stakeDenom = "rowan"
    var stakeSymbol = "ROWAN"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "sif")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "sif"
    var validatorPrefix = "sifvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-sifchain.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "sifchain/"
    var priceUrl = GeckoUrl + "sifchain"
    
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
        return "https://sifchain.finance/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/sifchain-finance"
    }
}

let SIF_MAIN_DENOM = "rowan"
