//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainCosmos: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.COSMOS_MAIN
    var chainImg = UIImage(named: "cosmosWhMain")
    var chainInfoImg = UIImage(named: "guideImg")
    var chainInfoTitle = NSLocalizedString("send_guide_title_cosmos", comment: "")
    var chainInfoMsg = NSLocalizedString("send_guide_msg_cosmos", comment: "")
    var chainColor = UIColor(named: "cosmos")!
    var chainColorBG = UIColor(named: "cosmos_bg")!
    
    var chainTitle = "(Cosmos Mainnet)"
    var chainTitle2 = "COSMOS"
    var chainDBName = "SUPPORT_CHAIN_COSMOS_MAIN"
    var chainAPIName = "cosmos"
    
    
    var stakeDenomImg = UIImage(named: "atom_ic")
    var stakeDenom = "uatom"
    var stakeSymbol = "Atom"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "cosmos")!
    
    var addressPrefix = "cosmos"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = true
    var grpcUrl = "lcd-cosmos-app.cosmostation.io"
    var grpcPort = "9090"
    var lcdUrl = "https://lcd-cosmos-app.cosmostation.io"
    var apiUrl = "https://api.cosmostation.io/"
    var explorerUrl = MintscanUrl + "cosmos/"
    var validatorImgUrl = MonikerUrl + "cosmoshub/"
    var relayerImgUrl = RelayerUrl + "cosmos/relay-cosmos-unknown.png"
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [addressHdPath0]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    

}
