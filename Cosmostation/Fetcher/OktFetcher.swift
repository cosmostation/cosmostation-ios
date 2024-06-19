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

class OktFetcher: FetcherLcd {
    var lcdOktDeposits = JSON()
    var lcdOktWithdaws = JSON()
    var lcdOktTokens = Array<JSON>()
    var lcdOktValidators = Array<JSON>()
    
    override func fetchBalances() async -> Bool {
        lcdAccountInfo = JSON()
        if let accountInfo = try? await fetchAccountInfo(chain.bechAddress!) {
            self.lcdAccountInfo = accountInfo ?? JSON()
        }
        return true
    }
    
    override func fetchLcdData(_ id: Int64) async -> Bool {
        lcdNodeInfo = JSON()
        lcdAccountInfo = JSON()
        lcdOktDeposits = JSON()
        lcdOktWithdaws = JSON()
        lcdOktTokens.removeAll()
        
        do {
            if let nodeInfo = try await fetchNodeInfo(),
               let accountInfo = try await fetchAccountInfo(chain.bechAddress!),
               let okDeposit = try await fetchOktDeposited(chain.bechAddress!),
               let okWithdraw = try await fetchOktWithdraw(chain.bechAddress!),
               let okTokens = try await fetchOktTokens() {
                self.lcdNodeInfo = nodeInfo
                self.lcdAccountInfo = accountInfo
                self.lcdOktDeposits = okDeposit
                self.lcdOktWithdaws = okWithdraw
                okTokens["data"].array?.forEach({ value in
                    self.lcdOktTokens.append(value)
                })
            }
            return true
        } catch {
            return false
        }
    }
    
    override func fetchValidators() async -> Bool {
        lcdOktValidators.removeAll()
        if let okValidators = try? await fetchOktValdators() {
            okValidators?.forEach { validator in
                self.lcdOktValidators.append(validator)
            }
            
            self.lcdOktValidators.sort {
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
        return lcdBalanceValue(chain.stakeDenom!, usd).adding(lcdOktDepositValue(usd)).adding(lcdOktWithdrawValue(usd))
    }
    
    override func lcdBalanceAmount(_ denom: String) -> NSDecimalNumber {
        if let balance = lcdAccountInfo.oktCoins?.filter({ $0["denom"].string == denom }).first {
            return NSDecimalNumber.init(string: balance["amount"].string ?? "0")
        }
        return NSDecimalNumber.zero
    }
    
    func lcdAllStakingDenomAmount() -> NSDecimalNumber {
        return lcdBalanceAmount(chain.stakeDenom!).adding(lcdOktDepositAmount()).adding(lcdOktWithdrawAmount())
    }
    
    func lcdBalanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakeDenom) {
            let amount = lcdBalanceAmount(denom)
            let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID, usd)
            return msPrice.multiplying(by: amount, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func lcdOktDepositAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: lcdOktDeposits["tokens"].string ?? "0")
    }
    
    func lcdOktDepositValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID, usd)
        let amount = lcdOktDepositAmount()
        return msPrice.multiplying(by: amount, withBehavior: handler6)
    }
    
    func lcdOktWithdrawAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: lcdOktWithdaws["quantity"].string ?? "0")
    }
    
    func lcdOktWithdrawValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID, usd)
        let amount = lcdOktWithdrawAmount()
        return msPrice.multiplying(by: amount, withBehavior: handler6)
    }
}

extension OktFetcher {
    
    func fetchNodeInfo() async throws -> JSON? {
        let url = OKT_LCD + "node_info"
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchAccountInfo(_ address: String) async throws -> JSON? {
        let url = OKT_LCD + "auth/accounts/" + address
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktDeposited(_ address: String) async throws -> JSON? {
        let url = OKT_LCD + "staking/delegators/" + address
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktWithdraw(_ address: String) async throws -> JSON? {
        let url = OKT_LCD + "staking/delegators/" + address + "/unbonding_delegations"
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktTokens() async throws -> JSON? {
        let url = OKT_LCD + "tokens"
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktValdators() async throws -> [JSON]? {
        let url = OKT_LCD + "staking/validators"
//        return try await AF.request(url, method: .get, parameters: ["status":"all"]).serializingDecodable([JSON].self).value
        return try await AF.request(url, method: .get, parameters: [:]).serializingDecodable([JSON].self).value
    }
}
