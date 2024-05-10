//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation


class BaseChain {
    var name: String!
    var tag: String!
    var chainIdCosmos: String!
    var logo1: String!
    var logo2: String!
    var isDefault = true
    var apiName: String!
    
    
    var accountKeyType: AccountKeyType!
    var privateKey: Data?
    var publicKey: Data?
    
    
    var fetchState = FetchState.Idle
    var allCoinValue = NSDecimalNumber.zero
    var allCoinUSDValue = NSDecimalNumber.zero
    var allTokenValue = NSDecimalNumber.zero
    var allTokenUSDValue = NSDecimalNumber.zero
    
    func getHDPath(_ lastPath: String) -> String {
        return accountKeyType.hdPath.replacingOccurrences(of: "X", with: lastPath)
    }
    
    
    func setInfoWithSeed(_ seed: Data, _ lastPath: String) {}
    
    func setInfoWithPrivateKey(_ priKey: Data) {}
    
    func fetchData(_ id: Int64) {}
    
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
}


func All_IBC_Chains() -> [CosmosClass] {
    var result = [CosmosClass]()
    result.append(contentsOf: ALLCOSMOSCLASS())
    result.append(contentsOf: ALLEVMCLASS().filter { $0.supportCosmos == true } )
    return result
}

func All_BASE_Chains() -> [BaseChain] {
    var result = [CosmosClass]()
    result.append(contentsOf: ALLCOSMOSCLASS())
    result.append(contentsOf: ALLEVMCLASS())
    return result
}


enum FetchState: Int {
    case Idle = -1
    case Busy = 0
    case Success = 1
    case Fail = 2
}
