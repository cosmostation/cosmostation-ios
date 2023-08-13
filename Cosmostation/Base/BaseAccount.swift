//
//  BaseAccount.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

public class BaseAccount {
    var id: Int64 = -1
    var uuid: String = ""
    var name: String = ""
    var type: BaseAccountType = .none
    
    //using for generate new aacount
    init(_ name: String, _ type: BaseAccountType) {
        self.uuid = UUID().uuidString
        self.name = name
        self.type = type
    }
    
    //db query
    init(_ id: Int64, _ uuid: String, _ name: String, _ type: Int64) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.type = BaseAccountType(rawValue: type)!
    }
    
    
    var activeChains = [BaseChain]()
    
    func setActiveChains() {
        activeChains.removeAll()
        activeChains.append(ChainCosmos())
        activeChains.append(ChainKava())
        activeChains.append(ChainKava_Legacy())
    }
    
    func setPrivateKeys() -> Data? {
        setActiveChains()
        
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()) {
                let seed = secureData?.components(separatedBy: ":").last?.data(using: .utf8)
                activeChains.forEach { chain in
//                    chain.privateKey =
                }
                
            }

        } else if (type == .onlyPrivateKey) {
            if let key = try? keychain.getString(uuid.sha1()) {
                activeChains.forEach { chain in
                    chain.privateKey = key!.data(using: .utf8)!
                }
            }
        }
        return nil
    }
    
    
}


public enum BaseAccountType: Int64 {
    case withMnemonic = 0
    case onlyPrivateKey = 1
    case none = 2
}
