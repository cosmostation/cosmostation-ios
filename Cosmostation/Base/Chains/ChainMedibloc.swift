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
    var isGrpc = true
    var chainType = ChainType.MEDI_MAIN
    var chainImg = UIImage(named: "chainMedibloc")
    var chainInfoImg = UIImage(named: "mediblocImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_medi", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_medi", comment: "")
    var chainColor = UIColor(named: "medibloc")!
    var chainColorBG = UIColor(named: "medibloc_bg")!
    var chainTitle = "(Medibloc Mainnet)"
    var chainTitle2 = "MEDIBLOC"
    var chainDBName = "SUPPORT_CHAIN_MEDI"
    var chainAPIName = "medibloc"
    
    var stakeDenomImg = UIImage(named: "tokenmedibloc")
    var stakeDenom = "umed"
    var stakeSymbol = "MED"
    var stakeSendImg = UIImage(named: "btnSendMedi")
    var stakeSendBg = UIColor.white
    
    var addressPrefix = "panacea"
    let addressHdPath0 = "m/44'/371'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-medibloc-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-medibloc-app.cosmostation.io"
    var apiUrl = "https://api-medibloc.cosmostation.io/"
    var explorerUrl = MintscanUrl + "medibloc/"
    var validatorImgUrl = MonikerUrl + "medibloc/"
    var relayerImgUrl = RelayerUrl + "medibloc/relay-medibloc-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String {
        return ""
    }
}
