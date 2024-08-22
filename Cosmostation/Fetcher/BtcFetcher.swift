//
//  BtcFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class BtcFetcher {
    
    var chain: BaseChain!
    
    let mempoolURL = "https://mempool.space/api/"
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchBtcBalances() async -> Bool {
        if let balance = try? await fetchBalance(chain.mainAddress) {
            print("balance ", balance)
        }
        return true
    }
    
    func fetchBtcData(_ id: Int64) async -> Bool {
        return true
    }
    
    
//    func fetchUtxos() async -> Bool {
//        
//    }
}




extension BtcFetcher {
    
    func fetchBalance(_ address: String) async throws -> JSON? {
        let url = mempoolURL + "address/" + address
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchUtxos(_ address: String) async throws -> JSON? {
        let url = mempoolURL + "address/" + address + "/utxo"
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
}
