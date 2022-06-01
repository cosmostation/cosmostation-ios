//
//  ChainProvenance.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainProvenance: ChainConfig {
    var chainType = ChainType.PROVENANCE_MAIN
    var chainImg = UIImage(named: "chainProvenance")
    var chainInfoImg = UIImage(named: "infoiconProvenance")
    var chainInfoTitle = NSLocalizedString("send_guide_title_provenance", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_provenance", comment: "")
    var stakeDenomImg = UIImage(named: "tokenHash")
    var stakeDenom = "nhash"
    var stakeSymbol = "HASH"
    var accountPrefix = "pb"
    var hdPath0 = "m/44'/505'/0'/0/X"
    
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
