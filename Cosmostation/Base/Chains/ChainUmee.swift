//
//  ChainUmee.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainUmee: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.UMEE_MAIN
    var chainImg = UIImage(named: "chainUmee")
    var chainInfoImg = UIImage(named: "infoUmee")
    var chainInfoTitle = NSLocalizedString("send_guide_title_umee", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_umee", comment: "")
    var chainColor = UIColor(named: "umee")!
    var chainColorBG = UIColor(named: "umee_bg")!
    var chainTitle = "(Umee Mainnet)"
    var chainTitle2 = "UMEE"
    var chainDBName = "SUPPORT_CHAIN_UMEE"
    var chainAPIName = "umee"
    
    var stakeDenomImg = UIImage(named: "tokenUmee")
    var stakeDenom = "uumee"
    var stakeSymbol = "UMEE"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "umee")!
    
    var addressPrefix = "umee"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-umee-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-umee-app.cosmostation.io"
    var apiUrl = "https://api-umee.cosmostation.io/"
    var explorerUrl = MintscanUrl + "umee/"
    var validatorImgUrl = MonikerUrl + "umee/"
    var relayerImgUrl = RelayerUrl + "umee/relay-umee-unknown.png"
    var priceUrl = CoingeckoUrl + "umee"
    
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
        return "https://www.umee.cc/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/umeeblog"
    }
}
