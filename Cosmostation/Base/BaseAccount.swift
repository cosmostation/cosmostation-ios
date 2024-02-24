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
    var order: Int64 = 999
    
    //using for generate new aacount
    init(_ name: String, _ type: BaseAccountType, _ lastPath: String) {
        self.uuid = UUID().uuidString
        self.name = name
        self.type = type
        self.lastHDPath = lastPath
    }
    
    //db query
    init(_ id: Int64, _ uuid: String, _ name: String, _ type: Int64, _ lastPath: String, _ order: Int64) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.type = BaseAccountType(rawValue: type)!
        self.lastHDPath = lastPath
        self.order = order
    }
    
    lazy var toDisplayCTags = [String]()
    lazy var allCosmosClassChains = [CosmosClass]()
    
    lazy var toDisplayETags = [String]()
    lazy var allEvmClassChains = [EvmClass]()
    
    func getRefreshName() -> String {
        self.name = BaseData.instance.selectAccount(id)?.name ?? ""
        return self.name
    }
    
    func loadDisplayCTags() {
        toDisplayCTags = BaseData.instance.getDisplayCosmosChainTags(self.id)
    }
    
    func loadDisplayETags() {
        toDisplayETags = BaseData.instance.getDisplayEvmChainTags(self.id)
    }
    
    func initAccount() {
        loadDisplayETags()
        loadDisplayCTags()
        
        allCosmosClassChains = ALLCOSMOSCLASS()
        if (type == .onlyPrivateKey) {
            allCosmosClassChains = ALLCOSMOSCLASS().filter({ $0.isDefault == true || $0.tag == "okt996_Secp"})
        }
        initSortCosmosChains()
        
        allEvmClassChains = ALLEVMCLASS()
        initSortEvmChains()
    }
    

    
    func updateAllValue() {
        getDisplayCosmosChains().forEach { chain in
            chain.allCoinValue = chain.allCoinValue()
            chain.allCoinUSDValue = chain.allCoinValue(true)
            chain.allTokenValue = chain.allTokenValue()
            chain.allTokenUSDValue = chain.allTokenValue(true)
        }
    }
}

extension BaseAccount {
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
                Task {
                    await getDisplayCosmosChains().concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await getDisplayCosmosChains().concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
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
                Task {
                    await allCosmosClassChains.concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await allCosmosClassChains.concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                    
                }
            }
        }
    }
    
    func fetchTargetCosmosChains(_ targetChains: [CosmosClass]) {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task {
                    await targetChains.concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await targetChains.concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
        }
    }
    
    func initSortCosmosChains() {
        allCosmosClassChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            let ref0 = BaseData.instance.selectRefAddress(id, $0.tag)?.lastUsdValue() ?? NSDecimalNumber.zero
            let ref1 = BaseData.instance.selectRefAddress(id, $1.tag)?.lastUsdValue() ?? NSDecimalNumber.zero
            return ref0.compare(ref1).rawValue > 0 ? true : false
            
        }
        allCosmosClassChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            if (toDisplayCTags.contains($0.tag) == true && toDisplayCTags.contains($1.tag) == false) { return true }
            return false
        }
    }
    
    func reSortCosmosChains() {
        allCosmosClassChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            return $0.allValue(true).compare($1.allValue(true)).rawValue > 0 ? true : false
        }
    }
}

extension BaseAccount {
    func getDisplayEvmChains() -> [EvmClass] {
        return allEvmClassChains.filter { evmChain in
            toDisplayETags.contains(evmChain.tag)
        }
    }
    
    func fetchDisplayEvmChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task(priority: .high) {
                    await getDisplayEvmChains().concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task(priority: .high) {
                    await getDisplayEvmChains().concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
        }
    }
    
    func fetchAllEvmChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task(priority: .high) {
                    await allEvmClassChains.concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task(priority: .high) {
                    await allEvmClassChains.concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetched == false) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
        }
    }
    
    
    func initSortEvmChains() {
        allEvmClassChains.sort {
            if ($0.tag == "ethereum60") { return true }
            if ($1.tag == "ethereum60") { return false }
            let ref0 = BaseData.instance.selectRefAddress(id, $0.tag)?.lastUsdValue() ?? NSDecimalNumber.zero
            let ref1 = BaseData.instance.selectRefAddress(id, $1.tag)?.lastUsdValue() ?? NSDecimalNumber.zero
            return ref0.compare(ref1).rawValue > 0 ? true : false
            
        }
        allEvmClassChains.sort {
            if ($0.tag == "ethereum60") { return true }
            if ($1.tag == "ethereum60") { return false }
            if (toDisplayETags.contains($0.tag) == true && toDisplayETags.contains($1.tag) == false) { return true }
            return false
        }
    }
    
    func reSortEvmChains() {
        allEvmClassChains.sort {
            if ($0.tag == "ethereum60") { return true }
            if ($1.tag == "ethereum60") { return false }
            return $0.allValue(true).compare($1.allValue(true)).rawValue > 0 ? true : false
        }
    }
}

extension BaseAccount {
    
    func initKeysforSwap() async -> [CosmosClass] {
        var result = [CosmosClass]()
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            ALLCOSMOSCLASS().filter({ $0.isDefault == true }).forEach { chain in
                result.append(chain)
            }
            ALLEVMCLASS().filter({ $0.isDefault == true && $0.supportCosmos == true }).forEach { chain in
                result.append(chain)
            }
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                result.forEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithSeed(seed, lastHDPath)
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            ALLCOSMOSCLASS().filter({ $0.isDefault == true }).forEach { chain in
                result.append(chain)
            }
            ALLEVMCLASS().filter({ $0.isDefault == true && $0.supportCosmos == true }).forEach { chain in
                result.append(chain)
            }
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                result.forEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                    }
                }
            }
        }
        return result
    }
    
    func initOnyKeyData() async -> [CosmosClass] {
        var result = [CosmosClass]()
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            ALLCOSMOSCLASS().forEach { chain in
                result.append(chain)
            }
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                result.forEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithSeed(seed, lastHDPath)
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            ALLCOSMOSCLASS().filter({ $0.isDefault == true }).forEach { chain in
                result.append(chain)
            }
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                result.forEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                    }
                }
            }
        }
        return result
    }
    
    func fetchForPreCreate(_ seed: Data? = nil, _ privateKeyString: String? = nil) {
        if (type == .withMnemonic) {
            allEvmClassChains = ALLEVMCLASS()
            allCosmosClassChains = ALLCOSMOSCLASS()
            Task(priority: .high) {
                await allEvmClassChains.concurrentForEach { chain in
                    if (chain.evmAddress.isEmpty) {
                        chain.setInfoWithSeed(seed!, self.lastHDPath)
//                        print("evmAddress ", chain.tag, "  ", chain.evmAddress)
                    }
                    if (chain.fetched == false) {
                        chain.fetchPreCreate()
                    }
                }
                
                await allCosmosClassChains.concurrentForEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithSeed(seed!, self.lastHDPath)
//                        print("bechAddress ", chain.tag, "  ", chain.bechAddress)
                    }
                    if (chain.fetched == false) {
                        chain.fetchPreCreate()
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            allEvmClassChains = ALLEVMCLASS()
            allCosmosClassChains = ALLCOSMOSCLASS().filter({ $0.isDefault == true || $0.tag == "okt996_Secp"})
            Task(priority: .high) {
                await allEvmClassChains.concurrentForEach { chain in
                    if (chain.evmAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(privateKeyString!)!)
                    }
                    if (chain.fetched == false) {
                        chain.fetchPreCreate()
                    }
                }
                
                await allCosmosClassChains.concurrentForEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(privateKeyString!)!)
                    }
                    if (chain.fetched == false) {
                        chain.fetchPreCreate()
                    }
                }
            }
        }
    }
}


public enum BaseAccountType: Int64 {
    case withMnemonic = 0
    case onlyPrivateKey = 1
    case none = 2
}


extension Sequence {
    func concurrentForEach(
        _ operation: @escaping (Element) async -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
}
