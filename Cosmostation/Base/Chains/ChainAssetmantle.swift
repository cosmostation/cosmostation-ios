//
//  ChainAssetmantle.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAssetMantle: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.MANTLE_MAIN
    var chainImg = UIImage(named: "chainAssetmantle")
    var chainInfoImg = UIImage(named: "infoAssetmantle")
    var chainInfoTitle = "ASSETMANTLE"
    var chainInfoMsg = NSLocalizedString("guide_msg_mantle", comment: "")
    var chainColor = UIColor(named: "assetmantle")!
    var chainColorBG = UIColor(named: "assetmantle_bg")!
    var chainTitle = "(Asset-Mantle Mainnet)"
    var chainTitle2 = "ASSET-MANTLE"
    var chainDBName = "SUPPORT_CHAIN_MANTLE"
    var chainAPIName = "asset-mantle"
    var chainKoreanName = "에셋멘틀"
    var chainIdPrefix = "mantle-"
    
    var stakeDenomImg = UIImage(named: "tokenAssetmantle")
    var stakeDenom = "umntl"
    var stakeSymbol = "MNTL"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "assetmantle")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "mantle"
    var validatorPrefix = "mantlevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-asset-mantle.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = "https://lcd-asset-mantle-app.cosmostation.io/"
    var explorerUrl = MintscanUrl + "asset-mantle/"
    var priceUrl = GeckoUrl + "assetmantle"
    
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
        return "https://assetmantle.one/"
    }

    func getInfoLink2() -> String {
        return "https://blog.assetmantle.one/"
    }
}
