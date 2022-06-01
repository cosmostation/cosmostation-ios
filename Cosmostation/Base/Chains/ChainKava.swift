//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainKava: ChainConfig {
    var chainType = ChainType.KAVA_MAIN
    var chainImg = UIImage(named: "kavaImg")
    var chainInfoImg = UIImage(named: "kavamainImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_kava", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_kava", comment: "")
    var stakeDenomImg = UIImage(named: "kavaTokenImg")
    var stakeDenom = "ukava"
    var stakeSymbol = "KAVA"
    var accountPrefix = "kava"
    var hdPath0 = "m/44'/118'/0'/0/X"
    var hdPath1 = "m/44'/459'/0'/0/X"
    
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
