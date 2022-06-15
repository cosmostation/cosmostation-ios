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
    var chainImg = UIImage(named: "testnetStation")
    var chainInfoImg = UIImage(named: "infoiconStation")
    var chainInfoTitle = NSLocalizedString("Station", comment: "")
    var chainInfoMsg = NSLocalizedString("Station", comment: "")
    var chainColor = UIColor(named: "station")!
    var chainColorDark = UIColor(named: "station_dark")
    var chainColorBG = UIColor(named: "station")!.withAlphaComponent(0.15)
    var chainTitle = "(Station Testnet)"
    var chainTitle2 = "STATION TEST"
    var chainDBName = "SUPPORT_CHAIN_STATION_TEST"
    var chainAPIName = ""
    
    var stakeDenomImg = UIImage(named: "tokenIss")
    var stakeDenom = "uiss"
    var stakeSymbol = "ISS"
    var stakeSendImg = UIImage(named: "sendImg")
    var stakeSendBg = UIColor(named: "station")!
    
    var addressPrefix = "station"
    let addressHdPath0 = "m/44'/118'/0'/0/X"
    
    var pushSupport = false
    var grpcUrl = "lcd-office.cosmostation.io"
    var grpcPort = "10400"
    var lcdUrl = "https://lcd-office.cosmostation.io/station-testnet/"
    var apiUrl = "https://api-office.cosmostation.io/station-testnet/"
    var explorerUrl = "https://testnet.mintscan.io/station/"
    var validatorImgUrl = ""
    var relayerImgUrl = ""
    
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
