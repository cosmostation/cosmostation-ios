//
//  ChainIris.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainIris: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.IRIS_MAIN
    var chainImg = UIImage(named: "chainIris")
    var chainInfoImg = UIImage(named: "infoIris")
    var chainInfoTitle = NSLocalizedString("send_guide_title_iris", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_iris", comment: "")
    var chainColor = UIColor(named: "iris")!
    var chainColorBG = UIColor(named: "iris_bg")!
    var chainTitle = "(Iris Mainnet)"
    var chainTitle2 = "IRIS"
    var chainDBName = CHAIN_IRIS_S
    var chainAPIName = "iris"
    var chainIdPrefix = "irishub-"
    
    var stakeDenomImg = UIImage(named: "tokenIris")
    var stakeDenom = "uiris"
    var stakeSymbol = "IRIS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "iris")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "iaa"
    var validatorPrefix = "iva"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.002uiris"
    let gasRate1 = "0.02uiris"
    let gasRate2 = "0.2uiris"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-iris-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-iris-app.cosmostation.io/"
    var apiUrl = "https://api-iris.cosmostation.io/"
    var explorerUrl = MintscanUrl + "iris/"
    var validatorImgUrl = MonikerUrl + "irishub/"
    var priceUrl = CoingeckoUrl + "irisnet"
    
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
        return "https://www.irisnet.org"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/irisnet-blog"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 1
    }
}
