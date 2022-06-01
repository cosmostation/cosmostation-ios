//
//  ChainCryptoorg.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCryptoorg: ChainConfig {
    var chainType = ChainType.CRYPTO_MAIN
    var chainImg = UIImage(named: "chaincrypto")
    var chainInfoImg = UIImage(named: "cryptochainImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_crypto", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_crypto", comment: "")
    var stakeDenomImg = UIImage(named: "tokencrypto")
    var stakeDenom = "basecro"
    var stakeSymbol = "CRO"
    var accountPrefix = "cro"
    var hdPath0 = "m/44'/394'/0'/0/X"
    
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
