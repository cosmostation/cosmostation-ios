//
//  ChainCudos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/07.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCudos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CUDOS_MAIN
    var chainImg = UIImage(named: "chainCudos")
    var chainInfoImg = UIImage(named: "infoCudos")
    var chainInfoTitle = NSLocalizedString("send_guide_title_cudos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_cudos", comment: "")
    var chainColor = UIColor(named: "cudos")!
    var chainColorBG = UIColor(named: "cudos_bg")!
    var chainTitle = "(Cudos Mainnet)"
    var chainTitle2 = "CUDOS"
    var chainDBName = CHAIN_CUDOS_S
    var chainAPIName = "cudos"
    var chainIdPrefix = "cudos-"
    
    var stakeDenomImg = UIImage(named: "tokenCudos")
    var stakeDenom = "acudos"
    var stakeSymbol = "CUDOS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cudos")!
    
    var addressPrefix = "cudos"
    var validatorPrefix = "cudosvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "5000000000000acudos"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-cudos-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-cudos-app.cosmostation.io/"
    var apiUrl = "https://api-cudos.cosmostation.io/"
    var explorerUrl = MintscanUrl + "cudos/"
    var validatorImgUrl = MonikerUrl + "cudos/"
    var priceUrl = CoingeckoUrl + "cudos"
    
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
        return "https://www.cudos.org/"
    }

    func getInfoLink2() -> String {
        return "https://www.cudos.org/blog/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
