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
    var chainInfoTitle = "IXO"
    var chainInfoMsg = NSLocalizedString("guide_msg_ixo", comment: "")
    var chainColor = UIColor(named: "ixo")!
    var chainColorBG = UIColor(named: "ixo_bg")!
    var chainTitle = "(Ixo Mainnet)"
    var chainTitle2 = "IXO"
    var chainDBName = CHAIN_IXO_S
    var chainAPIName = "ixo"
    var chainKoreanName = "아이엑스오"
    var chainIdPrefix = "ixo-"
    
    
    var stakeDenomImg = UIImage(named: "tokenIxo")
    var stakeDenom = "uixo"
    var stakeSymbol = "IXO"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "ixo")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "ixo"
    var validatorPrefix = "ixovaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-ixo.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "ixo/"
    var priceUrl = GeckoUrl + "ixo"
    
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
        return "https://www.ixo.world/"
    }

    func getInfoLink2() -> String {
        return "https://earthstate.ixo.world/"
    }
}
