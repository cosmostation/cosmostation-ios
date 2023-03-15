//
//  ChainOmiflix.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOmniflix: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.OMNIFLIX_MAIN
    var chainImg = UIImage(named: "chainOmniflix")
    var chainInfoImg = UIImage(named: "infoOmniflix")
    var chainInfoTitle = "OMNIFLIX"
    var chainInfoMsg = NSLocalizedString("guide_msg_omniflix", comment: "")
    var chainColor = UIColor(named: "omniflix")!
    var chainColorBG = UIColor(named: "omniflix_bg")!
    var chainTitle = "(Omniflix Mainnet)"
    var chainTitle2 = "OMNIFLIX"
    var chainDBName = CHAIN_OMNIFLIX_S
    var chainAPIName = "omniflix"
    var chainKoreanName = "옴니플리스"
    var chainIdPrefix = "omniflixhub-"
    
    var stakeDenomImg = UIImage(named: "tokenOmniflix")
    var stakeDenom = "uflix"
    var stakeSymbol = "FLIX"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "omniflix")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "omniflix"
    var validatorPrefix = "omniflixvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-omniflix.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-omniflix-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "omniflix/"
    var priceUrl = GeckoUrl + "omniflix-network"
    
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
        return "https://www.omniflix.network/"
    }

    func getInfoLink2() -> String {
        return "https://blog.omniflix.network/"
    }
}

