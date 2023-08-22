//
//  BaseAccount.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import GRPC
import NIO

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
    
    
    var cosmosClassChains = [CosmosClass]()
    
    func setAllcosmosClassChains() -> [CosmosClass] {
        cosmosClassChains.removeAll()
//        cosmosClassChains.append(ChainCosmos())
        cosmosClassChains.append(ChainAkash())
//        cosmosClassChains.append(ChainEvmos())
//        cosmosClassChains.append(ChainKava459())
//        cosmosClassChains.append(ChainKava60())
//        cosmosClassChains.append(ChainKava118())
//        cosmosClassChains.append(ChainJuno())
        return cosmosClassChains
    }
    
    func setAddressInfo() -> Bool {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                cosmosClassChains.forEach { chain in
                    Task {
                        chain.setInfoWithSeed(seed, lastHDPath)
                        chain.fetchData()
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                cosmosClassChains.forEach { chain in
                    Task {
                        chain.setInfoWithPrivateKey(secureKey!.hexadecimal!)
                        chain.fetchData()
                    }
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
