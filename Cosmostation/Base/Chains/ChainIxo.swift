//
//  ChainIxo.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/05.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainIxo: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.IXO_MAIN
    var chainImg = UIImage(named: "chainIxo")
    var chainInfoImg = UIImage(named: "infoIxo")
    var chainInfoTitle = NSLocalizedString("guide_title_ixo", comment: "")
    var chainInfoMsg = NSLocalizedString("guide_msg_ixo", comment: "")
    var chainColor = UIColor(named: "ixo")!
    var chainColorBG = UIColor(named: "ixo_bg")!
    var chainTitle = "(Ixo Mainnet)"
    var chainTitle2 = "IXO"
    var chainDBName = CHAIN_IXO_S
    var chainAPIName = "ixo"
    var chainIdPrefix = "impacthub-"
    
    
    var stakeDenomImg = UIImage(named: "tokenIxo")
    var stakeDenom = "uixo"
    var stakeSymbol = "IXO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "ixo")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "ixo"
    var validatorPrefix = "ixovaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.025uixo"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var grpcUrl = "lcd-ixo-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-ixo-app.cosmostation.io/"
    var apiUrl = "https://api-ixo.cosmostation.io/"
    var explorerUrl = MintscanUrl + "ixo/"
    var validatorImgUrl = MonikerUrl + "ixo/"
    var priceUrl = CoingeckoUrl + "ixo"
    
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
        return "https://www.ixo.world/"
    }

    func getInfoLink2() -> String {
        return "https://earthstate.ixo.world/"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
