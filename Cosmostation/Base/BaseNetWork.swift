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
        #if !DEBUG
        if (!BaseData.instance.needChainParamUpdate()) { return }
        #endif
        AF.request(BaseNetWork.msChainParams(), method: .get)
            .responseDecodable(of: JSON.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    BaseData.instance.mintscanChainParams = value
                    BaseData.instance.setLastChainParamTime()
                case .failure:
                    print("fetchChainParams error ", response.error)
                }
                NotificationCenter.default.post(name: Notification.Name("FetchParam"), object: nil, userInfo: nil)
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
            return MINTSCAN_API_URL + "v10/" + chain.apiName + "/proxy/okx/account/" + address + "/txs"
        } else if (!chain.supportCosmos && chain.supportEvm) {
            return MINTSCAN_API_URL + "v10/" + chain.apiName + "/proxy/okx/account/" + address + "/txs"
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
    
    static func msCw20InfoUrl(_ apiName: String) -> String {
        return MINTSCAN_API_URL + "v10/assets/" +  apiName + "/cw20/info"
    }
    
    static func msErc20InfoUrl(_ chain: BaseChain) -> String {
        return MINTSCAN_API_URL + "v10/assets/" +  chain.apiName + "/erc20/info"
    }
    
    static func msErc20InfoUrl(_ apiName: String) -> String {
        return MINTSCAN_API_URL + "v10/assets/" +  apiName + "/erc20/info"
    }
    
    static func msChainParams() -> String {
        return MINTSCAN_API_URL + "v10/utils/params"
    }
    
    static func msCw721InfoUrl(_ chain: BaseChain) -> String {
        return ResourceBase + chain.apiName + "/cw721.json"
    }
    
    static func msCw721InfoUrl(_ apiName: String) -> String {
        return ResourceBase + apiName + "/cw721.json"
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
    
    static func msNftDetail(_ apiName: String, _ contractAddress: String, _ tokenId: String) -> String {
        return MINTSCAN_API_URL + "v10/" + apiName + "/contracts/" + contractAddress + "/nft-url/" + tokenId
    }
    
    static func getPushStatus(_ fcmToken: String) -> String {
        return MINTSCAN_API_URL + "v10/notification?pushToken=" + fcmToken
    }
    
    static func setPushStatus() -> String {
        return MINTSCAN_API_URL + "v10/notification"
    }
    
    static func SkipChains() -> String {
//        return SKIP_API_URL + "v2/info/chains?include_evm=true"
        return SKIP_API_URL + "v2/info/chains"
    }
    
    static func SkipAsset(_ baseChain: BaseChain) -> String {
//        return SKIP_API_URL + "v2/fungible/assets?chain_ids=" + baseChain.chainIdForSwap + "&include_cw20_assets=true&include_evm_assets=true"
        return SKIP_API_URL + "v2/fungible/assets?chain_ids=" + baseChain.chainIdForSwap
    }
    
    static func SkipAssets() -> String {
//        return SKIP_API_URL + "v2/fungible/assets?include_cw20_assets=true&include_evm_assets=true"
        return SKIP_API_URL + "v2/fungible/assets"
    }
    
    static func SkipRoutes() -> String {
        return SKIP_API_URL + "v2/fungible/route"
    }
    
    static func SkipMsg() -> String {
        return SKIP_API_URL + "v2/fungible/msgs"
    }
    
    static func SquidChains() -> String {
        return SQUID_API_URL + "chains"
    }
    
    static func SquidAsset(_ chainId: String) -> String {
        return SQUID_API_URL + "tokens?chainId=" + chainId
    }
}

