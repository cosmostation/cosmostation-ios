//
//  ChainNeutron.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/05/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainNeutron: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.NEUTRON_MAIN
    var chainImg = UIImage(named: "chainNeutron")
    var chainInfoImg = UIImage(named: "infoNeutron")
    var chainInfoTitle = "NEUTRON"
    var chainInfoMsg = NSLocalizedString("guide_msg_neutron", comment: "")
    var chainColor = UIColor(named: "neutron")!
    var chainColorBG = UIColor(named: "neutron_bg")!
    var chainTitle = "(Neutron Mainnet)"
    var chainTitle2 = "NEUTRON"
    var chainDBName = CHAIN_NEUTRON_S
    var chainAPIName = "neutron"
    var chainKoreanName = "뉴트론"
    var chainIdPrefix = "neutron-"
    
    var stakeDenomImg = UIImage(named: "tokenNeutron")
    var stakeDenom = "untrn"
    var stakeSymbol = "NTRN"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "neutron")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "neutron"
    var validatorPrefix = "neutronvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = true
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-neutron.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanUrl + "neutron/"
    var priceUrl = ""
    
    required init(_ chainType: ChainType) {
        self.chainType = chainType
    }
    
    func supportHdPaths() -> Array<String> {
        return [defaultPath]
    }
    
    func getHdPath(_ type: Int, _ path: Int) -> String {
        supportHdPaths()[type].replacingOccurrences(of: "X", with: String(path))
    }
    
    func getInfoLink1() -> String {
        return "https://neutron.org/"
    }

    func getInfoLink2() -> String {
        return "https://neutron.org/"
    }
}

let NEUTRON_MAIN_VAULTS = "https://raw.githubusercontent.com/cosmostation/chainlist/main/chain/neutron/vaults.json"
let NEUTRON_MAIN_DAO = "https://raw.githubusercontent.com/cosmostation/chainlist/main/chain/neutron/daos.json"
