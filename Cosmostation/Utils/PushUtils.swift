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
//        if token != UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) {
//            UserDefaults.standard.set(token, forKey: KEY_FCM_TOKEN)
//            UserDefaults.standard.synchronize()
//            guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
//            AF.request("\(WALLET_API_PUSH_STATUS_URL)/\(token)", method: .get).response { response in
//                if (response.error != nil || response.response?.statusCode != 200) {
//                    self.updateStatus(enable: false)
//                } else {
//                    self.sync()
//                }
//            }
//        }
        if token != BaseData.instance.getFCMToken() {
            
        }
    }
    
    func getStatus() async throws -> JSON {
//        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return JSON() }
//        return try await AF.request("\(WALLET_API_PUSH_STATUS_URL)/\(token)", method: .get).serializingDecodable(JSON.self).value
//        let token = BaseData.
//        return JSON()
        
        guard let fcmToken = BaseData.instance.getFCMToken() else { return JSON() }
        let url = BaseNetWork.getPushStatus(fcmToken)
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func updateStatus(enable: Bool) {
//        if (enable) {
//            sync()
//        }
//        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
//        let parameters: Parameters = ["fcm_token": token, "subscribe": enable]
//        AF.request(WALLET_API_PUSH_STATUS_URL, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
//            if let error = response.error {
//                print("push status update error : ", error)
//            }
//        }
    }
    
    func updatePushInfo() async {
//        guard let account = BaseData.instance.baseAccount else { return }
//        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
//        if (account.getDisplayCosmosChains().count > 0) {
//            let addresses = account.getDisplayCosmosChains().map { chain in
//                ["address": chain.bechAddress, "chain": chain.apiName]
//            }
//            let parameters: Parameters = ["fcm_token": token, "accounts": addresses]
//            AF.request(WALLET_API_SYNC_PUSH_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
//                if let error = response.error {
//                    print("push address sync error : ", error)
//                }
//            }
//        }
    }
    
    
    func getPushInfo() async -> PushInfo {
        var pushInfo = PushInfo()
        var pushWallet = [PushWallet]()
        await BaseData.instance.selectAccounts().concurrentForEach { account in
            let wallet = await self.getPushWallet(account)
            pushWallet.append(wallet)
        }
        pushInfo.wallets = pushWallet
        return pushInfo
    }
    
    func getPushWallet(_ account: BaseAccount) async -> PushWallet {
        var pushWallet = PushWallet()
        var pushAccounts = [PushAccount]()
        await account.initAllKeys().forEach { chain in
            if (chain.isCosmos()) {
                let pushAccount = PushAccount(chain.chainIdCosmos!, chain.bechAddress!)
                pushAccounts.append(pushAccount)
            } else if (chain.supportEvm) {
                let pushAccount = PushAccount(chain.chainIdEvm!, chain.evmAddress!)
                pushAccounts.append(pushAccount)
            }
        }
        pushWallet.walletName = account.name
        pushWallet.walletKey = String(account.id)
        pushWallet.accounts = pushAccounts
        return pushWallet
    }
}


public struct PushInfo {
    var pushToken: String = String()
    var enable: Bool = Bool()
    var wallets: [PushWallet] = [PushWallet]()
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "pushToken" : pushToken,
            "enable" : enable,
            "wallets" : wallets
        ]
    }
}

public struct PushWallet {
    var walletName: String = String()
    var walletKey: String = String()
    var accounts: [PushAccount] = [PushAccount]()
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "walletName" : walletName,
            "walletKey" : walletKey,
            "accounts" : accounts
        ]
    }
}

public struct PushAccount {
    var chain: String = String()
    var address: String = String()
    
    init(_ chain: String, _ address: String) {
        self.chain = chain
        self.address = address
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "chain" : chain,
            "address" : address
        ]
    }
}
