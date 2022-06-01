//
//  ChainEvmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainEvmos: ChainConfig {
    var chainType = ChainType.EVMOS_MAIN
    var chainImg = UIImage(named: "chainEvmos")
    var chainInfoImg = UIImage(named: "infoiconEvmos")
    var chainInfoTitle = NSLocalizedString("send_guide_title_evmos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_evmos", comment: "")
    var stakeDenomImg = UIImage(named: "tokenEvmos")
    var stakeDenom = "aevmos"
    var stakeSymbol = "EVMOS"
    var accountPrefix = "evmos"
    var hdPath0 = "m/44'/60'/0'/0/X"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [hdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
