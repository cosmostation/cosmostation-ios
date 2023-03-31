//
//  ChainLike.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/05.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainLike: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.LIKECOIN_MAIN
    var chainImg = UIImage(named: "chainLike")
    var chainInfoImg = UIImage(named: "infoLike")
    var chainInfoTitle = "LIKECOIN"
    var chainInfoMsg = NSLocalizedString("guide_msg_like", comment: "")
    var chainColor = UIColor(named: "like")!
    var chainColorBG = UIColor(named: "like_bg")!
    var chainTitle = "(Likecoin Mainnet)"
    var chainTitle2 = "LIKECOIN"
    var chainDBName = CHAIN_LIKECOIN_S
    var chainAPIName = "likecoin"
    var chainKoreanName = "라이크코인"
    var chainIdPrefix = "likecoin-"
    
    
    var stakeDenomImg = UIImage(named: "tokenLike")
    var stakeDenom = "nanolike"
    var stakeSymbol = "LIKE"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "like")!
    var divideDecimal: Int16 = 9
    var displayDecimal: Int16 = 9
    
    var addressPrefix = "like"
    var validatorPrefix = "likevaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = true
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-likecoin.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "likecoin/"
    var priceUrl = GeckoUrl + "likecoin"
    
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
        return "https://about.like.co/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/likecoin"
    }
}

