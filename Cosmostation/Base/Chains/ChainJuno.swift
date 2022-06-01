//
//  ChainJuno.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainJuno: ChainConfig {
    var chainType = ChainType.JUNO_MAIN
    var chainImg = UIImage(named: "chainJuno")
    var chainInfoImg = UIImage(named: "infoiconJuno")
    var chainInfoTitle = NSLocalizedString("send_guide_title_juno", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_juno", comment: "")
    var stakeDenomImg = UIImage(named: "tokenJuno")
    var stakeDenom = "ujuno"
    var stakeSymbol = "JUNO"
    var accountPrefix = "juno"
    var hdPath0 = "m/44'/118'/0'/0/X"
    
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
