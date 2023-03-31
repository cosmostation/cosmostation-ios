//
//  ChainNoble.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/03/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainNoble: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.NOBLE_MAIN
    var chainImg = UIImage(named: "chainNoble")
    var chainInfoImg = UIImage(named: "infoNoble")
    var chainInfoTitle = "NOBLE"
    var chainInfoMsg = NSLocalizedString("guide_msg_noble", comment: "")
    var chainColor = UIColor(named: "noble")!
    var chainColorBG = UIColor(named: "noble_bg")!
    var chainTitle = "(Noble Mainnet)"
    var chainTitle2 = "NOBLE"
    var chainDBName = CHAIN_NOBLE_S
    var chainAPIName = "noble"
    var chainKoreanName = "노블"
    var chainIdPrefix = "noble"
    
    var stakeDenomImg = UIImage(named: "tokenNoble")
    var stakeDenom = "ustake"
    var stakeSymbol = "Noble"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "noble")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "noble"
    var validatorPrefix = "noblevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-noble.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "noble/"
    var priceUrl = ""
    
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
        return "https://nobleassets.xyz/"
    }

    func getInfoLink2() -> String {
        return "https://mirror.xyz/nobleassets.eth/"
    }
}
