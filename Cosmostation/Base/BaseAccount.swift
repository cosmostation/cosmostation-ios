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
    var lastHDPath = "0"
    
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
        activeChains.append(ChainKava459())
        activeChains.append(ChainKava60())
        activeChains.append(ChainKava118())
    }
    
    func setSecureInfo() -> Bool {
        setActiveChains()
        
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                activeChains.forEach { chain in
                    chain.setInfoWithSeed(seed, lastHDPath)
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                activeChains.forEach { chain in
                    chain.setInfoWithPrivateKey(secureKey!.hexadecimal!)
                }
            }
        }
        return true
    }
    
    
    
    
    
    
    
}


public enum BaseAccountType: Int64 {
    case withMnemonic = 0
    case onlyPrivateKey = 1
    case none = 2
}
