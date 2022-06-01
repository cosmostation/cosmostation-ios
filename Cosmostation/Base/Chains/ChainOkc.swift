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
    var chainType = ChainType.OKEX_MAIN
    var chainImg = UIImage(named: "chainOkex")
    var chainInfoImg = UIImage(named: "infoiconOkx")
    var chainInfoTitle = NSLocalizedString("send_guide_title_ok", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_ok", comment: "")
    var stakeDenomImg = UIImage(named: "tokenOkx")
    var stakeDenom = "okt"
    var stakeSymbol = "OKT"
    var accountPrefix = "ex"
    var hdPath0 = "m/44'/996'/0'/0/X"
    var hdPath1 = "m/44'/60'/0'/0/X"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [hdPath0, hdPath0, hdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
