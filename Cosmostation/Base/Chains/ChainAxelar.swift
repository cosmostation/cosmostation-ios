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
    var chainInfoTitle = NSLocalizedString("send_guide_title_axelar", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_axelar", comment: "")
    var chainColor = UIColor(named: "axelar")!
    var chainColorBG = UIColor(named: "axelar_bg")!
    
    var chainTitle = "(Axelar Mainnet)"
    var chainTitle2 = "AXELAR"
    var chainDBName = "SUPPORT_CHAIN_AXELAR"
    var chainAPIName = "axelar"
    
    var stakeDenomImg = UIImage(named: "tokenAxelar")
    var stakeDenom = "uaxl"
    var stakeSymbol = "AXL"
    var stakeSendImg = UIImage(named: "btnSendAlthea")!
    var stakeSendBg = UIColor.white
    
    var addressPrefix = "axelar"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-axelar-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-axelar-app.cosmostation.io"
    var apiUrl = "https://api-axelar.cosmostation.io/"
    var explorerUrl = MintscanUrl + "axelar/"
    var validatorImgUrl = MonikerUrl + "axelar/"
    var relayerImgUrl = RelayerUrl + "axelar/relay-axelar-unknown.png"
    var priceUrl = CoingeckoUrl + "axelar-network"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
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
