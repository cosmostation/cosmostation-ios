//
//  ChainNeutronTest.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/04/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Foundation

class ChainNeutronTest: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.NEUTRON_TEST
    var chainImg = UIImage(named: "chainNeutronTest")
    var chainInfoImg = UIImage(named: "infoNeutron")
    var chainInfoTitle = "NEUTRON"
    var chainInfoMsg = NSLocalizedString("guide_msg_neutron", comment: "")
    var chainColor = UIColor(named: "neutron")!
    var chainColorBG = UIColor(named: "neutron_bg")!
    var chainTitle = "(Neutron Testnet)"
    var chainTitle2 = "NEUTRON TEST"
    var chainDBName = CHAIN_NEUTRON_TEST_S
    var chainAPIName = "neutron-testnet"
    var chainKoreanName = "뉴트론 테스트넷"
    var chainIdPrefix = "baryon-"
    
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
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = false
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-office-neutron.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = MintscanTestUrl + "neutron-testnet/"
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

