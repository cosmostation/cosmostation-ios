//
//  ChainAxelar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAxelar: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.AXELAR_MAIN
    var chainImg = UIImage(named: "chainAxelar")
    var chainInfoImg = UIImage(named: "infoAxelar")
    var chainInfoTitle = "AXELAR"
    var chainInfoMsg = NSLocalizedString("guide_msg_axelar", comment: "")
    var chainColor = UIColor(named: "axelar")!
    var chainColorBG = UIColor(named: "axelar_bg")!
    var chainTitle = "(Axelar Mainnet)"
    var chainTitle2 = "AXELAR"
    var chainDBName = CHAIN_AXELAR_S
    var chainAPIName = "axelar"
    var chainKoreanName = "악셀라"
    var chainIdPrefix = "axelar-"
    
    var stakeDenomImg = UIImage(named: "tokenAxelar")
    var stakeDenom = "uaxl"
    var stakeSymbol = "AXL"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "axelar")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "axelar"
    var validatorPrefix = "axelarvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-axelar.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "axelar/"
    var priceUrl = GeckoUrl + "axelar-network"
    
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
        return "https://axelar.network/"
    }

    func getInfoLink2() -> String {
        return "https://axelar.network/blog"
    }
}
