//
//  ChainBitcana.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBitcana: ChainConfig {
    var chainType = ChainType.BITCANA_MAIN
    var chainImg = UIImage(named: "chainBitcanna")
    var chainInfoImg = UIImage(named: "infoiconBitcanna")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bitcanna", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bitcanna", comment: "")
    var stakeDenomImg = UIImage(named: "tokenBitcanna")
    var stakeDenom = "ubcna"
    var stakeSymbol = "BCNA"
    var accountPrefix = "bcna"
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

