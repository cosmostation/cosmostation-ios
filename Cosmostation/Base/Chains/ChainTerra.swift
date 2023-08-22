//
//  ChainTerra.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainTerra: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.TERRA_MAIN
    var chainImg = UIImage(named: "chainTerra")
    var chainInfoImg = UIImage(named: "infoTerra")
    var chainInfoTitle = "TERRA"
    var chainInfoMsg = NSLocalizedString("guide_msg_terra", comment: "")
    var chainColor = UIColor(named: "terra")!
    var chainColorBG = UIColor(named: "terra_bg")!
    var chainTitle = "(TERRA Mainnet)"
    var chainTitle2 = "TERRA"
    var chainDBName = CHAIN_TERRA_S
    var chainAPIName = "terra"
    var chainKoreanName = "테라"
    var chainIdPrefix = "phoenix-"
    
    var stakeDenomImg = UIImage(named: "tokenTerra")
    var stakeDenom = "uluna"
    var stakeSymbol = "LUNA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "terra")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "terra"
    var validatorPrefix = "terravaloper"
    var defaultPath = "m/44'/330'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = true
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-terra.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "terra/"
    var priceUrl = GeckoUrl + "terra"
    
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
        return ""
    }

    func getInfoLink2() -> String {
        return "https://medium.com/terra-money/"
    }
}


