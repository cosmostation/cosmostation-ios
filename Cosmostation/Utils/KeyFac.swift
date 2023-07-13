//
//  KeyFac.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/08.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

class KeyFac {
    
//    static func getPrivateKeyDataFromSeed(_ seed: Data, _ fullpath: String) -> Data {
//        if (BaseData.instance.getUsingEnginerMode()) {
//            return CKey.getPrivateKeyDataFromSeed(seed, fullpath)
//        } else {
//            return WKey.getPrivateKeyDataFromSeed(seed, fullpath)
//        }
//    }
//    
//    
//    
//    static func getPrivateRaw(_ mnemonic: [String], _ account: Account) -> Data {
//        if (BaseData.instance.getUsingEnginerMode()) {
//            return CKey.getPrivateRaw(mnemonic, account)
//        } else {
//            return WKey.getPrivateRaw(mnemonic, account)
//        }
//    }
//    
//    static func getPublicRaw(_ mnemonic: [String], _ account: Account) -> Data {
//        if (BaseData.instance.getUsingEnginerMode()) {
//            return CKey.getPublicRaw(mnemonic, account)
//        } else {
//            return WKey.getPublicRaw(mnemonic, account)
//        }
//    }
//    
//    static func isValidStringPrivateKey(_ input: String) -> Bool {
//        let pKeyRegEx = "^(0x|0X)?[a-fA-F0-9]{64}"
//        let pKeyPred = NSPredicate(format:"SELF MATCHES %@", pKeyRegEx)
//        return pKeyPred.evaluate(with: input)
//    }
//    
//    static func getPrivateFromString(_ hexInput: String) -> Data {
//        if (hexInput.starts(with: "0x") || hexInput.starts(with: "0X")) {
//            return hexInput.substring(from: 2).hexadecimal!
//        }
//        return hexInput.hexadecimal!
//    }
//    
//    static func getPublicFromStringPrivateKey(_ hexInput: String) -> Data {
//        let privateKey = getPrivateFromString(hexInput)
//        return getPublicFromPrivateKey(privateKey)
//    }
//    
//    static func getPublicFromPrivateKey(_ dataInput: Data) -> Data {
//        return WKey.getPublicFromPrivateKey(dataInput)
//    }
    
}
