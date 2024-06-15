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
    
    
    var allChains = [BaseChain]()
    var dpTags = [String]()
    
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
    
//    lazy var toDisplayCTags = [String]()
//    lazy var allCosmosClassChains = [CosmosClass]()
//    
//    lazy var toDisplayETags = [String]()
//    lazy var allEvmClassChains = [EvmClass]()
    
    func getRefreshName() -> String {
        self.name = BaseData.instance.selectAccount(id)?.name ?? ""
        return self.name
    }
    
//    func loadDisplayCTags() {
//        toDisplayCTags = BaseData.instance.getDisplayCosmosChainTags(self.id)
//    }
//    
//    func loadDisplayETags() {
//        toDisplayETags = BaseData.instance.getDisplayEvmChainTags(self.id)
//    }
    
    func loadDisplayTags() {
        dpTags = BaseData.instance.getDisplayCosmosChainTags(self.id)
    }
    
    func initAccount() {
//        loadDisplayETags()
//        loadDisplayCTags()
        loadDisplayTags()
//        print("initAccount ", dpTags.count)
        
        if (type == .onlyPrivateKey) {
            allChains = ALLCHAINS()
        } else {
            allChains = ALLCHAINS()
        }
        
        //YONG4 value
        allChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            return false
        }
        initSortChains()
        
//        allChains = ALLCHAINS(onlymainnet: false, onlydefault: false)
//        if (type == .onlyPrivateKey) {
//            allCosmosClassChains = ALLCOSMOSCLASS().filter({ $0.isDefault == true || $0.tag == "okt996_Secp"})
//        }
//        initSortCosmosChains()
//        
//        allEvmClassChains = ALLEVMCLASS()
//        initSortEvmChains()
        
    }
    
    func getDisplayChains() -> [BaseChain] {
        return allChains.filter { chain in
            dpTags.contains(chain.tag)
        }
    }
    
//    func initKeys() async -> ([EvmClass], [CosmosClass]) {
//        var evmResult = [EvmClass]()
//        var cosmosResult = [CosmosClass]()
//        let keychain = BaseData.instance.getKeyChain()
//        if (type == .withMnemonic) {
//            ALLEVMCLASS().forEach { chain in
//                evmResult.append(chain)
//            }
//            ALLCOSMOSCLASS().forEach { chain in
//                cosmosResult.append(chain)
//            }
//            if let secureData = try? keychain.getString(uuid.sha1()),
//               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
//                evmResult.forEach { chain in
//                    if (chain.evmAddress.isEmpty) {
//                        chain.setInfoWithSeed(seed, lastHDPath)
//                    }
//                }
//                cosmosResult.forEach { chain in
//                    if (chain.bechAddress.isEmpty) {
//                        chain.setInfoWithSeed(seed, lastHDPath)
//                    }
//                }
//            }
//            
//        } else if (type == .onlyPrivateKey) {
//            ALLEVMCLASS().forEach { chain in
//                evmResult.append(chain)
//            }
//            ALLCOSMOSCLASS().filter({ $0.isDefault == true }).forEach { chain in
//                cosmosResult.append(chain)
//            }
//            if let secureKey = try? keychain.getString(uuid.sha1()) {
//                evmResult.forEach { chain in
//                    if (chain.evmAddress.isEmpty) {
//                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
//                    }
//                }
//                cosmosResult.forEach { chain in
//                    if (chain.bechAddress.isEmpty) {
//                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
//                    }
//                }
//            }
//        }
//        return (evmResult, cosmosResult)
//    }
    
    func fetchDpChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task {
                    await getDisplayChains().concurrentForEach { chain in
                        if (chain.publicKey == nil) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await getDisplayChains().concurrentForEach { chain in
                        if (chain.publicKey == nil) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
        }
        
    }
    
    
    func fetchAllChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task {
                    await allChains.concurrentForEach { chain in
                        if (chain.publicKey == nil) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await allChains.concurrentForEach { chain in
                        if (chain.publicKey == nil) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
        }
    }
    
    
    func initSortChains() {
        allChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            let ref0 = BaseData.instance.selectRefAddress(id, $0.tag)?.lastUsdValue() ?? NSDecimalNumber.zero
            let ref1 = BaseData.instance.selectRefAddress(id, $1.tag)?.lastUsdValue() ?? NSDecimalNumber.zero
            return ref0.compare(ref1).rawValue > 0 ? true : false
        }
        allChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            if (dpTags.contains($0.tag) == true && dpTags.contains($1.tag) == false) { return true }
            return false
        }
    }
    
    func reSortChains() {
        allChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            return $0.allValue(true).compare($1.allValue(true)).rawValue > 0 ? true : false
        }
    }
    
    

    
    func updateAllValue() {
        getDisplayChains().forEach { chain in
            if let grpcFetcher = chain.grpcFetcher {
                chain.allCoinValue = grpcFetcher.allCoinValue()
                chain.allCoinUSDValue = grpcFetcher.allCoinValue(true)
                chain.allTokenValue = grpcFetcher.allTokenValue()
                chain.allTokenUSDValue = grpcFetcher.allTokenValue(true)
                
            } else if let evmFetcher = chain.evmFetcher {
                chain.allCoinValue = evmFetcher.allCoinValue()
                chain.allCoinUSDValue = evmFetcher.allCoinValue(true)
                chain.allTokenValue = evmFetcher.allTokenValue()
                chain.allTokenUSDValue = evmFetcher.allTokenValue(true)
            }
        }
    }
}

extension BaseAccount {
    
    /*
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
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                    
                }
            }
        }
    }
    
    func fetchBep3SupportChains(_ targetChains: [CosmosClass]) {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task {
                    await targetChains.concurrentForEach { chain in
                        if (chain.bechAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
    */
}

extension BaseAccount {
    /*
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
                Task {
                    await getDisplayEvmChains().concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await getDisplayEvmChains().concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
                Task {
                    await allEvmClassChains.concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithSeed(seed, self.lastHDPath)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                            chain.fetchData(self.id)
                        }
                    }
                }
            }

        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                Task {
                    await allEvmClassChains.concurrentForEach { chain in
                        if (chain.evmAddress.isEmpty) {
                            chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                        }
                        if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
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
     */
}

extension BaseAccount {
    
    /*
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
    
    func initKeyforCheck() async -> ([EvmClass], [CosmosClass]) {
        var evmResult = [EvmClass]()
        var cosmosResult = [CosmosClass]()
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            ALLEVMCLASS().forEach { chain in
                evmResult.append(chain)
            }
            ALLCOSMOSCLASS().forEach { chain in
                cosmosResult.append(chain)
            }
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                evmResult.forEach { chain in
                    if (chain.evmAddress.isEmpty) {
                        chain.setInfoWithSeed(seed, lastHDPath)
                    }
                }
                cosmosResult.forEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithSeed(seed, lastHDPath)
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            ALLEVMCLASS().forEach { chain in
                evmResult.append(chain)
            }
            ALLCOSMOSCLASS().filter({ $0.isDefault == true }).forEach { chain in
                cosmosResult.append(chain)
            }
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                evmResult.forEach { chain in
                    if (chain.evmAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                    }
                }
                cosmosResult.forEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                    }
                }
            }
        }
        return (evmResult, cosmosResult)
    }
    
    func fetchForPreCreate(_ seed: Data? = nil, _ privateKeyString: String? = nil) {
        if (type == .withMnemonic) {
            allEvmClassChains = ALLEVMCLASS()
            allCosmosClassChains = ALLCOSMOSCLASS()
            Task {
                await allEvmClassChains.concurrentForEach { chain in
                    if (chain.evmAddress.isEmpty) {
                        chain.setInfoWithSeed(seed!, self.lastHDPath)
//                        print("evmAddress ", chain.tag, "  ", chain.evmAddress)
                    }
                    if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                        chain.fetchPreCreate()
                    }
                }
            }
            
            Task {
                await allCosmosClassChains.concurrentForEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithSeed(seed!, self.lastHDPath)
//                        print("bechAddress ", chain.tag, "  ", chain.bechAddress)
                    }
                    if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                        chain.fetchPreCreate()
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            allEvmClassChains = ALLEVMCLASS()
            allCosmosClassChains = ALLCOSMOSCLASS().filter({ $0.isDefault == true || $0.tag == "okt996_Secp"})
            Task {
                await allEvmClassChains.concurrentForEach { chain in
                    if (chain.evmAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(privateKeyString!)!)
                    }
                    if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                        chain.fetchPreCreate()
                    }
                }
            }
            Task {
                await allCosmosClassChains.concurrentForEach { chain in
                    if (chain.bechAddress.isEmpty) {
                        chain.setInfoWithPrivateKey(Data.fromHex(privateKeyString!)!)
                    }
                    if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                        chain.fetchPreCreate()
                    }
                }
            }
        }
    }
     */
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
