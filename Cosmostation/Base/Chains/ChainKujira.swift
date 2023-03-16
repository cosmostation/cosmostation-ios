//
//  ChainKujira.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/17.
//  Copyright © 2022 wannabit. All rights reserved.
//
import UIKit
import Foundation


class ChainKujira: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.KUJIRA_MAIN
    var chainImg = UIImage(named: "chainKujira")
    var chainInfoImg = UIImage(named: "infoKujira")
    var chainInfoTitle = "KUJIRA"
    var chainInfoMsg = NSLocalizedString("guide_msg_kujira", comment: "")
    var chainColor = UIColor(named: "kujira")!
    var chainColorBG = UIColor(named: "kujira_bg")!
    var chainTitle = "(Kujira Mainnet)"
    var chainTitle2 = "KUJIRA"
    var chainDBName = CHAIN_KUJIRA_S
    var chainAPIName = "kujira"
    var chainKoreanName = "쿠지라"
    var chainIdPrefix = "kaiyo-"
    
    
    var stakeDenomImg = UIImage(named: "tokenKujira")
    var stakeDenom = "ukuji"
    var stakeSymbol = "KUJI"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "kujira")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "kujira"
    var validatorPrefix = "kujiravaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = true
    var grpcUrl = "grpc-kujira.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-kujira-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "kujira/"
    var priceUrl = GeckoUrl + "kujira"
    
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
        return "https://kujira.app/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/team-kujira"
    }
}
