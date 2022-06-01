//
//  ChainCertik.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCertik: ChainConfig {
    var chainType = ChainType.CERTIK_MAIN
    var chainImg = UIImage(named: "certikChainImg")
    var chainInfoImg = UIImage(named: "certikImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_certik", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_certik", comment: "")
    var stakeDenomImg = UIImage(named: "certikTokenImg")
    var stakeDenom = "uctk"
    var stakeSymbol = "CTK"
    var accountPrefix = "certik"
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
