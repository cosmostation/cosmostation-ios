//
//  ChainBand.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainBand: ChainConfig {
    var chainType = ChainType.BAND_MAIN
    var chainImg = UIImage(named: "chainBandprotocal")
    var chainInfoImg = UIImage(named: "infoiconBandprotocol")
    var chainInfoTitle = NSLocalizedString("send_guide_title_band", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_band", comment: "")
    var stakeDenomImg = UIImage(named: "tokenBand")
    var stakeDenom = "uband"
    var stakeSymbol = "Band"
    var accountPrefix = "band"
    var hdPath0 = "m/44'/494'/0'/0/X"
    
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
