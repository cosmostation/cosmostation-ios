//
//  PushUtils.swift
//  ios
//
//  Created by Naver on 2018. 7. 20..
//  Copyright © 2018년 snorose. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PushUtils {
    static let shared = PushUtils()
    
    func updateTokenIfNeed(token: String) {
        if token != UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) {
            UserDefaults.standard.set(token, forKey: KEY_FCM_TOKEN)
            UserDefaults.standard.synchronize()
            guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
            AF.request("\(WALLET_API_PUSH_STATUS_URL)/\(token)", method: .get).response { response in
                if (response.error != nil || response.response?.statusCode != 200) {
                    self.updateStatus(enable: false)
                } else {
                    self.sync()
                }
            }
        }
    }
    
    func getStatus() async throws -> JSON {
        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return JSON() }
        return try await AF.request("\(WALLET_API_PUSH_STATUS_URL)/\(token)", method: .get).serializingDecodable(JSON.self).value
    }
    
    func updateStatus(enable: Bool) {
        if (enable) {
            sync()
        }
        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
        let parameters: Parameters = ["fcm_token": token, "subscribe": enable]
        AF.request(WALLET_API_PUSH_STATUS_URL, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
            if let error = response.error {
                print("push status update error : ", error)
            }
        }
    }
    
    func sync() {
        guard let account = BaseData.instance.baseAccount else { return }
        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
        if (account.getDisplayCosmosChains().count > 0) {
            let addresses = account.getDisplayCosmosChains().map { chain in
                ["address": chain.bechAddress, "chain": chain.apiName]
            }
            let parameters: Parameters = ["fcm_token": token, "accounts": addresses]
            AF.request(WALLET_API_SYNC_PUSH_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
                if let error = response.error {
                    print("push address sync error : ", error)
                }
            }
        }
    }
}
