//
//  ChainBinanceBeacon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/05.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChainBinanceBeacon: CosmosClass  {
    
    //For Legacy Lcd chains
    lazy var lcdNodeInfo = JSON()
    lazy var lcdAccountInfo = JSON()
    lazy var lcdBeaconTokens = Array<JSON>()
    
    override init() {
        super.init()
        
        name = "BNB Beacon"
        tag = "binanceBeacon"
        chainId = "Binance-Chain-Tigris"
        logo1 = "chainBnbBeacon"
        logo2 = "chainBnbBeacon2"
        apiName = ""
        stakeDenom = "BNB"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/714'/0'/0/X")
        bechAccountPrefix = "bnb"
        supportStaking = false
    }
    
    override func fetchData(_ id: Int64) {
        fetchLcdData(id)
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return lcdBalanceValue(stakeDenom, usd)
    }
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "bnb-beacon-chain/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
}

extension ChainBinanceBeacon {
    
    func fetchLcdData(_ id: Int64) {
        let group = DispatchGroup()
        
        fetchNodeInfo(group)
        fetchAccountInfo(group, bechAddress)
        fetchBeaconTokens(group)
        fetchBeaconMiniTokens(group)
        
        group.notify(queue: .main) {
            self.fetched = true
            self.allCoinValue = self.allCoinValue()
            self.allCoinUSDValue = self.allCoinValue(true)
            
            BaseData.instance.updateRefAddressesMain(
                RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                           self.lcdAllStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                           nil, self.lcdAccountInfo.bnbCoins?.count))
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
        }
    }
    
    func fetchNodeInfo(_ group: DispatchGroup) {
//        print("fetchNodeInfo Start ", BaseNetWork.lcdNodeInfoUrl(self))
        group.enter()
        AF.request(BaseNetWork.lcdNodeInfoUrl(self), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdNodeInfo = value
//                    print("fetchNodeInfo ", value)
                case .failure:
                    print("fetchNodeInfo error")
                }
                group.leave()
            }
    }
    
    func fetchAccountInfo(_ group: DispatchGroup, _ address: String) {
//        print("fetchAccountInfo Start ", BaseNetWork.lcdAccountInfoUrl(self, address))
        group.enter()
        AF.request(BaseNetWork.lcdAccountInfoUrl(self, address), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdAccountInfo = value
//                    print("fetchAccountInfo ", value)
                case .failure:
                    print("fetchAccountInfo error")
                }
                group.leave()
            }
    }
    
    func fetchBeaconTokens(_ group: DispatchGroup) {
//        print("fetchBeaconTokens Start ", BaseNetWork.lcdBeaconTokenUrl())
        group.enter()
        AF.request(BaseNetWork.lcdBeaconTokenUrl(), method: .get, parameters: ["limit":"1000"])
            .responseDecodable(of: [JSON].self) { response in
                switch response.result {
                case .success(let values):
                    values.forEach { value in
                        self.lcdBeaconTokens.append(value)
                    }
                case .failure:
                    print("fetchBeaconTokens error")
                }
                group.leave()
            }
    }
    
    func fetchBeaconMiniTokens(_ group: DispatchGroup) {
//        print("fetchBeaconMiniTokens Start ", BaseNetWork.lcdBeaconMiniTokenUrl())
        group.enter()
        AF.request(BaseNetWork.lcdBeaconMiniTokenUrl(), method: .get, parameters: ["limit":"1000"])
            .responseDecodable(of: [JSON].self) { response in
                switch response.result {
                case .success(let values):
                    values.forEach { value in
                        self.lcdBeaconTokens.append(value)
                    }
                case .failure:
                    print("fetchBeaconMiniTokens error")
                }
                group.leave()
            }
    }
    
    
    func lcdAllStakingDenomAmount() -> NSDecimalNumber {
        return lcdBalanceAmount(stakeDenom)
    }
    
    func lcdBalanceAmount(_ denom: String) -> NSDecimalNumber {
        if let balance = lcdAccountInfo.bnbCoins?.filter({ $0["symbol"].string == denom }).first {
            return NSDecimalNumber.init(string: balance["free"].string ?? "0")
        }
        return NSDecimalNumber.zero
        
    }
    
    func lcdBalanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
            let amount = lcdBalanceAmount(denom)
            var msPrice = BaseData.instance.getPrice(BNB_GECKO_ID, usd)
            return msPrice.multiplying(by: amount, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
}

let BNB_BEACON_LCD = "https://dex.binance.org/"
let BNB_BEACON_EXPLORER = "https://explorer.bnbchain.org/"
let BNB_BEACON_BASE_FEE = "0.000075"
let BNB_GECKO_ID = "binancecoin"
