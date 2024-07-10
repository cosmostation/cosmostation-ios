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
        BaseData.instance.setFCMToken(token)
    }
    
    func getStatus() async throws -> JSON {
        guard let fcmToken = BaseData.instance.getFCMToken() else { return JSON() }
        let url = BaseNetWork.getPushStatus(fcmToken)
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func updateStatus(enable: Bool, _ completion: @escaping (Bool, String) -> ()) {
        guard let token = BaseData.instance.getFCMToken() else {
            BaseData.instance.setPushNoti(false)
            completion(false, "Not FCM Token.")
            return
        }
        
        Task {
            let paramsss = await getPushInfo(enable, token).dictionaryRepresentation
            let url = BaseNetWork.setPushStatus()
//            print("param ", paramsss)
            let param = try! JSONSerialization.jsonObject(with: paramsss.rawData(), options: .allowFragments) as? [String: Any]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
//                print("response ", response)
                if let error = response.error {
                    BaseData.instance.setPushNoti(false)
                    completion(false, "\(error)")
                    return
                } else {
                    BaseData.instance.setPushNoti(enable)
                    BaseData.instance.setLastPushTime()
                    completion(true, "Push Notification Updated.")
                    return
                }
            }
        }
    }
    
    
    func getPushInfo(_ enable: Bool, _ fcmToken: String) async -> PushInfo {
        var pushInfo = PushInfo()
        var pushWallet = [PushWallet]()
        if (enable) {
            await BaseData.instance.selectAccounts().concurrentForEach { account in
                let wallet = await self.getPushWallet(account)
                pushWallet.append(wallet)
            }
        }
        pushInfo.pushToken = fcmToken
        pushInfo.enable = enable
        pushInfo.wallets = pushWallet
        return pushInfo
    }
    
    func getPushWallet(_ account: BaseAccount) async -> PushWallet {
        var pushWallet = PushWallet()
        var pushAccounts = [PushAccount]()
        
        await account.initAllKeys().filter { $0.isTestnet == false }.forEach { chain in
            if let chainname = chain.apiName {
                if (chain.isCosmos()) {
                    let pushAccount = PushAccount(chainname, chain.bechAddress!)
                    pushAccounts.append(pushAccount)
                } else if (chain.supportEvm) {
                    let pushAccount = PushAccount(chainname, chain.evmAddress!)
                    pushAccounts.append(pushAccount)
                }
            }
        }
        pushWallet.walletName = account.name
        pushWallet.walletKey = String(account.id) + account.uuid + String(account.id)
        pushWallet.accounts = pushAccounts
        return pushWallet
    }
}


public struct PushInfo {
    var pushToken: String = String()
    var enable: Bool = Bool()
    var wallets: [PushWallet] = [PushWallet]()
    
    var dictionaryRepresentation: JSON {
        var result = JSON()
        result["pushToken"].stringValue = pushToken
        result["enable"].boolValue = enable
        var rawWallets = [JSON]()
        wallets.forEach { wallet in
            rawWallets.append(wallet.dictionaryRepresentation)
        }
        result["wallets"].arrayObject = rawWallets
        return result
    }
}

public struct PushWallet {
    var walletName: String = String()
    var walletKey: String = String()
    var accounts: [PushAccount] = [PushAccount]()
    
    var dictionaryRepresentation: JSON {
        var result = JSON()
        result["walletName"].stringValue = walletName
        result["walletKey"].stringValue = walletKey
        var rawAccounts = [JSON]()
        accounts.forEach { account in
            rawAccounts.append(account.dictionaryRepresentation)
        }
        result["accounts"].arrayObject = rawAccounts
        return result
    }
}

public struct PushAccount {
    var chain: String = String()
    var address: String = String()
    
    init(_ chain: String, _ address: String) {
        self.chain = chain
        self.address = address
    }
    
    var dictionaryRepresentation: JSON {
        return [
            "chain" : chain,
            "address" : address
        ]
    }
}
