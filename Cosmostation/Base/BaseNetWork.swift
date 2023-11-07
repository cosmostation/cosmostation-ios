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
    
    func fetchChainList() {
        AF.request(BaseNetWork.msSupportChains(), method: .get)
            .responseDecodable(of: JSON.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanChains = value
                    
                case .failure:
                    print("fetchChainList error ", response.error)
                }
            }
    }
    
    func fetchPrices(_ force: Bool? = false) {
//        print("fetchPrices ", BaseNetWork.msPricesUrl())
        if (!BaseData.instance.needPriceUpdate() && force == false) { return }
        AF.request(BaseNetWork.msPricesUrl(), method: .get)
            .responseDecodable(of: [MintscanPrice].self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanPrices = value
                    BaseData.instance.setLastPriceTime()
                    if let currnetAccount = BaseData.instance.baseAccount {
                        currnetAccount.updateAllValue()
                    }
                    
                case .failure:
                    print("fetchPrices error")
                }
                NotificationCenter.default.post(name: Notification.Name("FetchPrice"), object: nil, userInfo: nil)
            }
        
        AF.request(BaseNetWork.msUSDPricesUrl(), method: .get)
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
//        print("fetchAssets Start ", BaseNetWork.msAssetsUrl())
        AF.request(BaseNetWork.msAssetsUrl(), method: .get)
            .responseDecodable(of: MintscanAssets.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanAssets = value.assets
//                    print("mintscanAssets ", BaseData.instance.mintscanAssets?.count)
                case .failure:
                    print("fetchAssets error ", response.error)
                }
                NotificationCenter.default.post(name: Notification.Name("FetchAssets"), object: nil, userInfo: nil)
            }
    }
    
    
    
    static func getAccountHistoryUrl(_ chain: BaseChain, _ address: String) -> String {
        if (chain is ChainBinanceBeacon) {
            return BNB_BEACON_LCD + "api/v1/transactions"
        } else if (chain is ChainOkt60Keccak) {
            return MINTSCAN_API_URL + "v1/utils/proxy/okc-transaction-list?device=IOS&chainShortName=okc&address=" + address + "&limit=50"
        } else {
            return MINTSCAN_API_URL + "v1/" + chain.apiName + "/account/" + address + "/txs"
        }
    }
    
    static func msPricesUrl() -> String {
        let currency = BaseData.instance.getCurrencyString().lowercased()
        return MINTSCAN_API_URL + "v2/utils/market/prices?currency=" + currency
    }
    
    static func msUSDPricesUrl() -> String {
        return MINTSCAN_API_URL + "v2/utils/market/prices?currency=usd"
    }
    
    static func msAssetsUrl() -> String {
        return MINTSCAN_API_URL + "v3/assets"
    }
    
    static func msCw20InfoUrl(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v3/assets/" +  chain.apiName + "/cw20"
    }
    
    static func msErc20InfoUrl(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v3/assets/" +  chain.apiName + "/erc20"
    }
    
    static func msSupportChains() -> String {
        return MINTSCAN_API_URL + "v1/meta/support/chains"
    }
    
    static func msChainParam(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v10/utils/params/" + chain.apiName
    }
    
    static func msProposals(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v1/" + chain.apiName + "/proposals"
    }
    
    static func msMyVoteHistory(_ chain: BaseChain, _ address: String) -> String {
        return MINTSCAN_API_URL + "v1/" + chain.apiName + "/account/" + address + "/votes"
    }
    
    static func getTxDetailUrl(_ chain: BaseChain, _ txHash: String) -> URL? {
        if (chain is ChainBinanceBeacon) {
            return URL(string: BNB_BEACON_EXPLORER + "tx/" + txHash)
        } else if (chain is ChainOkt60Keccak) {
            return URL(string: OKT_EXPLORER + "tx/" + txHash)
        }
        return URL(string: MintscanUrl + chain.apiName + "/transactions/" + txHash)
    }
    
    static func getAccountDetailUrl(_ chain: CosmosClass) -> URL? {
        if (chain is ChainBinanceBeacon) {
            return URL(string: BNB_BEACON_EXPLORER + "address/" + chain.bechAddress)
        } else if (chain is ChainOkt60Keccak) {
            return URL(string: OKT_EXPLORER + "address/" + chain.bechAddress)
        }
        return URL(string: MintscanUrl + chain.apiName + "/account/" + chain.bechAddress)
    }
    
    static func getProposalDetailUrl(_ chain: BaseChain, _ proposalId: UInt64) -> URL? {
        return URL(string: MintscanUrl + chain.apiName + "/proposals/" + String(proposalId))
    }
    
    
    static func SkipChains() -> String {
        return SKIP_API_URL + "v1/info/chains"
    }
    
    static func SkipAssets() -> String {
        return SKIP_API_URL + "v1/fungible/assets"
    }
    
    static func SkipRoutes() -> String {
        return SKIP_API_URL + "v1/fungible/route"
    }
    
    static func SkipMsg() -> String {
        return SKIP_API_URL + "v1/fungible/msgs"
    }
}


//LCD call for legacy chains
extension BaseNetWork {
    
    static func lcdNodeInfoUrl(_ chain: BaseChain) -> String {
        if (chain is ChainBinanceBeacon) {
            return BNB_BEACON_LCD + "api/v1/node-info"
        } else if (chain is ChainOkt60Keccak) {
            return OKT_LCD + "node_info"
        }
        return ""
    }
    
    static func lcdAccountInfoUrl(_ chain: BaseChain, _ address: String) -> String {
        if (chain is ChainBinanceBeacon) {
            return BNB_BEACON_LCD + "api/v1/account/" + address
        } else if (chain is ChainOkt60Keccak) {
            return OKT_LCD + "auth/accounts/" + address
        }
        return ""
    }
    
    
    static func lcdBeaconTokenUrl() -> String {
        return BNB_BEACON_LCD + "api/v1/tokens"
    }
    
    static func lcdBeaconMiniTokenUrl() -> String {
        return BNB_BEACON_LCD + "api/v1/mini/tokens"
    }
    
//    static func lcdBeaconTicUrl() -> String {
//        return BNB_BEACON_LCD + "api/v1/ticker/24hr"
//    }
//
//    static func lcdBeaconMiniTicUrl() -> String {
//        return BNB_BEACON_LCD + "api/v1/mini/ticker/24hr"
//    }
    
    static func lcdOktDepositUrl(_ address: String) -> String {
        return OKT_LCD + "staking/delegators/" + address
    }
    
    static func lcdOktWithdrawUrl(_ address: String) -> String {
        return OKT_LCD + "staking/delegators/" + address + "/unbonding_delegations"
    }
    static func lcdOktTokenUrl() -> String {
        return OKT_LCD + "tokens"
    }
    
    static func broadcastUrl(_ chain: BaseChain) -> String {
        if (chain is ChainBinanceBeacon) {
            return BNB_BEACON_LCD + "api/v1/broadcast"
        } else if (chain is ChainOkt60Keccak) {
            return OKT_LCD + "txs"
        }
        return ""
    }
    
    
    static func swapIdBep3Url(_ toChain: BaseChain, _ id: String) -> String {
        if (toChain is ChainBinanceBeacon) {
            return BNB_BEACON_LCD + "api/v1/atomic-swaps/" + id
        } else if (toChain is ChainKava60) {
            return KAVA_LCD + "kava/bep3/v1beta1/atomicswap/" + id
        }
        return ""
    }
}
