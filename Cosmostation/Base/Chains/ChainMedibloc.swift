//
//  ChainMedibloc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainMedibloc: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.MEDI_MAIN
    var chainImg = UIImage(named: "chainMedibloc")
    var chainInfoImg = UIImage(named: "infoMedibloc")
    var chainInfoTitle = "MEDIBLOC"
    var chainInfoMsg = NSLocalizedString("guide_msg_medi", comment: "")
    var chainColor = UIColor(named: "medibloc")!
    var chainColorBG = UIColor(named: "medibloc_bg")!
    var chainTitle = "(Medibloc Mainnet)"
    var chainTitle2 = "MEDIBLOC"
    var chainDBName = CHAIN_MEDI_S
    var chainAPIName = "medibloc"
    var chainKoreanName = "메디블록"
    var chainIdPrefix = "panacea-"
    
    var stakeDenomImg = UIImage(named: "tokenMedibloc")
    var stakeDenom = "umed"
    var stakeSymbol = "MED"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "medibloc")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "panacea"
    var validatorPrefix = "panaceavaloper"
    var defaultPath = "m/44'/371'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-medibloc.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-medibloc-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "medibloc/"
    var priceUrl = GeckoUrl + "medibloc"
    
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
        if (Locale.current.languageCode == "ko") {
            return "https://medibloc.com"
        } else {
            return "https://medibloc.com/en/"
        }
    }

    func getInfoLink2() -> String {
        if (Locale.current.languageCode == "ko") {
            return "https://blog.medibloc.org/"
        } else {
            return "https://medium.com/medibloc/"
        }
    }
}
