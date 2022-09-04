//
//  ChainNyx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainNyx: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.NYX_MAIN
    var chainImg = UIImage(named: "chainNyx")
    var chainInfoImg = UIImage(named: "infoNyx")
    var chainInfoTitle = NSLocalizedString("send_guide_title_nyx", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_nyx", comment: "")
    var chainColor = UIColor(named: "nyx")!
    var chainColorBG = UIColor(named: "nyx_bg")!
    var chainTitle = "(Nyx Mainnet)"
    var chainTitle2 = "NYX"
    var chainDBName = CHAIN_NYX_S
    var chainAPIName = "nyx"
    var chainIdPrefix = "nyx"
    
    var stakeDenomImg = UIImage(named: "tokenNyx")
    var stakeDenom = "unyx"
    var stakeSymbol = "NYX"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "nyx")!
    
    var addressPrefix = "n"
    var validatorPrefix = "nvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.025unym"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-nym-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-nym-app.cosmostation.io/"
    var apiUrl = "https://api-nym.cosmostation.io/"
    var explorerUrl = MintscanUrl + "nyx/"
    var validatorImgUrl = MonikerUrl + "nyx/"
    var relayerImgUrl = RelayerUrl + "nyx/relay-nyx-unknown.png"
    var priceUrl = ""
    
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
        return "https://nymtech.net/"
    }

    func getInfoLink2() -> String {
        return "https://nymtech.net/blog/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

let NYX_NYM_DENOM = "unym"
