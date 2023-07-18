//
//  Mnemonic.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/04/19.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import HDWalletKit
import SwiftKeychainWrapper

public class MWords {
    var id: Int64 = -1;
    var uuid: String = "";
    var nickName: String = "";
    var wordsCnt: Int64 = 0;
    var isFavo: Bool = false;
    var importTime:Int64 = -1;
    
    init (isNew: Bool) {
        uuid = UUID().uuidString
        importTime = Date().millisecondsSince1970
    }
    
    init (_ id: Int64, _ uuid: String, _ nickName: String, _ wordsCnt: Int64, _ isFavo: Bool, _ importTime: Int64) {
        self.id = id;
        self.uuid = uuid;
        self.nickName = nickName;
        self.wordsCnt = wordsCnt;
        self.isFavo = isFavo;
        self.importTime = importTime;
    }
    
//    func getWords() -> String {
//        if let words = KeychainWrapper.standard.string(forKey: self.uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
//            return words
//        }
//        return ""
//    }
//    
//    func getMnemonicWords() -> Array<String> {
//        return getWords().components(separatedBy: " ")
//    }
//    
//    func getName() -> String {
//        if (self.nickName == "") {
//            return "Account " + String(id)
//        }
//        return nickName
//    }
//    
//    func getLinkedWalletCnt() -> Int {
//        return BaseData.instance.selectAccountsByMnemonic(id).count
//    }
//    
//    func getWordsCnt() -> Int {
//        return getWords().components(separatedBy: " ").count
//    }
//    
//    func getImportDate() -> String {
//        return WDP.dpTime(importTime)
//    }
//    
//    func getMasterKey() -> PrivateKey {
//        return PrivateKey(seed: Mnemonic.createSeed(mnemonic: getWords()), coin: .bitcoin)
//    }
}
