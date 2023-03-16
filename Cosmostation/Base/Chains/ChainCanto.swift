//
//  ChainCanto.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/08.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import UIKit

class ChainCanto: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.CANTO_MAIN
    var chainImg = UIImage(named: "chainCanto")
    var chainInfoImg = UIImage(named: "infoCanto")
    var chainInfoTitle = "Canto"
    var chainInfoMsg = NSLocalizedString("guide_msg_canto", comment: "")
    var chainColor = UIColor(named: "canto")!
    var chainColorBG = UIColor(named: "canto_bg")!
    var chainTitle = "(Canto Mainnet)"
    var chainTitle2 = "CANTO"
    var chainDBName = CHAIN_CANTO_S
    var chainAPIName = "canto"
    var chainKoreanName = "칸토"
    var chainIdPrefix = "canto_"
    
    var stakeDenomImg = UIImage(named: "tokenCanto")
    var stakeDenom = "acanto"
    var stakeSymbol = "CANTO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "canto")!
    var divideDecimal: Int16 = 18
    var displayDecimal: Int16 = 18
    
    var addressPrefix = "canto"
    var validatorPrefix = "cantovaloper"
    var defaultPath = "m/44'/60'/0'/0/X"
    
    var etherAddressSupport = true
    var wasmSupport = false
    var evmSupport = true
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-canto.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = "https://rpc-canto-app.cosmostation.io"
    var lcdUrl = "https://lcd-canto-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "canto/"
    var priceUrl = GeckoUrl + "canto"
    
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
        return "https://canto.io/"
    }

    func getInfoLink2() -> String {
        return "https://canto.mirror.xyz/"
    }
}
