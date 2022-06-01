//
//  ChainMedibloc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainMedibloc: ChainConfig {
    var chainType = ChainType.MEDI_MAIN
    var chainImg = UIImage(named: "chainMedibloc")
    var chainInfoImg = UIImage(named: "mediblocImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_medi", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_medi", comment: "")
    var stakeDenomImg = UIImage(named: "tokenmedibloc")
    var stakeDenom = "umed"
    var stakeSymbol = "MED"
    var accountPrefix = "panacea"
    var hdPath0 = "m/44'/371'/0'/0/X"
    
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
