//
//  ChainGno.swift
//  Cosmostation
//
//  Created by 차소민 on 1/6/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGno: BaseChain  {
    
    var gnoFetcher: GnoFetcher?
    var gnoIndexerUrl = "https://indexer.onbloc.xyz/graphql/query"
    
    override init() {
        super.init()
        
        name = "Gno"
        tag = "gno118"
        chainImg = "chainGno"
        apiName = "gno"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseRPC
        stakeDenom = "ugnot"
        bechAccountPrefix = "g"
        validatorPrefix = "gvaloper"
        supportStaking = false
        grpcHost = ""
        lcdUrl = ""
        rpcUrl = "https://rpc.onbloc.xyz:443"
    }
    
    func getGnoFetcher() -> GnoFetcher? {
        if (gnoFetcher != nil) { return gnoFetcher }
        gnoFetcher = GnoFetcher(self)
        return gnoFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            var result: Bool?
            
            result = await getGnoFetcher()?.fetchGnoBalances()
            coinsCnt = getGnoFetcher()?.valueCoinCnt() ?? 0
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            tokensCnt = 0
            var result: Bool?
            
            result = await getGnoFetcher()?.fetchGnoData(id)
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (self.fetchState == .Success) {
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                if let gnoFetcher = getGnoFetcher() {
                    coinsCnt = gnoFetcher.valueCoinCnt()
                    coinsValue = gnoFetcher.allCoinValue()
                    coinsUSDValue = gnoFetcher.allCoinValue(true)
                    mainCoinAmount = gnoFetcher.allStakingDenomAmount()
                    tokensCnt = gnoFetcher.valueTokenCnt(id)
                    tokensValue = gnoFetcher.allTokenValue(id)
                    tokensUSDValue = gnoFetcher.allTokenValue(id, true)
                }
                
                allCoinValue = coinsValue
                allCoinUSDValue = coinsUSDValue
                allTokenValue = tokensValue
                allTokenUSDValue = tokensUSDValue
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.bechAddress ?? "", self.evmAddress ?? "",
                               mainCoinAmount.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
            }
            DispatchQueue.main.async(execute: {
                //                print("", self.tag, " FetchData post")
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
}

let GNO_HISTORY_QUERY = """
query($addr: String!) {
    getTransactions(where: { _or: [
        { messages: { value: { BankMsgSend: { from_address: { eq: $addr } } } } },
        { messages: { value: { BankMsgSend: { to_address: { eq: $addr } } } } },
        { messages: { value: { MsgCall: { caller: { eq: $addr } } } } },
        { messages: { value: { MsgAddPackage: { creator: { eq: $addr } } } } },
        { messages: { value: { MsgRun: { caller: { eq: $addr } } } } }
    ]}, order: { heightAndIndex: DESC }) {
        hash
        block_height
        success
        memo
        gas_fee { denom amount }
        messages {
            typeUrl
            route
            value {
                __typename
                ... on BankMsgSend { from_address to_address amount }
                ... on MsgCall { caller pkg_path func args }
                ... on MsgAddPackage { creator package { path } }
                ... on MsgRun { caller }
            }
        }
    }
}
"""

let GNO_BLOCK_TIME_QUERY = """
query($heights: [FilterBlock!]!) {
    getBlocks(where: { _or: $heights }) {
        height
        time
    }
}
"""
