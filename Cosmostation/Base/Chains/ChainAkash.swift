//
//  ChainAkash.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAkash: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.AKASH_MAIN
    var chainImg = UIImage(named: "chainAkash")
    var chainInfoImg = UIImage(named: "infoAkash")
    var chainInfoTitle = NSLocalizedString("send_guide_title_akash", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_akash", comment: "")
    var chainColor = UIColor(named: "akash")!
    var chainColorBG = UIColor(named: "akash_bg")!
    var chainTitle = "(Akash Mainnet)"
    var chainTitle2 = "AKASH"
    var chainDBName = "SUPPORT_CHAIN_AKASH_MAIN"
    var chainAPIName = "akash"
    
    var stakeDenomImg = UIImage(named: "tokenAkash")
    var stakeDenom = "uakt"
    var stakeSymbol = "AKT"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "akash")!
    
    var addressPrefix = "akash"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-akash-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-akash-app.cosmostation.io"
    var apiUrl = "https://api-akash.cosmostation.io/"
    var explorerUrl = MintscanUrl + "akash/"
    var validatorImgUrl = MonikerUrl + "akash/"
    var relayerImgUrl = RelayerUrl + "akash/relay-akash-unknown.png"
    var priceUrl = CoingeckoUrl + "akash-network"
    
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
        return "https://akash.network/"
    }

    func getInfoLink2() -> String {
        return "https://akash.network/blog/"
    }
}
