//
//  ChainBitsong.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBitsong: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.BITSONG_MAIN
    var chainImg = UIImage(named: "chainBitsong")
    var chainInfoImg = UIImage(named: "infoBitsong")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bitsong", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bitsong", comment: "")
    var chainColor = UIColor(named: "bitsong")!
    var chainColorBG = UIColor(named: "bitsong_bg")!
    var chainTitle = "(Bitsong Mainnet)"
    var chainTitle2 = "BITSONG"
    var chainDBName = "SUPPORT_CHAIN_BITSONG"
    var chainAPIName = "bitsong"
    
    var stakeDenomImg = UIImage(named: "tokenBitsong")
    var stakeDenom = "ubtsg"
    var stakeSymbol = "BTSG"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "bitsong")!
    
    var addressPrefix = "bitsong"
    let addressHdPath0 = "m/44'/639'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-bitsong-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-bitsong-app.cosmostation.io"
    var apiUrl = "https://api-bitsong.cosmostation.io/"
    var explorerUrl = MintscanUrl + "bitsong/"
    var validatorImgUrl = MonikerUrl + "bitsong/"
    var relayerImgUrl = RelayerUrl + "bitsong/relay-bitsong-unknown.png"
    var priceUrl = CoingeckoUrl + "bitsong"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
}
