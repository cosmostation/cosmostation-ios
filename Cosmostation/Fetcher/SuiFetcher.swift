//
//  SuiFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/1/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SuiFetcher {
    
    var chain: BaseChain!
    
    var suiSystem = JSON()
    var suiBalances = Array<(String, NSDecimalNumber)>()
    var suiStakedList = [JSON]()
    var suiObjects = [JSON]()
    var suiValidators = [JSON]()
    var suiCoinMeta: [String: JSON] = [:]
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    
    func fetchSuiData(_ id: Int64) async -> Bool {
        
        suiSystem = JSON()
        suiBalances.removeAll()
        suiStakedList.removeAll()
        suiObjects.removeAll()
        suiValidators.removeAll()
        suiCoinMeta.removeAll()
        
        do {
            if let chainidentifier = try await fetchChainId(),
               let latestSuiSystemState = try await fetchSystemState(),
               let ownedObjects = try? await fetchOwnedObjects(chain.mainAddress),
               let stakes = try? await fetchStakes(chain.mainAddress) {
                
                suiSystem = latestSuiSystemState["result"]
                suiSystem["activeValidators"].arrayValue.forEach { validator in
                    suiValidators.append(validator)
                }
                suiValidators.sort {
                    if ($0["name"].stringValue == "Cosmostation") { return true }
                    if ($1["name"].stringValue == "Cosmostation") { return false }
                    return $0["votingPower"].intValue > $1["votingPower"].intValue ? true : false
                }
                
                //TODO check page
                ownedObjects?["result"]["data"].arrayValue.forEach({ data in
                    suiObjects.append(data["data"])
                })
                suiObjects.forEach { object in
                    let type = object["type"].stringValue
                    if (type.starts(with: SUI_TYPE_COIN)) {
                        if let index = suiBalances.firstIndex(where: { $0.0 == type }) {
                            let alreadyAmount = suiBalances[index].1
                            let sumAmount = alreadyAmount.adding(NSDecimalNumber.init(string:  object["content"]["fields"]["balance"].stringValue))
                            suiBalances[index] = (type, sumAmount)
                        } else {
                            let newAmount = NSDecimalNumber.init(string:  object["content"]["fields"]["balance"].stringValue)
                            suiBalances.append((type, newAmount))
                        }
                    }
                }
                suiBalances.sort {
                    if ($0.0 == SUI_MAIN_DENOM) { return true }
                    if ($1.0 == SUI_MAIN_DENOM) { return false }
                    return false
                }
                
                stakes?["result"].arrayValue.forEach({ stake in
                    suiStakedList.append(stake)
                })
                
                await suiBalances.concurrentForEach { type, balance in
                    if let metadata = try? await self.fetchCoinMetadata(type) {
                        self.suiCoinMeta[type] = metadata?["result"]
                    }
                }
            }
            return true
            
        } catch {
            print("sui error \(error) ", chain.tag)
            return false
        }
    }
    
    
    func getSuiRpc() -> String {
        return chain.mainUrl
    }
}


extension SuiFetcher {
    
    func fetchChainId() async throws -> JSON? {
        let parameters: Parameters = ["method": "sui_getChainIdentifier", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchSystemState() async throws -> JSON? {
        let parameters: Parameters = ["method": "suix_getLatestSuiSystemState", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchOwnedObjects(_ address: String) async throws -> JSON? {
        let params: Any = [address, ["filter": nil, "options":["showContent":true, "showDisplay":true,  "showType":true]]]
        let parameters: Parameters = ["method": "suix_getOwnedObjects", "params": params, "id" : 1, "jsonrpc" : "2.0"]
//        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        
        if let result = try? await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value {
            
        }
        return nil
    }
    
    func fetchStakes(_ address: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "suix_getStakes", "params": [address], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchCoinMetadata(_ type: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "suix_getCoinMetadata", "params": [type], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
}
