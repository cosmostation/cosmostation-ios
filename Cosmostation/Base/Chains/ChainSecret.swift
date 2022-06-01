//
//  ChainSecret.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainSecret: ChainConfig {
    var chainType = ChainType.SECRET_MAIN
    var chainImg = UIImage(named: "secretChainImg")
    var chainInfoImg = UIImage(named: "secretImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_secret", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_secret", comment: "")
    var stakeDenomImg = UIImage(named: "secretTokenImg")
    var stakeDenom = "uscrt"
    var stakeSymbol = "SCRT"
    var accountPrefix = "secret"
    var hdPath0 = "m/44'/118'/0'/0/X"
    var hdPath1 = "m/44'/529'/0'/0/X"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [hdPath0, hdPath1]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
