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
            let param = await getPushInfo(enable, token).dictionaryRepresentation
            let url = BaseNetWork.setPushStatus()
//            print("param ", param)
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
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
            "wallets" : wallets.map({ wallet in
                wallet.dictionaryRepresentation
            })
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
            "accounts" : accounts.map({ accuont in
                accuont.dictionaryRepresentation
            })
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
