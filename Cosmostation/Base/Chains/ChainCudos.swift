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
    var chainInfoTitle = "CUDOS"
    var chainInfoMsg = NSLocalizedString("guide_msg_cudos", comment: "")
    var chainColor = UIColor(named: "cudos")!
    var chainColorBG = UIColor(named: "cudos_bg")!
    var chainTitle = "(Cudos Mainnet)"
    var chainTitle2 = "CUDOS"
    var chainDBName = CHAIN_CUDOS_S
    var chainAPIName = "cudos"
    var chainKoreanName = "쿠도스"
    var chainIdPrefix = "cudos-"
    
    var stakeDenomImg = UIImage(named: "tokenCudos")
    var stakeDenom = "acudos"
    var stakeSymbol = "CUDOS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "cudos")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "cudos"
    var validatorPrefix = "cudosvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-cudos.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "cudos/"
    var priceUrl = GeckoUrl + "cudos"
    
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
        return "https://www.cudos.org/"
    }

    func getInfoLink2() -> String {
        return "https://www.cudos.org/blog/"
    }
}
