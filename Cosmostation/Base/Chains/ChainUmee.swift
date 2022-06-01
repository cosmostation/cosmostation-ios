//
//  ChainUmee.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainUmee: ChainConfig {
    var chainType = ChainType.UMEE_MAIN
    var chainImg = UIImage(named: "chainUmee")
    var chainInfoImg = UIImage(named: "infoiconUmee")
    var chainInfoTitle = NSLocalizedString("send_guide_title_umee", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_umee", comment: "")
    var stakeDenomImg = UIImage(named: "tokenUmee")
    var stakeDenom = "uumee"
    var stakeSymbol = "UMEE"
    var accountPrefix = "umee"
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
