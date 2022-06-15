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
    var chainInfoImg = UIImage(named: "infoiconBitsong")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bitsong", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bitsong", comment: "")
    var chainColor = UIColor(named: "bitsong")!
    var chainColorDark = UIColor(named: "bitsong_dark")
    var chainColorBG = UIColor(named: "bitsong")!.withAlphaComponent(0.15)
    
    var stakeDenomImg = UIImage(named: "tokenBitsong")
    var stakeDenom = "ubtsg"
    var stakeSymbol = "BTSG"
    
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
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
