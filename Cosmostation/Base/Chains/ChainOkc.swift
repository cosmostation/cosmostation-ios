//
//  ChainOkc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainOkc: ChainConfig {
    var isGrpc = false
    var chainType = ChainType.OKEX_MAIN
    var chainImg = UIImage(named: "chainOkex")
    var chainInfoImg = UIImage(named: "infoiconOkx")
    var chainInfoTitle = NSLocalizedString("send_guide_title_ok", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_ok", comment: "")
    
    var stakeDenomImg = UIImage(named: "tokenOkx")
    var stakeDenom = "okt"
    var stakeSymbol = "OKT"
    
    var addressPrefix = "ex"
    let addressHdPath0 = "m/44'/996'/0'/0/X"
    let addressHdPath1 = "m/44'/60'/0'/0/X"
    
    var grpcUrl = ""
    var grpcPort = ""
    var lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
    var apiUrl = "https://www.oklink.com/api/explorer/v1/"
    var explorerUrl = "https://www.oklink.com/okexchain/"
    var validatorImgUrl = MonikerUrl + "okex/"
    var relayerImgUrl = ""
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0, addressHdPath0, addressHdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
