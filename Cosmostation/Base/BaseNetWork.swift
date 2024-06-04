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
    
    func fetchChainParams() {
//        print("fetchChainParams ", BaseNetWork.msChainParams())
        AF.request(BaseNetWork.msChainParams(), method: .get)
            .responseDecodable(of: JSON.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanChainParams = value
                case .failure:
                    print("fetchChainParams error ", response.error)
                }
            }
    }
    
    func fetchChainParams() async throws -> JSON {
        return try await AF.request(BaseNetWork.msChainParams(), method: .get).serializingDecodable(JSON.self).value
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
        if (chain.tag.starts(with: "okt")) {
            return MINTSCAN_API_URL + "v10/utils/proxy/okc-transaction-list?device=IOS&chainShortName=okc&address=" + address + "&limit=50"
        } else {
            return MINTSCAN_API_URL + "v10/" + chain.apiName + "/account/" + address + "/txs"
        }
    }
    
    static func msPricesUrl() -> String {
        let currency = BaseData.instance.getCurrencyString().lowercased()
        return MINTSCAN_API_URL + "v10/utils/market/prices?currency=" + currency
    }
    
    static func msUSDPricesUrl() -> String {
        return MINTSCAN_API_URL + "v10/utils/market/prices?currency=usd"
    }
    
    static func msAssetsUrl() -> String {
        return MINTSCAN_API_URL + "v10/assets"
    }
    
    static func msCw20InfoUrl(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v10/assets/" +  chain.apiName + "/cw20/info"
    }
    
    static func msErc20InfoUrl(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v10/assets/" +  chain.apiName + "/erc20/info"
    }
    
    static func msChainParams() -> String {
        return MINTSCAN_API_URL + "v10/utils/params"
    }
    
    static func msCw721InfoUrl(_ chain: BaseChain) -> String {
        return ResourceBase + chain.apiName + "/cw721.json"
    }
    
    static func msProposals(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v10/" + chain.apiName + "/proposals"
    }
    
    static func msMyVoteHistory(_ chain: BaseChain, _ address: String) -> String {
        return MINTSCAN_API_URL + "v10/" + chain.apiName + "/account/" + address + "/votes"
    }
    
    static func msNftDetail(_ chain: BaseChain, _ contractAddress: String, _ tokenId: String) -> String {
        return MINTSCAN_API_URL + "v10/" + chain.apiName + "/contracts/" + contractAddress + "/nft-url/" + tokenId
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
        if (chain.tag.starts(with: "okt")) {
            return OKT_LCD + "node_info"
        }
        return ""
    }
    
    static func lcdAccountInfoUrl(_ chain: BaseChain, _ address: String) -> String {
        if (chain.tag.starts(with: "okt")) {
            return OKT_LCD + "auth/accounts/" + address
        }
        return ""
    }
    
    static func lcdOktDepositUrl(_ address: String) -> String {
        return OKT_LCD + "staking/delegators/" + address
    }
    
    static func lcdOktWithdrawUrl(_ address: String) -> String {
        return OKT_LCD + "staking/delegators/" + address + "/unbonding_delegations"
    }
    
    static func lcdOktTokenUrl() -> String {
        return OKT_LCD + "tokens"
    }
    
    static func lcdOktValidatorsUrl() -> String {
        return OKT_LCD + "staking/validators"
    }
    
    static func broadcastUrl(_ chain: BaseChain) -> String {
        if (chain is ChainOkt996Keccak) {
            return OKT_LCD + "txs"
        }
        return ""
    }
    
    
    static func swapIdBep3Url(_ toChain: BaseChain, _ id: String) -> String {
        if (toChain.tag.starts(with: "kava")) {
            return KAVA_LCD + "kava/bep3/v1beta1/atomicswap/" + id
        }
        return ""
    }
}

