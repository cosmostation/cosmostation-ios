//
//  ChainKonstellation.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKonstellation: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KONSTELLATION_MAIN
    var chainImg = UIImage(named: "chainKonstellation")
    var chainInfoImg = UIImage(named: "infoKonstellation")
    var chainInfoTitle = "KONSTELLATION"
    var chainInfoMsg = NSLocalizedString("guide_msg_konstellation", comment: "")
    var chainColor = UIColor(named: "konstellation")!
    var chainColorBG = UIColor(named: "konstellation_bg")!
    var chainTitle = "(Konstellation Mainnet)"
    var chainTitle2 = "KONSTELLATION"
    var chainDBName = CHAIN_KONSTELLATION_S
    var chainAPIName = "konstellation"
    var chainKoreanName = "콘스텔레이션"
    var chainIdPrefix = "darchub"
    
    var stakeDenomImg = UIImage(named: "tokenKonstellation")
    var stakeDenom = "udarc"
    var stakeSymbol = "DARC"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor.init(hexString: "122951")
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "darc"
    var validatorPrefix = "darcvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-konstellation.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "konstellation/"
    var priceUrl = GeckoUrl + "konstellation"
    
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
        return "https://konstellation.tech/"
    }

    func getInfoLink2() -> String {
        return "https://konstellation.medium.com/"
    }
}
