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
        if (!BaseData.instance.needPriceUpdate()) {
            return
        }
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
    }
    
    func fetchAssets() {
        print("fetchAssets Start ", BaseNetWork.getMintscanAssetsUrl())
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
    
//    func fetchAssets() {
//        AF.request(BaseNetWork.getMintscanAssetsUrl(), method: .get)
//            .responseDecodable(of: JSON.self) { response in
//            switch response.result {
//            case .success(let value):
////                BaseData.instance.prices = value
////                BaseData.instance.setLastPriceTime()
////                let assets = value["assets"] as? [JSON]
//                let aaa = value["assets"].arrayValue
//                value["assets"].arrayValue
//
//            case .failure:
//                print("onFetchPriceInfo error")
//            }
//            NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
//        }
//    }
    
    
    
    
    
    static func getPricesUrl() -> String {
        let currency = BaseData.instance.getCurrencyString().lowercased()
        return MINTSCAN_API_URL + "v2/utils/market/prices?currency=" + currency
    }
    
    static func getMintscanAssetsUrl() -> String {
        return MINTSCAN_API_URL + "v3/assets"
    }
}
