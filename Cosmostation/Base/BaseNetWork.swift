//
//  BaseNetWork.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class BaseNetWork {
    
    func fetchPrices() {
        print("fetchPrices ", BaseNetWork.getPricesUrl())
        if (!BaseData.instance.needPriceUpdate()) { return }
        AF.request(BaseNetWork.getPricesUrl(), method: .get)
            .responseDecodable(of: [MintscanPrice].self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanPrices = value
                    BaseData.instance.setLastPriceTime()
                    
                case .failure:
                    print("fetchPrices error")
                }
                NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
            }
        
        AF.request(BaseNetWork.getUSDPricesUrl(), method: .get)
            .responseDecodable(of: [MintscanPrice].self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanUSDPrices = value
                    
                case .failure:
                    print("fetchUSDPrices error")
                }
            }
    }
    
    func fetchAssets() {
//        print("fetchAssets Start ", BaseNetWork.getMintscanAssetsUrl())
        AF.request(BaseNetWork.getMintscanAssetsUrl(), method: .get)
            .responseDecodable(of: MintscanAssets.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanAssets = value.assets
                    print("mintscanAssets ", BaseData.instance.mintscanAssets?.count)
                    
                    
                case .failure:
                    print("fetchAssets error ", response.error)
                }
                NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
            }
    }
    
    func fetchCw20Info(_ chain: CosmosClass) {
//        print("fetchCw20Info Start ",  BaseNetWork.getMintscanCw20InfoUrl(chain))
        AF.request(BaseNetWork.getMintscanCw20InfoUrl(chain), method: .get)
            .responseDecodable(of: MintscanTokens.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    if let tokens = value.assets {
                        chain.mintscanTokens = tokens
                    }
                    
                case .failure:
                    print("fetchCw20Info error ", response.error)
                }
            }
    }
    
    
    
    static func getAccountHistoryUrl(_ chain: BaseChain, _ address: String) -> String {
        if (chain is ChainBinanceBeacon) {
            return ChainBinanceBeacon.lcdUrl + "api/v1/transactions"
        } else if (chain is ChainOktKeccak256) {
            return MINTSCAN_API_URL + "v1/utils/proxy/okc-transaction-list?device=IOS&chainShortName=okc&address=" + address + "&limit=50"
        } else {
            return MINTSCAN_API_URL + "v1/" + chain.apiName + "/account/" + address + "/txs"
        }
        
    }
    
    static func getPricesUrl() -> String {
        let currency = BaseData.instance.getCurrencyString().lowercased()
        return MINTSCAN_API_URL + "v2/utils/market/prices?currency=" + currency
    }
    
    static func getUSDPricesUrl() -> String {
        return MINTSCAN_API_URL + "v2/utils/market/prices?currency=usd"
    }
    
    static func getMintscanAssetsUrl() -> String {
        return MINTSCAN_API_URL + "v3/assets"
    }
    
    static func getMintscanCw20InfoUrl(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v3/assets/" +  chain.apiName + "/cw20"
    }
    
    static func getTxDetailUrl(_ chain: BaseChain, _ txHash: String) -> URL? {
        if (chain is ChainBinanceBeacon) {
            return URL(string: ChainBinanceBeacon.explorer + "tx/" + txHash)
        } else if (chain is ChainOktKeccak256) {
            return URL(string: ChainOktKeccak256.explorer + "tx/" + txHash)
        }
        return URL(string: MintscanUrl + chain.apiName + "/transactions/" + txHash)
    }
}


//LCD call for legacy chains
extension BaseNetWork {
    
    static func lcdNodeInfoUrl(_ chain: BaseChain) -> String {
        if (chain is ChainBinanceBeacon) {
            return ChainBinanceBeacon.lcdUrl + "api/v1/node-info"
        } else if (chain is ChainOktKeccak256) {
            return ChainOktKeccak256.lcdUrl + "node_info"
        }
        return ""
    }
    
    static func lcdAccountInfoUrl(_ chain: BaseChain, _ address: String) -> String {
        if (chain is ChainBinanceBeacon) {
            return ChainBinanceBeacon.lcdUrl + "api/v1/account/" + address
        } else if (chain is ChainOktKeccak256) {
            return ChainOktKeccak256.lcdUrl + "auth/accounts/" + address
        }
        return ""
    }
    
    
    static func lcdBeaconTokenUrl() -> String {
        return ChainBinanceBeacon.lcdUrl + "api/v1/tokens"
    }
    
    static func lcdBeaconMiniTokenUrl() -> String {
        return ChainBinanceBeacon.lcdUrl + "api/v1/mini/tokens"
    }
    
//    static func lcdBeaconTicUrl() -> String {
//        return ChainBinanceBeacon.lcdUrl + "api/v1/ticker/24hr"
//    }
//
//    static func lcdBeaconMiniTicUrl() -> String {
//        return ChainBinanceBeacon.lcdUrl + "api/v1/mini/ticker/24hr"
//    }
    
    static func lcdOktDepositUrl(_ address: String) -> String {
        return ChainOktKeccak256.lcdUrl + "staking/delegators/" + address
    }
    
    static func lcdOktWithdrawUrl(_ address: String) -> String {
        return ChainOktKeccak256.lcdUrl + "staking/delegators/" + address + "/unbonding_delegations"
    }
    static func lcdOktTokenUrl() -> String {
        return ChainOktKeccak256.lcdUrl + "tokens"
    }
}
