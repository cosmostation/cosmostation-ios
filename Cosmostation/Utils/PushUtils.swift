//
//  PushUtils.swift
//  ios
//
//  Created by Naver on 2018. 7. 20..
//  Copyright © 2018년 snorose. All rights reserved.
//

import Foundation
import Alamofire

class PushUtils {
    static let shared = PushUtils()
    
    func updateTokenIfNeed(token: String) {
//        if token != UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) {
//            UserDefaults.standard.set(token, forKey: KEY_FCM_TOKEN)
//            UserDefaults.standard.synchronize()
//            guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
//            Alamofire.request("\(WALLET_API_PUSH_STATUS_URL)/\(token)", method: .get).response { response in
//                if (response.error != nil || response.response?.statusCode != 200) {
//                    self.updateStatus(enable: false)
//                } else {
//                    self.sync()
//                }
//            }
//        }
    }
    
    func updateStatus(enable: Bool) {
        if (enable) {
            sync()
        }
        
        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
        let parameters: Parameters = ["fcm_token": token, "subscribe": enable]
        Alamofire.request(WALLET_API_PUSH_STATUS_URL, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
            if let error = response.error {
                print("push status update error : ", error)
            }
        }
    }
    
//    func sync() {
//        let accounts = BaseData.instance.selectAllAccounts().filter { account in
//            account.account_has_private
//        }.map { account in
//            ["address": account.account_address,"chain": ChainFactory.getChainConfig(ChainFactory.getChainType(account.account_base_chain))!.chainAPIName]
//        }
//        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
//        let parameters: Parameters = ["fcm_token": token, "accounts": accounts]
//        Alamofire.request(WALLET_API_SYNC_PUSH_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
//            if let error = response.error {
//                print("push address sync error : ", error)
//            }
//        }
//    }
}
