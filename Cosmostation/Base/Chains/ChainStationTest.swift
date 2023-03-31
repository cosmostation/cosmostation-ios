//
//  ChainStationTest.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/07.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation

class StationTest: ChainConfig {
    var isGrpc = true
    var chainType = ChainType.STATION_TEST
    var chainImg = UIImage(named: "chainStationTest")
    var chainInfoImg = UIImage(named: "infoStation")
    var chainInfoTitle = "STATION"
    var chainInfoMsg = NSLocalizedString("Station", comment: "")
    var chainColor = UIColor(named: "station")!
    var chainColorBG = UIColor(named: "station_bg")!
    var chainTitle = "(Station Testnet)"
    var chainTitle2 = "STATION TEST"
    var chainDBName = CHAIN_STATION_TEST_S
    var chainAPIName = "station"
    var chainKoreanName = "스테이션"
    var chainIdPrefix = "station"
    
    var stakeDenomImg = UIImage(named: "tokenStation")
    var stakeDenom = "uiss"
    var stakeSymbol = "ISS"
    var stakeSendImg = UIImage(named: "sendImg")!
    var stakeSendBg = UIColor(named: "station")!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    
    var addressPrefix = "station"
    var validatorPrefix = "stationvaloper"
    var defaultPath = "m/44'/118'/0'/0/X"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "grpc-office.cosmostation.io"
    var grpcPort = 443
    var rpcUrl = ""
    var lcdUrl = ""
    var explorerUrl = "https://testnet.mintscan.io/station/"
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
        return "https://www.cosmostation.io/"
    }

    func getInfoLink2() -> String {
        return "https://medium.com/cosmostation"
    }
}
