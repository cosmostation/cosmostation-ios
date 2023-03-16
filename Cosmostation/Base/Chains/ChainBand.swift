//
//  ChainBand.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBand: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.BAND_MAIN
    var chainImg = UIImage(named: "chainBand")
    var chainInfoImg = UIImage(named: "infoBand")
    var chainInfoTitle = "BAND"
    var chainInfoMsg = NSLocalizedString("guide_msg_band", comment: "")
    var chainColor = UIColor(named: "band")!
    var chainColorBG = UIColor(named: "band_bg")!
    var chainTitle = "(Band Mainnet)"
    var chainTitle2 = "BAND"
    var chainDBName = CHAIN_BAND_S
    var chainAPIName = "band"
    var chainKoreanName = "밴드"
    var chainIdPrefix = "laozi-mainnet"
    
    var stakeDenomImg = UIImage(named: "tokenBand")
    var stakeDenom = "uband"
    var stakeSymbol = "BAND"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "band")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "band"
    var validatorPrefix = "bandvaloper"
    var defaultPath = "m/44'/494'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-band.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-band-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "band/"
    var priceUrl = GeckoUrl + "band-protocol"
    
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
        return "https://bandprotocol.com/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/bandprotocol"
    }
}
