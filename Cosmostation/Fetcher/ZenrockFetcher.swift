//
//  ZenrockFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 2/5/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftProtobuf

class ZenrockFetcher: CosmosFetcher {
    var delegations = [Zrchain_Validation_DelegationResponse]()
    var unbondings: [Zrchain_Validation_UnbondingDelegation]?
    var validators = [Zrchain_Validation_ValidatorHV]()
    

    override func fetchCosmosData(_ id: Int64) async -> Bool {
        _ = await super.fetchCosmosData(id)
        
        delegations.removeAll()
        unbondings = nil
        
        do {
            if let delegations = try await fetchZenrockDelegation(),
               let unbonding = try await fetchZenrockUnbondings() {

                delegations.forEach({ delegation in
                    if (delegation.balance.amount != "0") {
                        self.delegations.append(delegation)
                    }
                })
                self.unbondings = unbonding
            }
            return true
            
        } catch {
            print("fetchZenrock error \(error) ", chain.tag)
            return false
        }
    }
    
    override func fetchCosmosValidators() async -> Bool {
        if (validators.count > 0) { return true }
        if let bonded = try? await fetchZenrockBondedValidator(),
           let unbonding = try? await fetchZenrockUnbondingValidator(),
           let unbonded = try? await fetchZenrockUnbondedValidator() {
            
            validators.append(contentsOf: bonded ?? [])
            validators.append(contentsOf: unbonding ?? [])
            validators.append(contentsOf: unbonded ?? [])
            
            validators = validators.map { validator in
                var updatedValidator = validator
                updatedValidator.description_p.moniker = validator.description_p.moniker.trimmingCharacters(in: .whitespaces)
                return updatedValidator
            }
            
            validators.sort {
                if ($0.description_p.moniker == "Cosmostation") { return true }
                if ($1.description_p.moniker == "Cosmostation") { return false }
                if ($0.jailed && !$1.jailed) { return false }
                if (!$0.jailed && $1.jailed) { return true }
                return Double($0.tokensNative)! > Double($1.tokensNative)!
            }
            return true
        }
        return false
    }
    
    override func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakingAssetDenom()) {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(zenrockDelegationValueSum(usd)).adding(zenrockUnbondingValueSum(usd)).adding(commissionValue(denom, usd))
            
        } else {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(commissionValue(denom, usd))
        }
    }
    
    override func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakingAssetDenom()).adding(zenrockDelegationAmountSum())
            .adding(zenrockUnbondingAmountSum()).adding(rewardAmountSum(chain.stakingAssetDenom())).adding(commissionAmount(chain.stakingAssetDenom()))
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(zenrockDelegationValueSum(usd))
            .adding(zenrockUnbondingValueSum(usd)).adding(rewardValueSum(usd)).adding(commissionValueSum(usd))
    }
}


extension ZenrockFetcher {
    func fetchZenrockBondedValidator() async throws -> [Zrchain_Validation_ValidatorHV]? {
        if (getEndpointType() == .UseGRPC) {
            let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
            let req = Zrchain_Validation_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
            return try await Zrchain_Validation_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
            
        } else {
            let url = getLcd() + "cosmos/staking/v1beta1/validators?status=BOND_STATUS_BONDED&pagination.limit=300"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.validators(.bonded)
        }
    }

    func fetchZenrockUnbondedValidator() async throws -> [Zrchain_Validation_ValidatorHV]? {
        if (getEndpointType() == .UseGRPC) {
            let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
            let req = Zrchain_Validation_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
            return try await Zrchain_Validation_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
        } else {
            let url = getLcd() + "cosmos/staking/v1beta1/validators?status=BOND_STATUS_UNBONDED&pagination.limit=500"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.validators(.unbonded)
        }
    }
    
    func fetchZenrockUnbondingValidator() async throws -> [Zrchain_Validation_ValidatorHV]? {
        if (getEndpointType() == .UseGRPC) {
            let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
            let req = Zrchain_Validation_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
            return try await Zrchain_Validation_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
        } else {
            let url = getLcd() + "cosmos/staking/v1beta1/validators?status=BOND_STATUS_UNBONDING&pagination.limit=500"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.validators(.unbonding)
        }
    }
    
    func fetchZenrockDelegation() async throws -> [Zrchain_Validation_DelegationResponse]? {
        if (getEndpointType() == .UseGRPC) {
            let req = Zrchain_Validation_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
            return try? await Zrchain_Validation_QueryNIOClient(channel: getClient()).delegatorDelegations(req, callOptions: getCallOptions()).response.get().delegationResponses
        } else {
            let url = getLcd() + "cosmos/staking/v1beta1/delegations/${address}".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
            let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response?.delegations()
        }
    }
    
    func fetchZenrockUnbondings() async throws -> [Zrchain_Validation_UnbondingDelegation]? {
        if (getEndpointType() == .UseGRPC) {
            let req = Zrchain_Validation_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
            return try? await Zrchain_Validation_QueryNIOClient(channel: getClient()).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.get().unbondingResponses
        } else {
            let url = getLcd() + "cosmos/staking/v1beta1/delegators/${address}/unbonding_delegations".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
            let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response?.undelegations()
        }
    }

    func isActiveValidator(_ validator: Zrchain_Validation_ValidatorHV) -> Bool {
            return validator.status == .bonded
    }
    
    func zenrockDelegationAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        delegations.forEach({ delegation in
            sum = sum.adding(NSDecimalNumber(string: delegation.balance.amount))
        })
        return sum
    }
    
    func zenrockDelegationValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakingAssetDenom()) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = zenrockDelegationAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func zenrockUnbondingAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        unbondings?.forEach({ unbonding in
            for entry in unbonding.entries {
                sum = sum.adding(NSDecimalNumber(string: entry.balance))
            }
        })
        return sum
    }
    
    func zenrockUnbondingValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakingAssetDenom()) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = zenrockUnbondingAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
}

extension JSON {
    func validators(_ status: Zrchain_Validation_BondStatus) -> [Zrchain_Validation_ValidatorHV]? {
        var result = [Zrchain_Validation_ValidatorHV]()
        self["validators"].array?.forEach({ validator in
            var temp = Zrchain_Validation_ValidatorHV()
            temp.operatorAddress = validator["operator_address"].stringValue
            temp.jailed = validator["jailed"].boolValue
            temp.tokensNative = validator["tokensNative"].stringValue
            temp.tokensAvs = validator["tokensAVS"].stringValue
            temp.status = status
            
            var desription = Zrchain_Validation_Description()
            desription.moniker = validator["description"]["moniker"].stringValue
            desription.identity = validator["description"]["identity"].stringValue
            desription.website = validator["description"]["website"].stringValue
            desription.securityContact = validator["description"]["security_contact"].stringValue
            desription.details = validator["description"]["details"].stringValue
            temp.description_p = desription
            
            var commission = Zrchain_Validation_Commission()
            var commissionRates = Zrchain_Validation_CommissionRates()
            commissionRates.rate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["rate"].string).multiplying(byPowerOf10: 18).stringValue
            commissionRates.maxRate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["max_rate"].string).multiplying(byPowerOf10: 18).stringValue
            commissionRates.maxChangeRate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["max_change_rate"].string).multiplying(byPowerOf10: 18).stringValue
            commission.commissionRates = commissionRates
            temp.commission = commission
            result.append(temp)
        })
        return result
    }
    
    func delegations() -> [Zrchain_Validation_DelegationResponse]? {
        var result = [Zrchain_Validation_DelegationResponse]()
        self["delegation_responses"].array?.forEach({ delegation in
            var temp = Zrchain_Validation_DelegationResponse()
            
            var staking = Zrchain_Validation_Delegation()
            staking.delegatorAddress = delegation["delegation"]["delegator_address"].stringValue
            staking.validatorAddress = delegation["delegation"]["validator_address"].stringValue
            staking.shares = NSDecimalNumber(string: delegation["delegation"]["shares"].stringValue).multiplying(byPowerOf10: 18).stringValue
            temp.delegation = staking
            let balance = Cosmos_Base_V1beta1_Coin(delegation["balance"]["denom"].stringValue, delegation["balance"]["amount"].stringValue)
            temp.balance = balance
            
            result.append(temp)
        })
        return result
    }
    
    func undelegations() -> [Zrchain_Validation_UnbondingDelegation]? {
        var result = [Zrchain_Validation_UnbondingDelegation]()
        self["unbonding_responses"].array?.forEach({ unbonding in
            var temp = Zrchain_Validation_UnbondingDelegation()
            temp.delegatorAddress = unbonding["delegator_address"].stringValue
            temp.validatorAddress = unbonding["validator_address"].stringValue
            
            var entries = [Zrchain_Validation_UnbondingDelegationEntry]()
            unbonding["entries"].array?.forEach({ entry in
                var tempEntry = Zrchain_Validation_UnbondingDelegationEntry()
                tempEntry.balance = entry["balance"].stringValue
                tempEntry.creationHeight = Int64(entry["creation_height"].stringValue) ?? 0
                
                if let date = WDP.toDate(entry["completion_time"].stringValue) {
                    let time: Google_Protobuf_Timestamp = Google_Protobuf_Timestamp.init(timeIntervalSince1970: date.timeIntervalSince1970)
                    tempEntry.completionTime = time
                }
                
                entries.append(tempEntry)
            })
            temp.entries = entries
            
            result.append(temp)
        })
        return result
    }
}
