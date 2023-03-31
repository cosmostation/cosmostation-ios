//
//  ChainBitsong.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBitsong: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.BITSONG_MAIN
    var chainImg = UIImage(named: "chainBitsong")
    var chainInfoImg = UIImage(named: "infoBitsong")
    var chainInfoTitle = "BITSONG"
    var chainInfoMsg = NSLocalizedString("guide_msg_bitsong", comment: "")
    var chainColor = UIColor(named: "bitsong")!
    var chainColorBG = UIColor(named: "bitsong_bg")!
    var chainTitle = "(Bitsong Mainnet)"
    var chainTitle2 = "BITSONG"
    var chainDBName = CHAIN_BITSONG_S
    var chainAPIName = "bitsong"
    var chainKoreanName = "빗송"
    var chainIdPrefix = "bitsong-"
    
    var stakeDenomImg = UIImage(named: "tokenBitsong")
    var stakeDenom = "ubtsg"
    var stakeSymbol = "BTSG"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "bitsong")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "bitsong"
    var validatorPrefix = "bitsongvaloper"
    var defaultPath = "m/44'/639'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-bitsong.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "bitsong/"
    var priceUrl = GeckoUrl + "bitsong"
    
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
        return "http://bitsong.io/"
    }

    func getInfoLink2() -> String {
        return "https://bitsongofficial.medium.com/"
    }
}
