//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import HDWalletKit

class ChainCosmos: ChainConfig {
    var chainType: ChainType
    var accountPrefix = "cosmos"
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
//        let masterKey = words.getMasterKey()
//        let sPath = getHdPath(type, path)
        let childKey = WKey.getDerivedKey(words.getMasterKey(), getHdPath(type, path))
        return WKey.getDpAddress(childKey.publicKey, accountPrefix)
    }
}
