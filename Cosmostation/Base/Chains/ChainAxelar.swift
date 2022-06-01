//
//  ChainAxelar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainAxelar: ChainConfig {
    var chainType = ChainType.AXELAR_MAIN
    var chainInfoImg = UIImage(named: "infoiconAxelar")
    var chainInfoTitle = NSLocalizedString("send_guide_title_axelar", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_axelar", comment: "")
    var stakeDenomImg = UIImage(named: "tokenAxelar")
    var stakeDenom = "uaxl"
    var stakeSymbol = "AXL"
    var accountPrefix = "axelar"
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
