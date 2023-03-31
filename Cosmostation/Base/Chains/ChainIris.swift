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
    var chainInfoTitle = "IRIS"
    var chainInfoMsg = NSLocalizedString("guide_msg_iris", comment: "")
    var chainColor = UIColor(named: "iris")!
    var chainColorBG = UIColor(named: "iris_bg")!
    var chainTitle = "(Iris Mainnet)"
    var chainTitle2 = "IRIS"
    var chainDBName = CHAIN_IRIS_S
    var chainAPIName = "iris"
    var chainKoreanName = "아이리스"
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
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-iris.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "iris/"
    var priceUrl = GeckoUrl + "irisnet"
    
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
        return "https://www.irisnet.org"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/irisnet-blog"
    }
}
