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
    var chainInfoTitle = NSLocalizedString("Station", comment: "")
    var chainInfoMsg = NSLocalizedString("Station", comment: "")
    var chainColor = UIColor(named: "station")!
    var chainColorBG = UIColor(named: "station_bg")!
    var chainTitle = "(Station Testnet)"
    var chainTitle2 = "STATION TEST"
    var chainDBName = CHAIN_STATION_TEST_S
    var chainAPIName = "station"
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
    
    let gasRate0 = "0.00025uiss"
    let gasRate1 = "0.0025uiss"
    let gasRate2 = "0.025uiss"
    
    var etherAddressSupport = false
    var wasmSupport = false
    var evmSupport = false
    var wcSupoort = true
    var authzSupoort = false
    var moonPaySupoort = false
    var kadoMoneySupoort = false
    var grpcUrl = "lcd-office.cosmostation.io"
    var grpcPort = 20400
    var rpcUrl = ""
    var lcdUrl = "https://lcd-office.cosmostation.io/station-testnet/"
    var apiUrl = "https://api-office.cosmostation.io/station-testnet/"
    var explorerUrl = "https://testnet.mintscan.io/station/"
    var validatorImgUrl = ""
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
    
    func getGasRates() -> Array<String> {
        return [gasRate0, gasRate1, gasRate2]
    }
    
    func getGasDefault() -> Int {
        return 0
    }
}
