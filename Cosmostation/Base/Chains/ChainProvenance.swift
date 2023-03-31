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
    var chainInfoTitle = "PROVENANCE"
    var chainInfoMsg = NSLocalizedString("guide_msg_provenance", comment: "")
    var chainColor = UIColor(named: "provenance")!
    var chainColorBG = UIColor(named: "provenance_bg")!
    var chainTitle = "(Provenance Mainnet)"
    var chainTitle2 = "PROVENANCE"
    var chainDBName = CHAIN_PROVENANCE_S
    var chainAPIName = "provenance"
    var chainKoreanName = "프로비넌스"
    var chainIdPrefix = "pio-mainnet-"
    
    var stakeDenomImg = UIImage(named: "tokenProvenance")
    var stakeDenom = "nhash"
    var stakeSymbol = "HASH"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "provenance")!
    var divideDecimal: Int16 = 9
    var displayDecimal: Int16 = 9
    
    var addressPrefix = "pb"
    var validatorPrefix = "pbvaloper"
    var defaultPath = "m/44'/505'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-provenance.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "provenance/"
    var priceUrl = GeckoUrl + "provenance-blockchain"
    
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
        return "https://www.provenance.io/"
    }

    func getInfoLink2() -> String {
        return "https://www.provenance.io/blog"
    }
}
