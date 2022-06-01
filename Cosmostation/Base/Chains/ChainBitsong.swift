//
//  ChainBitsong.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBitsong: ChainConfig {
    var chainType = ChainType.BITSONG_MAIN
    var chainImg = UIImage(named: "chainBitsong")
    var chainInfoImg = UIImage(named: "infoiconBitsong")
    var chainInfoTitle = NSLocalizedString("send_guide_title_bitsong", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_bitsong", comment: "")
    var stakeDenomImg = UIImage(named: "tokenBitsong")
    var stakeDenom = "ubtsg"
    var stakeSymbol = "BTSG"
    var accountPrefix = "bitsong"
    var hdPath0 = "m/44'/639'/0'/0/X"
    
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
