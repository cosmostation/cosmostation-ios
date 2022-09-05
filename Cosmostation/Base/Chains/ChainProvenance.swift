//
//  ChainProvenance.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainProvenance: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.PROVENANCE_MAIN
    var chainImg = UIImage(named: "chainProvenance")
    var chainInfoImg = UIImage(named: "infoProvenance")
    var chainInfoTitle = NSLocalizedString("send_guide_title_provenance", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_provenance", comment: "")
    var chainColor = UIColor(named: "provenance")!
    var chainColorBG = UIColor(named: "provenance_bg")!
    var chainTitle = "(Provenance Mainnet)"
    var chainTitle2 = "PROVENANCE"
    var chainDBName = CHAIN_PROVENANCE_S
    var chainAPIName = "provenance"
    var chainIdPrefix = "pio-mainnet-"
    
    var stakeDenomImg = UIImage(named: "tokenProvenance")
    var stakeDenom = "nhash"
    var stakeSymbol = "HASH"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "provenance")!
    
    var addressPrefix = "pb"
    var validatorPrefix = "pbvaloper"
    let addressHdPath0 = "m/44'/505'/0'/0/X"
    
    let gasRate0 = "2000nhash"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-provenance-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-provenance-app.cosmostation.io/"
    var apiUrl = "https://api-provenance.cosmostation.io/"
    var explorerUrl = MintscanUrl + "provenance/"
    var validatorImgUrl = MonikerUrl + "provenance/"
    var priceUrl = CoingeckoUrl + "provenance-blockchain"
    
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
        return "https://www.provenance.io/"
    }

    func getInfoLink2() -> String {
        return "https://www.provenance.io/blog"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
