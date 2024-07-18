//
//  NeutronLcdFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/18/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftProtobuf

class NeutronLcdFetcher: CosmosLcdFetcher {
    
    override func fetchCosmosData(_ id: Int64) async -> Bool {
        cosmosAuth = nil
        cosmosBalances = nil
        neutronDeposited = NSDecimalNumber.zero
        neutronVesting = nil
        vaultsList = chain.getChainListParam()["vaults"].array
        daosList = chain.getChainListParam()["daos"].array
        cosmosBaseFees.removeAll()
        
        do {
            if let cw20Tokens = try? await fetchCw20Info(),
               let balance = try await fetchBalance(),
               let auth = try? await fetchAuth(),
               let vault = try? await fetchVaultDeposit(),
               let vesting = try? await fetchNeutronVesting(),
               let baseFees = try? await fetchBaseFee() {
                self.mintscanCw20Tokens = cw20Tokens ?? []
                self.cosmosAuth = auth
                self.cosmosBalances = balance
                
                if let deposited = vault {
                    self.neutronDeposited = NSDecimalNumber(string: deposited["power"].string)
                }
                if let vestingInfo = vesting {
                    self.neutronVesting = vestingInfo
                }
                
                baseFees?.forEach({ basefee in
                    if (BaseData.instance.getAsset(chain.apiName, basefee.denom) != nil) {
                        self.cosmosBaseFees.append(basefee)
                    }
                })
                self.cosmosBaseFees.sort {
                    if ($0.denom == chain.stakeDenom) { return true }
                    if ($1.denom == chain.stakeDenom) { return false }
                    return false
                }
                
                await mintscanCw20Tokens.concurrentForEach { cw20 in
                    await self.fetchCw20Balance(cw20)
                }
            }
            return true
            
        } catch {
            print("neutron lcd error \(error) ", chain.tag)
            return false
        }
    }
    
    
    override func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakeDenom) {
            return balanceValue(denom, usd).adding(neutronVestingValue(usd)).adding(neutronDepositedValue(usd))
        } else {
            return balanceValue(denom, usd)
        }
    }
    
    override func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakeDenom!).adding(neutronVestingAmount()).adding(neutronDeposited)
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(neutronVestingValue(usd)).adding(neutronDepositedValue(usd))
    }
    
    
    override func neutronVestingAmount() -> NSDecimalNumber  {
        if let allocated = neutronVesting?["allocated_amount"].string,
           let withdrawn = neutronVesting?["withdrawn_amount"].string {
            let allocatedAmount = NSDecimalNumber(string: allocated)
            let withdrawnAmount = NSDecimalNumber(string: withdrawn)
            return allocatedAmount.subtracting(withdrawnAmount)
        }
        return NSDecimalNumber.zero
    }
    
    override func neutronVestingValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = neutronVestingAmount()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    override func neutronDepositedValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = neutronDeposited
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    
    
    
    
    
    
    override func fetchVaultDeposit() async throws -> JSON? {
        let query: JSON = ["voting_power_at_height" : ["address" : chain.bechAddress!]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: vaultsList?[0]["address"].stringValue ?? "" ).replacingOccurrences(of: "${query_data}", with: queryBase64)
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]
    }
    
    override func fetchNeutronVesting() async throws -> JSON? {
        let query: JSON = ["allocation" : ["address" : chain.bechAddress!]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: NEUTRON_VESTING_CONTRACT_ADDRESS).replacingOccurrences(of: "${query_data}", with: queryBase64)
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]
    }
    
    override func fetchNeutronProposals(_ daoType: Int) async throws -> JSON? {
        let contAddress = daosList?[0]["proposal_modules"][daoType]["address"].string ?? ""
        let query: JSON = ["reverse_proposals" : JSON()]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: contAddress).replacingOccurrences(of: "${query_data}", with: queryBase64)
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]
    }
}
