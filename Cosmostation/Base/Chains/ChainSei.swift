//
//  ChainSei.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSei: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SEI_MAIN
    var chainImg = UIImage(named: "chainSei")
    var chainInfoImg = UIImage(named: "infoSei")
    var chainInfoTitle = "SEI"
    var chainInfoMsg = NSLocalizedString("guide_msg_sei", comment: "")
    var chainColor = UIColor(named: "sei")!
    var chainColorBG = UIColor(named: "sei_bg")!
    var chainTitle = "(Sei Mainnet)"
    var chainTitle2 = "SEI"
    var chainDBName = CHAIN_SEI_S
    var chainAPIName = "sei"
    var chainKoreanName = "세이"
    var chainIdPrefix = "pacific-"
    
    var stakeDenomImg = UIImage(named: "tokenSei")
    var stakeDenom = "usei"
    var stakeSymbol = "SEI"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "sei")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "sei"
    var validatorPrefix = "seivaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-sei.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "sei/"
    var priceUrl = GeckoUrl + "sei-network"
    
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
        return "https://www.sei.io/"
    }

    func getInfoLink2() -> String {
        return "https://blog.sei.io/"
    }
}
