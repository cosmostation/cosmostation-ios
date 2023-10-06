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
    
    lazy var toDisplayCTags = [String]()
    lazy var allCosmosClassChains = [CosmosClass]()
    
    func initAccount() {
        toDisplayCTags = BaseData.instance.getDisplayCosmosChainTags(self.id)
        allCosmosClassChains = ALLCOSMOSCLASS()
        sortCosmosChains()
    }
    
    func getDisplayCosmosChains() -> [CosmosClass] {
        return allCosmosClassChains.filter { cosmosChain in
            toDisplayCTags.contains(cosmosChain.tag)
        }
    }
    
    func fetchDisplayCosmosChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                getDisplayCosmosChains().forEach { chain in
                    Task {
                        if (chain.address == nil) {
                            chain.setInfoWithSeed(seed, lastHDPath)
                        }
                        chain.fetchData(id)
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                getDisplayCosmosChains().forEach { chain in
                    Task {
                        if (chain.address == nil) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        chain.fetchData(id)
                    }
                }
            }
        }
    }
    
    func fetchAllCosmosChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                allCosmosClassChains.forEach { chain in
                    Task {
                        if (chain.address == nil) {
                            chain.setInfoWithSeed(seed, lastHDPath)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                allCosmosClassChains.forEach { chain in
                    Task {
                        if (chain.address == nil) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(id)
                        }
                    }
                }
            }
        }
    }
    
    func updateAllValue() {
        getDisplayCosmosChains().forEach { chain in
            chain.allCoinValue = chain.allCoinValue()
            chain.allCoinUSDValue = chain.allCoinValue(true)
            chain.allTokenValue = chain.allTokenValue()
            chain.allTokenUSDValue = chain.allTokenValue(true)
        }
    }
    
    func sortCosmosChains() {
        allCosmosClassChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            return $0.allCoinUSDValue.compare($1.allCoinUSDValue).rawValue > 0 ? true : false
        }
        allCosmosClassChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            if (toDisplayCTags.contains($0.tag) == true && toDisplayCTags.contains($1.tag) == false) { return true }
            return false
        }
    }
}

extension BaseAccount {
    
    func initOnyKeyData() async -> [CosmosClass] {
        allCosmosClassChains.removeAll()
        
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            ALLCOSMOSCLASS().forEach { chain in
                allCosmosClassChains.append(chain)
            }
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                allCosmosClassChains.forEach { chain in
                    chain.setInfoWithSeed(seed, lastHDPath)
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            ALLCOSMOSCLASS().filter({ $0.isDefault == true }).forEach { chain in
                allCosmosClassChains.append(chain)
            }
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
