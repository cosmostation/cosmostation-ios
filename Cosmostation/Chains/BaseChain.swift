//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation


class BaseChain {
    var name: String!
    var id: String!
    var logo1: String!
    var logo2: String!
    var isDefault = true
    var apiName: String!
    var accountPrefix: String?
    
    
    var accountKeyType: AccountKeyType!
    var privateKey: Data?
    var publicKey: Data?
    var address: String?
    
    
    var fetched = false
    var allValue: NSDecimalNumber?
    var allUSDValue: NSDecimalNumber?
    
    
    
    
    func getHDPath(_ lastPath: String) -> String {
        return accountKeyType.hdPath.replacingOccurrences(of: "X", with: lastPath)
    }
    
    func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        address = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, accountPrefix)
    }
    
    func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        address = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, accountPrefix)
    }
    
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if (usd == true) {
            guard let allUsdVlaue = allUSDValue else {
                return NSDecimalNumber.zero
            }
            return allUsdVlaue
            
        } else {
            guard let allValue = allValue else {
                return NSDecimalNumber.zero
            }
            return allValue
        }
    }
}



struct AccountKeyType {
    var pubkeyType: PubKeyType!
    var hdPath: String!
    
    init(_ pubkeyType: PubKeyType!, _ hdPath: String!) {
        self.pubkeyType = pubkeyType
        self.hdPath = hdPath
    }
}

enum PubKeyType: Int {
    case ETH_Keccak256 = 0
    case COSMOS_Secp256k1 = 1
    case SUI_Ed25519 = 2
    case unknown = 99
}
