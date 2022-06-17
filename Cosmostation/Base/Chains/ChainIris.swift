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
    var chainDBName = "SUPPORT_CHAIN_IRIS_MAIN"
    var chainAPIName = "iris"
    
    var stakeDenomImg = UIImage(named: "tokenIris")
    var stakeDenom = "uiris"
    var stakeSymbol = "Iris"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "iris")!
    
    var addressPrefix = "iaa"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-iris-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-iris-app.cosmostation.io"
    var apiUrl = "https://api-iris.cosmostation.io/"
    var explorerUrl = MintscanUrl + "iris/"
    var validatorImgUrl = MonikerUrl + "irishub/"
    var relayerImgUrl = RelayerUrl + "iris/relay-iris-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
