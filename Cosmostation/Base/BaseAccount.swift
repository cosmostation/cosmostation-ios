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
    
    lazy var allCosmosClassChains = [CosmosClass]()
    lazy var toDisplayCosmosChains = [CosmosClass]()
    
    /*
     Too Heavy Job
     */
    func initAllData() {
        allCosmosClassChains.removeAll()
        ALLCOSMOSCLASS().forEach { chain in
            allCosmosClassChains.append(chain)
        }
        
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                allCosmosClassChains.forEach { chain in
                    Task {
                        chain.setInfoWithSeed(seed, lastHDPath)
                        chain.fetchData()
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                allCosmosClassChains.forEach { chain in
                    Task {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        chain.fetchData()
                    }
                }
            }
        }
    }
    
    func initDisplayData() {
        toDisplayCosmosChains.removeAll()
        let toDisplayNames = BaseData.instance.getDisplayCosmosChainNames(self)
        toDisplayNames.forEach { chainId in
            if let toDisplayChain = ALLCOSMOSCLASS().filter({ $0.id == chainId }).first {
                toDisplayCosmosChains.append(toDisplayChain)
            }
        }
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                toDisplayCosmosChains.forEach { chain in
                    Task {
                        chain.setInfoWithSeed(seed, lastHDPath)
                        chain.fetchData()
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                toDisplayCosmosChains.forEach { chain in
                    Task {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        chain.fetchData()
                    }
                }
            }
        }
    }
    

    
    
    func updateAllValue() {
        toDisplayCosmosChains.forEach { chain in
            chain.setAllValue()
        }
    }
    
    func sortCosmosChain() {
        allCosmosClassChains.sort {
            if ($0.id == "cosmos118") { return true }
            if ($1.id == "cosmos118") { return false }
            return $0.allValue().compare($1.allValue()).rawValue > 0 ? true : false
        }
        let toDisplayNames = BaseData.instance.getDisplayCosmosChainNames(self)
        allCosmosClassChains.sort {
            if ($0.id == "cosmos118") { return true }
            if ($1.id == "cosmos118") { return false }
            if (toDisplayNames.contains($0.id) == true && toDisplayNames.contains($1.id) == false) { return true }
            return false
        }
    }
}

extension BaseAccount {
    
    func initOnyKeyData(_ chainId: Bool? = false) async -> [CosmosClass] {
        allCosmosClassChains.removeAll()
        ALLCOSMOSCLASS(chainId).forEach { chain in
            allCosmosClassChains.append(chain)
        }
        
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                allCosmosClassChains.forEach { chain in
                    chain.setInfoWithSeed(seed, lastHDPath)
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                allCosmosClassChains.forEach { chain in
                    chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                }
            }
        }
        return allCosmosClassChains
    }
}


public enum BaseAccountType: Int64 {
    case withMnemonic = 0
    case onlyPrivateKey = 1
    case none = 2
}
