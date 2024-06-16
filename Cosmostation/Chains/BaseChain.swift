//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON


class BaseChain {
    
    var name: String!
    var tag: String!
    var logo1: String!
    var logo2: String!
    var isDefault = true
    var isTestnet = false
    var supportCosmos = false
    var supportEvm = false
    var apiName: String!
    
    var chainIdCosmos: String?
    var chainIdEvm: String?
    
    var accountKeyType: AccountKeyType!
    var privateKey: Data?
    var publicKey: Data?
    
    //cosmos & grpc info
    var bechAddress: String?
    var stakeDenom: String?
    var bechAccountPrefix: String?
    var validatorPrefix: String?
    var bechOpAddress: String?
    var supportCw20 = false
    var supportCw721 = false
    var supportStaking = true
    var isGrpc = true
    var grpcHost = ""
    var grpcPort = 443
    var lcdUrl = ""
    
    //evm & rpc info
    var evmAddress: String?
    var coinSymbol = ""
    var coinGeckoId = ""
    var coinLogo = ""
    var evmRpcURL = ""
    
    
//    var fetchState = FetchState.Idle
    var allCoinValue = NSDecimalNumber.zero
    var allCoinUSDValue = NSDecimalNumber.zero
    var allTokenValue = NSDecimalNumber.zero
    var allTokenUSDValue = NSDecimalNumber.zero
    
    var fetchState = FetchState.Idle
    var grpcFetcher: FetcherGrpc?
    var lcdFetcher: FetcherLcd?
    var evmFetcher: FetcherEvmrpc?
    
    func getHDPath(_ lastPath: String) -> String {
        return accountKeyType.hdPath.replacingOccurrences(of: "X", with: lastPath)
    }
    
    func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        setInfoWithPrivateKey(privateKey!)
    }
    
    func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        if (accountKeyType.pubkeyType == .COSMOS_Secp256k1) {
            bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
            
        } else if (accountKeyType.pubkeyType == .SUI_Ed25519) {
            
        } else {
            evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
            if (supportCosmos) {
                bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAccountPrefix!)
            }
        }
        
        if (supportCosmos && supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress!, validatorPrefix)
        }
    }
    
    func getGrpcfetcher() -> FetcherGrpc? {
        return grpcFetcher
    }
    
    func getLcdfetcher() -> FetcherLcd? {
        return lcdFetcher
    }
    
    func getEvmfetcher() -> FetcherEvmrpc? {
        return evmFetcher
    }
    
    func initFetcher() {
        if (supportEvm == true) {
            evmFetcher = FetcherEvmrpc.init(self)
        }
        if (supportCosmos == true) {
            grpcFetcher = FetcherGrpc.init(self)
        }
    }
    
    func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            var evmResult: Bool?
            var grpcResult: Bool?
            
            if (supportEvm == true) {
                evmResult = await evmFetcher?.fetchEvmData(id)
            }
            if (supportCosmos == true) {
                grpcResult = await grpcFetcher?.fetchGrpcData(id)
            }
            
            if (evmResult == false || grpcResult == false) {
                fetchState = .Fail
                print("fetching Some error ", tag)
            } else {
                fetchState = .Success
//                print("fetching good ", tag)
            }
            
            if (self.fetchState == .Success) {
                if let grpcFetcher = grpcFetcher, supportCosmos == true {
                    allCoinValue = grpcFetcher.allCoinValue()
                    allCoinUSDValue = grpcFetcher.allCoinValue(true)
                    allTokenValue = grpcFetcher.allTokenValue()
                    allTokenUSDValue = grpcFetcher.allTokenValue(true)
                    BaseData.instance.updateRefAddressesValue(
                        RefAddress(id, self.tag, self.bechAddress!, self.evmAddress ?? "",
                                   grpcFetcher.allStakingDenomAmount().stringValue, allCoinUSDValue.stringValue,
                                   allTokenUSDValue.stringValue, grpcFetcher.cosmosBalances?.filter({ BaseData.instance.getAsset(self.apiName, $0.denom) != nil }).count))
                    
                } else if let evmFetcher = evmFetcher, supportEvm == true {
                    allCoinValue = evmFetcher.allCoinValue()
                    allCoinUSDValue = evmFetcher.allCoinValue(true)
                    allTokenValue = evmFetcher.allTokenValue()
                    allTokenUSDValue = evmFetcher.allTokenValue(true)
                    BaseData.instance.updateRefAddressesValue(
                        RefAddress(id, self.tag, self.bechAddress ?? "", self.evmAddress!,
                                   evmFetcher.evmBalances.stringValue, allCoinUSDValue.stringValue,
                                   allTokenUSDValue.stringValue, (evmFetcher.evmBalances != NSDecimalNumber.zero ? 1 : 0) ))
                }
                
            }
            
            DispatchQueue.main.async(execute: {
//                print("", self.tag, " FetchData post")
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func fetchValidatorInfos() {
        if (supportCosmos == true && supportStaking == true) {
            Task {
                _ = await grpcFetcher?.fetchValidators()
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Notification.Name("FetchValidator"), object: self.tag, userInfo: nil)
                })
            }
        }
    }
    
    
    
    func fetchPreCreate() {}
    
    func isTxFeePayable() -> Bool { return false }
    
    func getExplorerAccount() -> URL? { return nil }
    
    func getExplorerTx(_ hash: String?) -> URL? { return nil }
    
    func getExplorerProposal(_ id: UInt64) -> URL? { return nil }
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if (usd == true) {
            return allCoinUSDValue.adding(allTokenUSDValue)
        } else {
            return allCoinValue.adding(allTokenValue)
        }
    }
    
    func getChainParam() -> JSON {
        return BaseData.instance.mintscanChainParams?[apiName] ?? JSON()
    }
    
    func getChainListParam() -> JSON {
        return getChainParam()["params"]["chainlist_params"]
    }
    func isEcosystem() -> Bool {
        return getChainListParam()["moblie_dapp"].bool ?? false
    }
    
    
    func isLagacyOKT() -> Bool {
        if (tag == "okt996_Keccak" || tag == "okt996_Secp") {
            return true
        }
        return false
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

enum PubKeyType: Int {
    case ETH_Keccak256 = 0
    case COSMOS_Secp256k1 = 1
    case INJECTIVE_Secp256k1 = 2
    case BERA_Secp256k1 = 3
    case SUI_Ed25519 = 4
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
        case PubKeyType.SUI_Ed25519:
            return "ed25519"
        case PubKeyType.unknown:
            return "unknown"
        }
    }
    
    var cosmosPubkey: String? {
        switch self {
        case PubKeyType.ETH_Keccak256:
            return "ethsecp256k1"
        case PubKeyType.COSMOS_Secp256k1:
            return "secp256k1"
        case PubKeyType.INJECTIVE_Secp256k1:
            return "ethsecp256k1"
        case PubKeyType.BERA_Secp256k1:
            return "ethsecp256k1"
        case PubKeyType.SUI_Ed25519:
            return "ed25519"
        case PubKeyType.unknown:
            return "unknown"
        }
    }
}


//func All_IBC_Chains() -> [CosmosClass] {
//    var result = [CosmosClass]()
//    result.append(contentsOf: ALLCOSMOSCLASS())
//    result.append(contentsOf: ALLEVMCLASS().filter { $0.supportCosmos == true } )
//    return result
//}
//
//func All_BASE_Chains() -> [BaseChain] {
//    var result = [CosmosClass]()
//    result.append(contentsOf: ALLCOSMOSCLASS())
//    result.append(contentsOf: ALLEVMCLASS())
//    return result
//}

func ALLCHAINS() -> [BaseChain] {
    var result = [BaseChain]()
    result.append(ChainCosmos())
    result.append(ChainAkash())
    result.append(ChainAlthea118())
    result.append(ChainArchway())
    result.append(ChainAssetMantle())
    result.append(ChainAxelar())
    result.append(ChainKava459())
    result.append(ChainKava118())
    result.append(ChainNeutron())
    result.append(ChainOkt996Keccak())
    result.append(ChainOkt996Secp())

    
    result.append(ChainEthereum())
    result.append(ChainAltheaEVM())
    result.append(ChainOktEVM())
    return result
}


enum FetchState: Int {
    case Idle = -1
    case Busy = 0
    case Success = 1
    case Fail = 2
}
