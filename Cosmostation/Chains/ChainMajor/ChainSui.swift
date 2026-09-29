//
//  ChainSui.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSui: BaseChain  {
    
    var suiFetcher: SuiFetcher?
    
    override init() {
        super.init()
        
        name = "Sui"
        tag = "suiMainnet"
        chainImg = "chainSui"
        apiName = "sui"
        accountKeyType = AccountKeyType(.SUI_Ed25519, "m/44'/784'/0'/0'/X'")
    
        coinSymbol = "SUI"
        stakeDenom = SUI_MAIN_DENOM
        
        grpcHost = "fullnode.mainnet.sui.io"
        mainUrl = "https://graphql.mainnet.sui.io/graphql"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    func getSuiFetcher() -> SuiFetcher? {
        if (suiFetcher != nil) { return suiFetcher }
        suiFetcher = SuiFetcher(self)
        return suiFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            let suiResult = await getSuiFetcher()?.fetchSuiBalances()
            
            if (suiResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (self.fetchState == .Success) {
                if let suiFetcher = getSuiFetcher() {
                    coinsCnt = suiFetcher.suiBalances.count
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
            let suiResult = await getSuiFetcher()?.fetchSuiData(id)
            
            if (suiResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let suiFetcher = getSuiFetcher(), fetchState == .Success {
                coinsCnt = suiFetcher.suiBalances.count
                
                allCoinValue = suiFetcher.allValue()
                allCoinUSDValue = suiFetcher.allValue(true)
                let mainCoinAmount = suiFetcher.allSuiAmount()
                
                allTokenValue = NSDecimalNumber.zero
                allTokenUSDValue = NSDecimalNumber.zero
                
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
    
    func fetchHistory() {
        Task {
            await getSuiFetcher()?.fetchSuiHistory()
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchHistory"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    
    override func assetSymbol(_ denom: String) -> String {
        if let suiFetcher = getSuiFetcher() {
            if let msAsset = BaseData.instance.getAsset(apiName, denom) {
                return msAsset.symbol!
            } else if let metaData = suiFetcher.suiCoinMeta[denom] {
                return  metaData?.symbol ?? "UnKnown"
                
            }
        }
        return denom.suiCoinSymbol() ?? "UnKnown"
    }
    
    override func assetImgUrl(_ denom: String) -> URL? {
        if let suiFetcher = getSuiFetcher() {
            if let msAsset = BaseData.instance.getAsset(apiName, denom) {
                return msAsset.assetImg()
            } else if let metaData = suiFetcher.suiCoinMeta[denom] {
                return URL(string: metaData?.iconURL ?? "")
            }
        }
        return nil
    }
    
    override func assetDecimal(_ denom: String) -> Int16 {
        if let suiFetcher = getSuiFetcher() {
            if let msAsset = BaseData.instance.getAsset(apiName, denom) {
                return msAsset.decimals ?? 9
            } else if let metaData = suiFetcher.suiCoinMeta[denom] {
                return Int16(metaData?.decimals ?? 9)
            }
        }
        return 9
    }
    
    override func assetGeckoId(_ denom: String) -> String {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            return msAsset.coinGeckoId ?? ""
        }
        return ""
        
    }
}

let SUI_TYPE_COIN = "0x2::coin::Coin"
let SUI_MAIN_DENOM = "0x2::sui::SUI"
let SUI_STAKED_TYPE = "0x3::staking_pool::StakedSui"

let SUI_MIN_STAKE       = NSDecimalNumber.init(string: "1000000000")
let SUI_FEE_SEND        = NSDecimalNumber.init(string: "4000000")
let SUI_FEE_STAKE       = NSDecimalNumber.init(string: "50000000")
let SUI_FEE_UNSTAKE     = NSDecimalNumber.init(string: "50000000")
let SUI_FEE_DEFAULT     = NSDecimalNumber.init(string: "70000000")

let SUI_EXCHANGE_RATE_QUERY = """
query($tableId: SuiAddress!, $epochKey: Base64!) {
    address(address: $tableId) {
        dynamicField(name: { type: "u64", bcs: $epochKey }) {
            value {
                ... on MoveValue {
                    json
                }
            }
        }
    }
}
"""

let SUI_HISTORY_QUERY = """
  query($addr: SuiAddress!, $last: Int!, $before: String) {
    transactions(last: $last, before: $before, filter: {affectedAddress: $addr}) {
      pageInfo { hasPreviousPage startCursor }
      nodes {
        digest
        sender { address }
        effects {
          checkpoint { sequenceNumber }
          status
          timestamp
          balanceChanges { nodes { owner { address } coinType { repr } amount } }
          gasEffects { gasSummary { computationCost storageCost storageRebate } }
        }
        kind {
          __typename
          ... on ProgrammableTransaction {
            inputs { nodes { __typename ... on MoveValue { type { repr } json } } }
            commands { nodes { __typename ... on MoveCallCommand { function { name module { name } } } } }
          }
        }
      }
    }
  }
  """
