//
//  ChainPassage.swift
//  Cosmostation
//
//  Created by 권혁준 on 2022/08/16.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainPassage: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.IRIS_MAIN
    var chainImg = UIImage(named: "chainPassage")
    var chainInfoImg = UIImage(named: "infoPassage")
    var chainInfoTitle = NSLocalizedString("send_guide_title_passage", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_passage", comment: "")
    var chainColor = UIColor(named: "passage")!
    var chainColorBG = UIColor(named: "passage_bg")!
    var chainTitle = "(Passage Mainnet)"
    var chainTitle2 = "PASSAGE"
    var chainDBName = CHAIN_PASSAGE_S
    var chainAPIName = "passage"
    var chainIdPrefix = "passage-"
    
    var stakeDenomImg = UIImage(named: "tokenPassage")
    var stakeDenom = "upasg"
    var stakeSymbol = "PASG"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "passage")!
    
    var addressPrefix = "pasg"
    var validatorPrefix = "pasgvaloper"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    let gasRate0 = "0.0upasg"
    
    var etherAddressSupport = false
    var pushSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var grpcUrl = "lcd-passage-app.cosmostation.io"
    var grpcPort = 9090
    var lcdUrl = "https://lcd-passage-app.cosmostation.io/"
    var apiUrl = "https://api-passage.cosmostation.io/"
    var explorerUrl = MintscanUrl + "passage/"
    var validatorImgUrl = MonikerUrl + "passage/"
    var relayerImgUrl = RelayerUrl + "passage/relay-passage-unknown.png"
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
        return "https://passage3d.com"
    }

    func getInfoLink2() -> String {
        return "https://passage3d.com"
    }
    
    func getGasRates() -> Array<String> {
        return [gasRate0]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}

