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
    var chainType = ChainType.PASSAGE_MAIN
    var chainImg = UIImage(named: "chainPassage")
    var chainInfoImg = UIImage(named: "infoPassage")
    var chainInfoTitle = "PASSAGE"
    var chainInfoMsg = NSLocalizedString("guide_msg_passage", comment: "")
    var chainColor = UIColor(named: "passage")!
    var chainColorBG = UIColor(named: "passage_bg")!
    var chainTitle = "(Passage Mainnet)"
    var chainTitle2 = "PASSAGE"
    var chainDBName = CHAIN_PASSAGE_S
    var chainAPIName = "passage"
    var chainKoreanName = "파사지"
    var chainIdPrefix = "passage-"
    
    var stakeDenomImg = UIImage(named: "tokenPassage")
    var stakeDenom = "upasg"
    var stakeSymbol = "PASG"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "passage")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "pasg"
    var validatorPrefix = "pasgvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-passage.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-passage-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "passage/"
    var priceUrl = ""
    
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
        return "https://passage3d.com"
    }

    func getInfoLink2() -> String {
        return "https://passage3d.com"
    }
}

