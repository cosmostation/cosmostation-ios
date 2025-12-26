//
//  ChainSolana.swift
//  Cosmostation
//
//  Created by 권혁준 on 7/7/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSolana: BaseChain {
    
    var solanaFetcher: SolanaFetcher?
    
    override init() {
        super.init()
        
        name = "Solana"
        tag = "solana501"
        chainImg = "chainSolana"
        apiName = "solana"
        accountKeyType = AccountKeyType(.SOLANA_Ed25519, "m/44'/501'/X/0'")
        
        coinSymbol = "SOL"
        
        mainUrl = "https://api.mainnet-beta.solana.com"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    func getSolanaFetcher() -> SolanaFetcher? {
        if (solanaFetcher != nil) { return solanaFetcher }
        solanaFetcher = SolanaFetcher(self)
        return solanaFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            let solanaResult = await getSolanaFetcher()?.fetchSolanaBalance()
            
            if (solanaResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (self.fetchState == .Success) {
                if let solanaFetcher = getSolanaFetcher() {
                    if (solanaFetcher.balanceAmount() == NSDecimalNumber.zero) {
                        coinsCnt = 0
                    } else {
                        coinsCnt = 1
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let solanaResult = await getSolanaFetcher()?.fetchSolanaData()
            
            if (solanaResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let solanaFetcher = getSolanaFetcher(), fetchState == .Success {
                coinsCnt = solanaFetcher.valueCoinCnt()
                allCoinValue = solanaFetcher.balanceValue()
                allCoinUSDValue = solanaFetcher.balanceValue(usd: true)
                let mainCoinAmount = solanaFetcher.balanceAmount()
                tokensCnt = solanaFetcher.solanaTokenInfo.count
                allTokenValue = solanaFetcher.allTokenValue()
                allTokenUSDValue = solanaFetcher.allTokenValue(true)
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.mainAddress, "",
                               mainCoinAmount.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
}

let SOLANA_PROGRAM_ID = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"

let SOLANA_DEFAULT_FEE = NSDecimalNumber.init(string: "5000")
let SOLANA_MAX_PRIORITY_TIP = NSDecimalNumber.init(string: "2000")
