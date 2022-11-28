//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKava: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KAVA_MAIN
    var chainImg = UIImage(named: "chainKava")
    var chainInfoImg = UIImage(named: "infoKava")
    var chainInfoTitle = NSLocalizedString("guide_title_kava", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_kava", comment: "")
    var chainColor = UIColor(named: "kava")!
    var chainColorBG = UIColor(named: "kava_bg")!
    var chainTitle = "(Kava Mainnet)"
    var chainTitle2 = "KAVA"
    var chainDBName = CHAIN_KAVA_S
    var chainAPIName = "kava"
    var chainIdPrefix = "kava_"
    
    var stakeDenomImg = UIImage(named: "tokenKava")
    var stakeDenom = "ukava"
    var stakeSymbol = "KAVA"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "kava")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "kava"
    var validatorPrefix = "kavavaloper"
    let addressHdPath = "m/44'/118'/0'/0/X"
    var defaultPath = "m/44'/459'/0'/0/X"
    
    var etherAddressSupport = true
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var moonPaySupoort = true
    var kadoMoneySupoort = false
    var grpcUrl = "lcd-kava-app.cosmostation.io"
    var grpcPort = 9090
    var rpcUrl = ""
    var lcdUrl = "https://lcd-kava-app.cosmostation.io/"
    var apiUrl = "https://api-kava.cosmostation.io/"
    var explorerUrl = MintscanUrl + "kava/"
    var validatorImgUrl = MonikerUrl + "kava/"
    var priceUrl = CoingeckoUrl + "kava"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath, defaultPath]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://www.kava.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/kava-labs"
    }
}

let KAVA_MAIN_DENOM = "ukava"
let KAVA_HARD_DENOM = "hard"
let KAVA_USDX_DENOM = "usdx"
let KAVA_SWAP_DENOM = "swp"

let KAVA_CDP_IMG_URL        = ResourceBase + "kava/cdp/";
let KAVA_HARD_POOL_IMG_URL  = ResourceBase + "kava/hard/";
let KAVA_COIN_IMG_URL       = ResourceBase + "coin_image/kava/";
