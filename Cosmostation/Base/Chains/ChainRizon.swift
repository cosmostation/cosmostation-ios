//
//  ChainRizon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainRizon: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.RIZON_MAIN
    var chainImg = UIImage(named: "chainRizon")
    var chainInfoImg = UIImage(named: "infoRizon")
    var chainInfoTitle = NSLocalizedString("send_guide_title_rizon", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_rizon", comment: "")
    var chainColor = UIColor(named: "rizon")!
    var chainColorBG = UIColor(named: "rizon_bg")!
    var chainTitle = "(Rizon Mainnet)"
    var chainTitle2 = "RIZON"
    var chainDBName = "SUPPORT_CHAIN_RIZON"
    var chainAPIName = "rizon"
    
    var stakeDenomImg = UIImage(named: "tokenRizon")
    var stakeDenom = "uatolo"
    var stakeSymbol = "ATOLO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "rizon")!
    
    var addressPrefix = "rizon"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var wcSupoort = false
    var grpcUrl = "lcd-rizon-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-rizon-app.cosmostation.io"
    var apiUrl = "https://api-rizon.cosmostation.io/"
    var explorerUrl = MintscanUrl + "rizon/"
    var validatorImgUrl = MonikerUrl + "rizon/"
    var relayerImgUrl = RelayerUrl + "rizon/relay-rizon-unknown.png"
    var priceUrl = CoingeckoUrl + "rizon"
    
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
        return "https://rizon.world/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/@hdac-rizon"
    }
}
