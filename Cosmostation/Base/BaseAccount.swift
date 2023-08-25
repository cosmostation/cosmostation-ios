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
    var lastHDPath = ""
    
    //using for generate new aacount
    init(_ name: String, _ type: BaseAccountType, _ lastPath: String) {
        self.uuid = UUID().uuidString
        self.name = name
        self.type = type
        self.lastHDPath = lastPath
    }
    
    //db query
    init(_ id: Int64, _ uuid: String, _ name: String, _ type: Int64, _ lastPath: String) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.type = BaseAccountType(rawValue: type)!
        self.lastHDPath = lastPath
    }
    
    var allCosmosClassChains = [CosmosClass]()
    
    /*
     Too Heavy Job
     */
    func initData(_ fetchAll: Bool? = false) {
        allCosmosClassChains.removeAll()
        ALLCOSMOSCLASS().forEach { chain in
            allCosmosClassChains.append(chain)
        }
        
        let keychain = BaseData.instance.getKeyChain()
        let toDisplayCosmosChainNames = BaseData.instance.getDisplayCosmosChainNames(self)
        
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                allCosmosClassChains.forEach { chain in
                    Task {
                        chain.setInfoWithSeed(seed, lastHDPath)
                        if (fetchAll == true || toDisplayCosmosChainNames.contains(chain.id)) {
                            chain.fetchAuth()
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                allCosmosClassChains.forEach { chain in
                    Task {
                        chain.setInfoWithPrivateKey(secureKey!.hexadecimal!)
                        if (fetchAll == true || toDisplayCosmosChainNames.contains(chain.id)) {
                            chain.fetchAuth()
                        }
                    }
                }
            }
        }
    }
    
    func sortCosmosChain() {
        allCosmosClassChains.sort {
            return $0.allValue().compare($1.allValue()).rawValue > 0 ? true : false
        }
    }
}


public enum BaseAccountType: Int64 {
    case withMnemonic = 0
    case onlyPrivateKey = 1
    case none = 2
}
