//
//  ChainMintStation.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/27/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainMintStation: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.MINTSTATION_TEST
    var chainImg = UIImage(named: "chainMintstation")
    var chainInfoImg = UIImage(named: "infoMintstation")
    var chainInfoTitle = "MINTSTATION-TESTNET"
    var chainInfoMsg = NSLocalizedString("guide_msg_mintstation", comment: "")
    var chainColor = UIColor(named: "mintstation")!
    var chainColorBG = UIColor(named: "mintstation_bg")!
    var chainTitle = "(MintStation-Testnet)"
    var chainTitle2 = "MINTSTATION-TESTNET"
    var chainDBName = CHAIN_MINTSTATION_TEST_S
    var chainAPIName = "mintstation-testnet"
    var chainKoreanName = "민트스테이션"
    var chainIdPrefix = "mintstation-"
    
    var stakeDenomImg = UIImage(named: "tokenMintstation")
    var stakeDenom = "umint"
    var stakeSymbol = "MINT"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "mintstation")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "mint"
    var validatorPrefix = "mintvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-office-mintstation.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "mintstation-testnet/"
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
        return ""
    }

    func getInfoLink2() -> String {
        return ""
    }
}

