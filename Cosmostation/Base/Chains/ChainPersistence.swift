//
//  ChainPersistence.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainPersistence: ChainConfig {
    var chainType = ChainType.PERSIS_MAIN
    var chainImg = UIImage(named: "chainpersistence")
    var chainInfoImg = UIImage(named: "persistenceImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_persis", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_persis", comment: "")
    var stakeDenomImg = UIImage(named: "tokenpersistence")
    var stakeDenom = "uxprt"
    var stakeSymbol = "XPRT"
    var accountPrefix = "persistence"
    var hdPath0 = "m/44'/750'/0'/0/X"
    
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
