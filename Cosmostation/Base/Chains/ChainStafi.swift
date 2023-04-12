//
//  ChainStafi.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/04/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainStafi: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.SOMMELIER_MAIN
    var chainImg = UIImage(named: "chainStafi")
    var chainInfoImg = UIImage(named: "infoStafi")
    var chainInfoTitle = "STAFI HUB"
    var chainInfoMsg = NSLocalizedString("guide_msg_stafi", comment: "")
    var chainColor = UIColor(named: "stafi")!
    var chainColorBG = UIColor(named: "stafi_bg")!
    var chainTitle = "(STAFI Mainnet)"
    var chainTitle2 = "STAFI"
    var chainDBName = CHAIN_STAFI_S
    var chainAPIName = "stafi"
    var chainKoreanName = "스테파이"
    var chainIdPrefix = "stafihub-"
    
    var stakeDenomImg = UIImage(named: "tokenStafi")
    var stakeDenom = "ufis"
    var stakeSymbol = "FIS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "stafi")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "stafi"
    var validatorPrefix = "sommvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-stafi.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "stafi/"
    var priceUrl = GeckoUrl + "stafi"
    
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
        return "https://www.stafihub.io/"
    }

    func getInfoLink2() -> String {
        return "https://stafi-protocol.medium.com/"
    }
}

