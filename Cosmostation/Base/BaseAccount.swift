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
    
    func getRefreshName() -> String {
        self.name = BaseData.instance.selectAccount(id)?.name ?? ""
        return self.name
    }
    
    func loadDisplayTags() {
        dpTags = BaseData.instance.getDisplayChainTags(self.id)
    }
    
    func initAccount() {
        loadDisplayTags()
        allChains = ALLCHAINS()
        allChains.sort {
            if ($0.tag == "cosmos118") { return true }
            if ($1.tag == "cosmos118") { return false }
            return false
        }
        initSortChains()
    }
    
    func getDpChains() -> [BaseChain] {
        return allChains.filter { chain in
            dpTags.contains(chain.tag)
        }
    }
    
    //only derive address for service
    func initAllKeys() async -> [BaseChain] {
        let result = ALLCHAINS()
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                result.forEach { chain in
                    if (chain.publicKey == nil) {
                        chain.setInfoWithSeed(seed, lastHDPath)
                    }
                }
            }
            
        } else if (type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(uuid.sha1()) {
                result.forEach { chain in
                    if (chain.publicKey == nil) {
                        chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                    }
                }
            }
        }
        return result
    }
    
    //user seelcted to display chains feching full data from node
    func fetchDpChains() {
        let keychain = BaseData.instance.getKeyChain()
        if (type == .withMnemonic) {
            if let secureData = try? keychain.getString(uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                Task {
                    await getDpChains().concurrentForEach { chain in
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
                    await getDpChains().concurrentForEach { chain in
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
    
    //all chain fetching full data from node
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
    
    //all chain fetching only balance
    func fetchForPreCreate(_ seed: Data? = nil, _ privateKeyString: String? = nil) {
        allChains = ALLCHAINS()
        if (seed != nil) {
            Task {
                await allChains.concurrentForEach { chain in
                    if (chain.publicKey == nil) {
                        chain.setInfoWithSeed(seed!, self.lastHDPath)
                    }
                    if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                        chain.fetchBalances()
                    }
                }
            }
            
        } else if (privateKeyString != nil) {
            if !BaseData.instance.getHideLegacy() {
                self.allChains = self.allChains.filter { $0.isDefault || $0.tag == "kava459" }
            }
            Task {
                await allChains.concurrentForEach { chain in
                    if (chain.publicKey == nil) {
                        chain.setInfoWithPrivateKey(Data.fromHex(privateKeyString!)!)
                    }
                    if (chain.fetchState == .Idle || chain.fetchState == .Fail) {
                        chain.fetchBalances()
                    }
                }
            }
        }
    }
    
    func initSortChains() {
        let chainSort = UserDefaults.standard.string(forKey: KEY_CHAIN_SORT) ?? SortingType.value.rawValue
        if let sortType = SortingType(rawValue: chainSort) {
            switch sortType {
            case .name:
                allChains.sort {
                    if ($0.tag == "cosmos118") { return true }
                    if ($1.tag == "cosmos118") { return false }
                    return $0.name.lowercased() < $1.name.lowercased()
                }
                allChains.sort {
                    if ($0.tag == "cosmos118") { return true }
                    if ($1.tag == "cosmos118") { return false }
                    if (dpTags.contains($0.tag) == true && dpTags.contains($1.tag) == false) { return true }
                    return false
                }

            case .value:
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
        }
    }
    
    func reSortChains() {
        let chainSort = UserDefaults.standard.string(forKey: KEY_CHAIN_SORT) ?? SortingType.value.rawValue
        if let sortType = SortingType(rawValue: chainSort) {
            switch sortType {
            case .name:
                allChains.sort {
                    if ($0.tag == "cosmos118") { return true }
                    if ($1.tag == "cosmos118") { return false }
                    return $0.name < $1.name
                }

            case .value:
                allChains.sort {
                    if ($0.tag == "cosmos118") { return true }
                    if ($1.tag == "cosmos118") { return false }
                    return $0.allValue(true).compare($1.allValue(true)).rawValue > 0 ? true : false
                }
            }
        }
    }
    
    func updateAllValue() {
        allChains.forEach { chain in
            if let chain = chain as? ChainOktEVM {
                if let oktFetcher = chain.getOktfetcher(), let evmFetcher = chain.getEvmfetcher() {
                    chain.allCoinValue = oktFetcher.allCoinValue()
                    chain.allCoinUSDValue = oktFetcher.allCoinValue(true)
                    chain.allTokenValue = evmFetcher.allTokenValue(id)
                    chain.allTokenUSDValue = evmFetcher.allTokenValue(id, true)
                    
                } else if let oktFetcher = chain.getOktfetcher() {
                    chain.allCoinValue = oktFetcher.allCoinValue()
                    chain.allCoinUSDValue = oktFetcher.allCoinValue(true)
                    
                }
            } else if let cosmosFetcher = chain.getCosmosfetcher() {
                chain.allCoinValue = cosmosFetcher.allCoinValue()
                chain.allCoinUSDValue = cosmosFetcher.allCoinValue(true)
                chain.allTokenValue = cosmosFetcher.allTokenValue(id)
                chain.allTokenUSDValue = cosmosFetcher.allTokenValue(id, true)
                
            } else if let evmFetcher = chain.getEvmfetcher() {
                chain.allCoinValue = evmFetcher.allCoinValue()
                chain.allCoinUSDValue = evmFetcher.allCoinValue(true)
                chain.allTokenValue = evmFetcher.allTokenValue(id)
                chain.allTokenUSDValue = evmFetcher.allTokenValue(id, true)
                
            } else if let suiFetcher = (chain as? ChainSui)?.getSuiFetcher() {
                chain.allCoinValue = suiFetcher.allValue()
                chain.allCoinUSDValue = suiFetcher.allValue(true)
                
            } else if let iotaFetcher = (chain as? ChainIota)?.getIotaFetcher() {
                chain.allCoinValue = iotaFetcher.allValue()
                chain.allCoinUSDValue = iotaFetcher.allValue(true)
                
            } else if let btcFetcher = (chain as? ChainBitCoin86)?.getBtcFetcher() {
                chain.allCoinValue = btcFetcher.allValue()
                chain.allCoinUSDValue = btcFetcher.allValue(true)
                
            } else if let gnoFetcher = (chain as? ChainGno)?.getGnoFetcher() {
                chain.allCoinValue = gnoFetcher.allCoinValue()
                chain.allCoinUSDValue = gnoFetcher.allCoinValue(true)
                chain.allTokenValue = gnoFetcher.allTokenValue(id)
                chain.allTokenUSDValue = gnoFetcher.allTokenValue(id, true)
                
            } else if let solanaFetcher = (chain as? ChainSolana)?.getSolanaFetcher() {
                chain.allCoinValue = solanaFetcher.allCoinValue()
                chain.allCoinUSDValue = solanaFetcher.allCoinValue(true)
                chain.allTokenValue = solanaFetcher.allTokenValue()
                chain.allTokenUSDValue = solanaFetcher.allTokenValue(true)
            }
        }
    }
}

struct AccountKeyType {
    var pubkeyType: PubKeyType!
    var hdPath: String!
    
    init(_ pubkeyType: PubKeyType!, _ hdPath: String!) {
        self.pubkeyType = pubkeyType
        self.hdPath = hdPath
    }
}

public enum PubKeyType: Int {
    case ETH_Keccak256 = 0
    case COSMOS_Secp256k1 = 1
    case INJECTIVE_Secp256k1 = 2
    case BERA_Secp256k1 = 3
    case ARTELA_Keccak256 = 4
    case SUI_Ed25519 = 5
    case BTC_Legacy = 6
    case BTC_Nested_Segwit = 7
    case BTC_Native_Segwit = 8
    case BTC_Taproot = 9
    case STRATOS_Keccak256 = 10
    case INITIA_Keccak256 = 11
    case IOTA_Ed25519 = 12
    case COSMOS_EVM_Keccak256 = 13
    case SOLANA_Ed25519 = 14

    case unknown = 99
    
    var algorhythm: String? {
        switch self {
        case PubKeyType.ETH_Keccak256:
            return "keccak256"
        case PubKeyType.COSMOS_Secp256k1:
            return "secp256k1"
        case PubKeyType.INJECTIVE_Secp256k1:
            return "secp256k1"
        case PubKeyType.BERA_Secp256k1:
            return "secp256k1"
        case PubKeyType.ARTELA_Keccak256:
            return "keccak256"
        case PubKeyType.SUI_Ed25519:
            return "ed25519"
        case PubKeyType.BTC_Legacy:
            return "p2pkh"
        case PubKeyType.BTC_Nested_Segwit:
            return "p2sh"
        case PubKeyType.BTC_Native_Segwit:
            return "p2wpkh"
        case PubKeyType.BTC_Taproot:
            return "p2tr"
        case PubKeyType.STRATOS_Keccak256:
            return "keccak256"
        case PubKeyType.INITIA_Keccak256:
            return "keccak256"
        case PubKeyType.IOTA_Ed25519:
            return "ed25519"
        case PubKeyType.COSMOS_EVM_Keccak256:
            return "keccak256"
        case PubKeyType.SOLANA_Ed25519:
            return "ed25519"
        case PubKeyType.unknown:
            return "unknown"
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
