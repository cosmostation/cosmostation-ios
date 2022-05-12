//
//  ChainFetchAi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

class ChainFetchAi: ChainConfig {
    var chainType: ChainType
    var hdPath0 = "m/44'/118'/0'/0/X"
    var hdPath1 = "m/44'/60'/0'/0/X"
    var hdPath2 = "m/44'/60'/X'/0/0"
    var hdPath3 = "m/44'/60'/0'/X"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [hdPath0, hdPath1, hdPath2, hdPath3]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
