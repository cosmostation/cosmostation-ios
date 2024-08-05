//
//  OktFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/16/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OktFetcher: CosmosFetcher {
    
    var oktNodeInfo = JSON()
    var oktAccountInfo = JSON()
    
    var oktDeposits = JSON()
    var oktWithdaws = JSON()
    var oktTokens = Array<JSON>()
    var oktValidators = Array<JSON>()
    
    override func fetchCosmosBalances() async -> Bool {
        cosmosBalances = [Cosmos_Base_V1beta1_Coin]()
        if let _ = try? await fetchAuth(),
           let balance = try? await fetchBalance() {
            self.cosmosBalances = balance
        }
        
        oktAccountInfo = JSON()
        
        if let accountInfo = try? await fetchAccountInfo(chain.bechAddress!) {
            self.oktAccountInfo = accountInfo ?? JSON()
        }
        return true
    }
    
    override func valueCoinCnt() -> Int {
        return cosmosBalances?.count ?? 0
    }

    override func fetchCosmosData(_ id: Int64) async -> Bool {
        oktNodeInfo = JSON()
        oktAccountInfo = JSON()
        oktDeposits = JSON()
        oktWithdaws = JSON()
        oktTokens.removeAll()

        do {
            if let nodeInfo = try await fetchNodeInfo(),
               let balance = try await fetchBalance(),
               let accountInfo = try await fetchAccountInfo(chain.bechAddress!),
               let okDeposit = try await fetchOktDeposited(chain.bechAddress!),
               let okWithdraw = try await fetchOktWithdraw(chain.bechAddress!),
               let okTokens = try await fetchOktTokens() {
                self.oktNodeInfo = nodeInfo
                self.cosmosBalances = balance
                self.oktAccountInfo = accountInfo
                self.oktDeposits = okDeposit
                self.oktWithdaws = okWithdraw
                okTokens["data"].array?.forEach({ value in
                    self.oktTokens.append(value)
                })
            }
            return true
        } catch {
            return false
        }
    }
    
    override func fetchCosmosValidators() async -> Bool {
        oktValidators.removeAll()
        if let okValidators = try? await fetchOktValdators() {
            okValidators?.forEach { validator in
                self.oktValidators.append(validator)
            }
            
            self.oktValidators.sort {
                if ($0["description"]["moniker"].stringValue == "Cosmostation") {
                    return true
                }
                if ($1["description"]["moniker"].stringValue == "Cosmostation"){
                    return false
                }
                if ($0["jailed"].boolValue && !$1["jailed"].boolValue) {
                    return false
                }
                if (!$0["jailed"].boolValue && $1["jailed"].boolValue) {
                    return true
                }
                return $0["delegator_shares"].doubleValue > $1["delegator_shares"].doubleValue
            }
            return true
        } else {
            print("okValidators error")
        }
        return false
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return oktBalanceValue(chain.stakeDenom!, usd).adding(oktDepositValue(usd)).adding(oktWithdrawValue(usd))
    }
    
    func oktAllStakingDenomAmount() -> NSDecimalNumber {
        return oktBalanceAmount(chain.stakeDenom!).adding(oktDepositAmount()).adding(oktWithdrawAmount())
    }
    
    func oktBalanceAmount(_ denom: String) -> NSDecimalNumber {
        if let balance = oktAccountInfo.oktCoins?.filter({ $0["denom"].string == denom }).first {
            return NSDecimalNumber.init(string: balance["amount"].string ?? "0")
        }
        return NSDecimalNumber.zero
    }
    
    func oktBalanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakeDenom) {
            let amount = oktBalanceAmount(denom)
            let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID, usd)
            return msPrice.multiplying(by: amount, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func oktDepositAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: oktDeposits["tokens"].string ?? "0")
    }
    
    func oktDepositValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID, usd)
        let amount = oktDepositAmount()
        return msPrice.multiplying(by: amount, withBehavior: handler6)
    }
    
    func oktWithdrawAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: oktWithdaws["quantity"].string ?? "0")
    }
    
    func oktWithdrawValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID, usd)
        let amount = oktWithdrawAmount()
        return msPrice.multiplying(by: amount, withBehavior: handler6)
    }
}

extension OktFetcher {
    
    func fetchNodeInfo() async throws -> JSON? {
        let url = getLcd() + "node_info"
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchAccountInfo(_ address: String) async throws -> JSON? {
        let url = getLcd() + "auth/accounts/" + address
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktDeposited(_ address: String) async throws -> JSON? {
        let url = getLcd() + "staking/delegators/" + address
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktWithdraw(_ address: String) async throws -> JSON? {
        let url = getLcd() + "staking/delegators/" + address + "/unbonding_delegations"
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktTokens() async throws -> JSON? {
        let url = getLcd() + "tokens"
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktValdators() async throws -> [JSON]? {
        let url = getLcd() + "staking/validators"
        return try await AF.request(url, method: .get, parameters: ["status":"all"]).serializingDecodable([JSON].self).value
    }
}


extension JSON {
    var oktCoins: [JSON]? {
        return self["value","coins"].array
    }
    
    func oktCoin(_ position: Int) -> JSON? {
        return oktCoins?[position]
    }
}
