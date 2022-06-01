//
//  ChainComdex.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainComdex: ChainConfig {
    var chainType = ChainType.COMDEX_MAIN
    var chainImg = UIImage(named: "chainComdex")
    var chainInfoImg = UIImage(named: "infoiconComdex")
    var chainInfoTitle = NSLocalizedString("send_guide_title_comdex", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_comdex", comment: "")
    var stakeDenomImg = UIImage(named: "tokenComdex")
    var stakeDenom = "ucmdx"
    var stakeSymbol = "CMDX"
    var accountPrefix = "comdex"
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
