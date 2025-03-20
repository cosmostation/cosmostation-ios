//
//  InitiaFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 11/4/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftProtobuf

class InitiaFetcher: CosmosFetcher {
    var initiaDelegations = [Initia_Mstaking_V1_DelegationResponse]()
    var initiaUnbondings: [Initia_Mstaking_V1_UnbondingDelegation]?
    var initiaValidators = [Initia_Mstaking_V1_Validator]()

    override func fetchCosmosData(_ id: Int64) async -> Bool {
        _ = await super.fetchCosmosData(id)
        
        initiaDelegations.removeAll()
        initiaUnbondings = nil
        
        do {
            if let delegationsInitia = try await fetchDelegation_initia(),
               let unbondingInitia = try await fetchUnbondings_initia() {

                delegationsInitia.forEach({ delegation in
                    if delegation.balance.filter({ $0.denom == chain.stakeDenom }).first?.amount != "0" {
                        self.initiaDelegations.append(delegation)
                    }
                })
                self.initiaUnbondings = unbondingInitia
            }
            return true
            
        } catch {
            print("fetchInitia error \(error) ", chain.tag)
            return false
        }
    }
    
    override func fetchCosmosValidators() async -> Bool {
        if (initiaValidators.count > 0) { return true }
        if let bonded = try? await fetchBondedValidator_Initia(),
           let unbonding = try? await fetchUnbondingValidator_Initia(),
           let unbonded = try? await fetchUnbondedValidator_Initia() {
            
            initiaValidators.append(contentsOf: bonded ?? [])
            initiaValidators.append(contentsOf: unbonding ?? [])
            initiaValidators.append(contentsOf: unbonded ?? [])
            
            initiaValidators = initiaValidators.map { validator in
                var updatedValidator = validator
                updatedValidator.description_p.moniker = validator.description_p.moniker.trimmingCharacters(in: .whitespaces)
                return updatedValidator
            }
            
            initiaValidators.sort {
                if ($0.description_p.moniker == "Cosmostation") { return true }
                if ($1.description_p.moniker == "Cosmostation") { return false }
                if ($0.jailed && !$1.jailed) { return false }
                if (!$0.jailed && $1.jailed) { return true }
                return Double($0.tokens.filter({$0.denom == chain.stakeDenom}).first!.amount)! > Double($1.tokens.filter({$0.denom == chain.stakeDenom}).first!.amount)!
            }
            return true
        }
        return false
    }
    
    override func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakeDenom) {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(initiaDelegationValueSum(usd)).adding(initiaUnbondingValueSum(usd)).adding(commissionValue(denom, usd))
            
        } else {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(commissionValue(denom, usd))
        }
    }
    
    override func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakeDenom!).adding(vestingAmount(chain.stakeDenom!)).adding(initiaDelegationAmountSum())
            .adding(initiaUnbondingAmountSum()).adding(rewardAmountSum(chain.stakeDenom!)).adding(commissionAmount(chain.stakeDenom!))
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(vestingValueSum(usd)).adding(initiaDelegationValueSum(usd))
            .adding(initiaUnbondingValueSum(usd)).adding(rewardValueSum(usd)).adding(commissionValueSum(usd))
    }
}


extension InitiaFetcher {
    func fetchBondedValidator_Initia() async throws -> [Initia_Mstaking_V1_Validator]? {
        if (getEndpointType() == .UseGRPC) {
            let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
            let req = Initia_Mstaking_V1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
            return try await Initia_Mstaking_V1_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
            
        } else {
            let url = getLcd() + "initia/mstaking/v1/validators?status=BOND_STATUS_BONDED&pagination.limit=300"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.validators(.bonded)
        }
    }

    func fetchUnbondedValidator_Initia() async throws -> [Initia_Mstaking_V1_Validator]? {
        if (getEndpointType() == .UseGRPC) {
            let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
            let req = Initia_Mstaking_V1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
            return try await Initia_Mstaking_V1_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
        } else {
            let url = getLcd() + "initia/mstaking/v1/validators?status=BOND_STATUS_UNBONDED&pagination.limit=500"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.validators(.unbonded)
        }
    }
    
    func fetchUnbondingValidator_Initia() async throws -> [Initia_Mstaking_V1_Validator]? {
        if (getEndpointType() == .UseGRPC) {
            let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
            let req = Initia_Mstaking_V1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
            return try await Initia_Mstaking_V1_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
        } else {
            let url = getLcd() + "initia/mstaking/v1/validators?status=BOND_STATUS_UNBONDING&pagination.limit=500"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.validators(.unbonding)
        }
    }
    
    func fetchDelegation_initia() async throws -> [Initia_Mstaking_V1_DelegationResponse]? {
        if (getEndpointType() == .UseGRPC) {
            let req = Initia_Mstaking_V1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
            return try? await Initia_Mstaking_V1_QueryNIOClient(channel: getClient()).delegatorDelegations(req, callOptions: getCallOptions()).response.get().delegationResponses
        } else {
            let url = getLcd() + "initia/mstaking/v1/delegations/${address}".replacingOccurrences(of: "${address}", with: chain.bechAddress!)   //
            let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response?.delegations_initia()
        }
    }
    
    func fetchUnbondings_initia() async throws -> [Initia_Mstaking_V1_UnbondingDelegation]? {
        if (getEndpointType() == .UseGRPC) {
            let req = Initia_Mstaking_V1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
            return try? await Initia_Mstaking_V1_QueryNIOClient(channel: getClient()).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.get().unbondingResponses
        } else {
            let url = getLcd() + "initia/mstaking/v1/delegators/${address}/unbonding_delegations".replacingOccurrences(of: "${address}", with: chain.bechAddress!)  //
            let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response?.undelegations_initia()
        }
    }

    func isActiveValidator(_ validator: Initia_Mstaking_V1_Validator) -> Bool {
            return validator.status == .bonded
    }
    
    func initiaDelegationAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        initiaDelegations.forEach({ delegation in
            sum = sum.adding(NSDecimalNumber(string: delegation.balance.filter({ $0.denom == chain.stakeDenom}).first?.amount))
        })
        return sum
    }
    
    func initiaDelegationValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = initiaDelegationAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func initiaUnbondingAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        initiaUnbondings?.forEach({ unbonding in
            for entry in unbonding.entries {
                sum = sum.adding(NSDecimalNumber(string: entry.balance.filter({ $0.denom == chain.stakeDenom }).first?.amount))
            }
        })
        return sum
    }
    
    func initiaUnbondingValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = initiaUnbondingAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
}

extension JSON {
    func validators(_ status: Initia_Mstaking_V1_BondStatus) -> [Initia_Mstaking_V1_Validator]? {
        var result = [Initia_Mstaking_V1_Validator]()
        self["validators"].array?.forEach({ validator in
            var temp = Initia_Mstaking_V1_Validator()
            temp.operatorAddress = validator["operator_address"].stringValue
            temp.jailed = validator["jailed"].boolValue
            validator["tokens"].arrayValue.forEach { token in
                temp.tokens.append(Cosmos_Base_V1beta1_Coin.with {
                    $0.denom = token["denom"].stringValue
                    $0.amount = token["amount"].stringValue
                })
            }
            temp.status = status
            
            var desription = Initia_Mstaking_V1_Description()
            desription.moniker = validator["description"]["moniker"].stringValue
            desription.identity = validator["description"]["identity"].stringValue
            desription.website = validator["description"]["website"].stringValue
            desription.securityContact = validator["description"]["security_contact"].stringValue
            desription.details = validator["description"]["details"].stringValue
            temp.description_p = desription
            
            var commission = Initia_Mstaking_V1_Commission()
            var commissionRates = Initia_Mstaking_V1_CommissionRates()
            commissionRates.rate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["rate"].string).multiplying(byPowerOf10: 18).stringValue
            commissionRates.maxRate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["max_rate"].string).multiplying(byPowerOf10: 18).stringValue
            commissionRates.maxChangeRate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["max_change_rate"].string).multiplying(byPowerOf10: 18).stringValue
            commission.commissionRates = commissionRates
            temp.commission = commission
            result.append(temp)
        })
        return result
    }
    
    func delegations_initia() -> [Initia_Mstaking_V1_DelegationResponse]? {
        var result = [Initia_Mstaking_V1_DelegationResponse]()
        self["delegation_responses"].array?.forEach({ delegation in
            var temp = Initia_Mstaking_V1_DelegationResponse()
            
            var staking = Initia_Mstaking_V1_Delegation()
            staking.delegatorAddress = delegation["delegation"]["delegator_address"].stringValue
            staking.validatorAddress = delegation["delegation"]["validator_address"].stringValue
            delegation["delegation"]["shares"].arrayValue.forEach { share in
                staking.shares.append(Cosmos_Base_V1beta1_DecCoin.with { decCoin in
                    decCoin.denom = share["denom"].stringValue
                    decCoin.amount = NSDecimalNumber(string: share["amount"].stringValue).multiplying(byPowerOf10: 18).stringValue
                    
                })
            }
            temp.delegation = staking
            delegation["balance"].arrayValue.forEach { balance in
                temp.balance.append(
                    Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = balance["denom"].stringValue
                        $0.amount = balance["amount"].stringValue
                    }
                )
            }
            
            result.append(temp)
        })
        return result
    }
    
    func undelegations_initia() -> [Initia_Mstaking_V1_UnbondingDelegation]? {
        var result = [Initia_Mstaking_V1_UnbondingDelegation]()
        self["unbonding_responses"].array?.forEach({ unbonding in
            var temp = Initia_Mstaking_V1_UnbondingDelegation()
            temp.delegatorAddress = unbonding["delegator_address"].stringValue
            temp.validatorAddress = unbonding["validator_address"].stringValue
            
            var entries = [Initia_Mstaking_V1_UnbondingDelegationEntry]()
            unbonding["entries"].array?.forEach({ entry in
                var tempEntry = Initia_Mstaking_V1_UnbondingDelegationEntry()
                entry["balance"].arrayValue.forEach { balance in
                    tempEntry.balance.append(Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = balance["denom"].stringValue
                        $0.amount = balance["amount"].stringValue
                    })
                }
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
