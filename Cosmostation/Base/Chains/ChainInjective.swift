//
//  ChainInjective.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainInjective: ChainConfig {
    var chainType = ChainType.INJECTIVE_MAIN
    var chainImg = UIImage(named: "chainInjective")
    var chainInfoImg = UIImage(named: "infoiconInjective")
    var chainInfoTitle = NSLocalizedString("send_guide_title_injective", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_injective", comment: "")
    var stakeDenomImg = UIImage(named: "tokenInjective")
    var stakeDenom = "inj"
    var stakeSymbol = "INJ"
    var accountPrefix = "inj"
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
