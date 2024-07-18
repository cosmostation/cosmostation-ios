//
//  CosmosLcdFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftProtobuf


class CosmosLcdFetcher: CosmosFetcher {
    
    var cosmosAuth: JSON?
    
    override func fetchBalances() async -> Bool {
        cosmosAuth = nil
        cosmosBalances = [Cosmos_Base_V1beta1_Coin]()
        if let auth = try? await fetchAuth(),
           let balance = try? await fetchBalance() {
            self.cosmosAuth = auth
            self.cosmosBalances = balance
        }
        return true
    }
    
    override func fetchCosmosData(_ id: Int64) async -> Bool {
        mintscanCw20Tokens.removeAll()
        mintscanCw721List.removeAll()
        cosmosAuth = nil
        cosmosBalances = nil
        cosmosVestings.removeAll()
        cosmosDelegations.removeAll()
        cosmosUnbondings = nil
        cosmosRewards = nil
        cosmosCommissions.removeAll()
        rewardAddress = nil
        cosmosBaseFees.removeAll()
        
        do {
            if let cw20Tokens = try? await fetchCw20Info(),
               let cw721List = try? await fetchCw721Info(),
               let balance = try await fetchBalance(),
               let auth = try? await fetchAuth(),
               let delegations = try? await fetchDelegation(),
               let unbonding = try? await fetchUnbondings(),
               let rewards = try? await fetchRewards(),
               let commission = try? await fetchCommission(),
               let rewardaddr = try? await fetchRewardAddress(),
               let baseFees = try? await fetchBaseFee() {
                self.mintscanCw20Tokens = cw20Tokens ?? []
                self.mintscanCw721List = cw721List ?? []
                self.cosmosAuth = auth
                self.cosmosBalances = balance
                
                delegations?.forEach({ delegation in
                    if (delegation.balance.amount != "0") {
                        self.cosmosDelegations.append(delegation)
                    }
                })
                self.cosmosUnbondings = unbonding
                self.cosmosRewards = rewards
                commission?.commission.forEach { commi in
                    if (commi.getAmount().compare(NSDecimalNumber.zero).rawValue > 0) {
                        self.cosmosCommissions.append(Cosmos_Base_V1beta1_Coin(commi.denom, commi.getAmount()))
                    }
                }
                self.rewardAddress = rewardaddr?.replacingOccurrences(of: "\"", with: "")
                
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
            print("lcd error \(error) ", chain.tag)
            return false
        }
    }
    
    override func fetchValidators() async -> Bool {
        if (cosmosValidators.count > 0) { return true }
        if let bonded = try? await fetchBondedValidator(),
           let unbonding = try? await fetchUnbondingValidator(),
           let unbonded = try? await fetchUnbondedValidator() {
            
            cosmosValidators.append(contentsOf: bonded ?? [])
            cosmosValidators.append(contentsOf: unbonding ?? [])
            cosmosValidators.append(contentsOf: unbonded ?? [])
            
            cosmosValidators.sort {
                if ($0.description_p.moniker == "Cosmostation") { return true }
                if ($1.description_p.moniker == "Cosmostation") { return false }
                if ($0.jailed && !$1.jailed) { return false }
                if (!$0.jailed && $1.jailed) { return true }
                return Double($0.tokens)! > Double($1.tokens)!
            }
            return true
        }
        return false
    }
    
    override func fetchCosmosCw721() {
        self.fetchAllCw721()
    }
    
    override func fetchCosmosAuth() async {
        if let auth = try? await fetchAuth() {
            self.cosmosAuth = auth
        }
    }
    
    override func fetchCosmosLastHeight() async throws -> Int64? {
        if let height = try? await fetchLastBlock() {
            return height
        }
        return nil
    }
    
    override func fetchCosmosIbcClient(_ ibcPath: MintscanPath) async throws -> UInt64? {
        if let revisionNumber = try? await fetchIbcClient(ibcPath) {
            return revisionNumber
        }
        return nil
    }
    
    override func fetchCosmosTx(_ txHash: String) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? {
        if let result = try await fetchTx(txHash) {
            return result
        }
        return nil
    }
    
    override func simulCosmosTx(_ simulTx: Cosmos_Tx_V1beta1_SimulateRequest) async throws -> UInt64? {
        return try! await simulateTx(simulTx)
    }
    
    override func broadCastCosmosTx(_ tx: Cosmos_Tx_V1beta1_BroadcastTxRequest) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        return try! await broadcastTx(tx)
    }
    
    override func updateBaseFee() async {
        cosmosBaseFees.removeAll()
        if (!chain.supportFeeMarket()) { return }
        let url = getLcd() + "feemarket/v1/gas_prices"
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        if let result = response?.feeMarket() {
            result.forEach { basefee in
                if (BaseData.instance.getAsset(chain.apiName, basefee.denom) != nil) {
                    self.cosmosBaseFees.append(basefee)
                }
            }
            self.cosmosBaseFees.sort {
                if ($0.denom == chain.stakeDenom) { return true }
                if ($1.denom == chain.stakeDenom) { return false }
                return false
            }
        }
    }
    
    override func onCheckCosmosVesting() {
        self.onCheckVesting()
    }
}

//about common grpc call
extension CosmosLcdFetcher {
    
    func fetchBondedValidator() async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let url = getLcd() + "cosmos/staking/v1beta1/validators?status=BOND_STATUS_BONDED&pagination.limit=300"
        let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response.validators(.bonded)
    }
    
    func fetchUnbondedValidator() async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let url = getLcd() + "cosmos/staking/v1beta1/validators?status=BOND_STATUS_UNBONDED&pagination.limit=500"
        let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response.validators(.unbonded)
    }
    
    func fetchUnbondingValidator() async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let url = getLcd() + "cosmos/staking/v1beta1/validators?status=BOND_STATUS_UNBONDING&pagination.limit=500"
        let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response.validators(.unbonding)
    }
    
    func fetchAuth() async throws -> JSON? {
        cosmosAccountNumber = nil
        cosmosSequenceNum = nil
        let url = getLcd() + "cosmos/auth/v1beta1/accounts/${address}".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
        if let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["account"] {
            cosmosAccountNumber = response.getAccountNum()
            cosmosSequenceNum = response.getSequenceNum()
            return response
        }
        return nil
    }
    
    func fetchBalance() async throws -> [Cosmos_Base_V1beta1_Coin]? {
        let url = getLcd() + "cosmos/bank/v1beta1/balances/${address}?pagination.limit=2000".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
        let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response.balances()
    }
    
    func fetchDelegation() async throws -> [Cosmos_Staking_V1beta1_DelegationResponse]? {
        let url = getLcd() + "cosmos/staking/v1beta1/delegations/${address}".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response?.delegations()
    }
    
    func fetchUnbondings() async throws -> [Cosmos_Staking_V1beta1_UnbondingDelegation]? {
        let url = getLcd() + "cosmos/staking/v1beta1/delegators/${address}/unbonding_delegations".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response?.undelegations()
    }
    
    func fetchRewards() async throws -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]? {
        let url = getLcd() + "cosmos/distribution/v1beta1/delegators/${address}/rewards".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response?.rewards()
    }
    
    func fetchCommission() async throws -> Cosmos_Distribution_V1beta1_ValidatorAccumulatedCommission? {
        let url = getLcd() + "cosmos/distribution/v1beta1/validators/${address}/commission".replacingOccurrences(of: "${address}", with: chain.bechOpAddress!)
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response?.commission()
    }
    
    func fetchRewardAddress() async throws -> String? {
        let url = getLcd() + "cosmos/distribution/v1beta1/delegators/${address}/withdraw_address".replacingOccurrences(of: "${address}", with: chain.bechAddress!)
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response?.rewardAddress()
    }
    
    func simulateTx(_ simulTx: Cosmos_Tx_V1beta1_SimulateRequest) async throws -> UInt64? {
        let param: Parameters = ["txBytes": try! simulTx.tx.serializedData().base64EncodedString() ]
        let url = getLcd() + "cosmos/tx/v1beta1/simulate"
        if let result = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value["gas_info"]["gas_used"].string {
            return UInt64(result)
        }
        return nil
    }
    
    func broadcastTx(_ tx: Cosmos_Tx_V1beta1_BroadcastTxRequest) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let param: Parameters = ["mode" : Cosmos_Tx_V1beta1_BroadcastMode.async.rawValue, "tx_bytes": try! tx.txBytes.base64EncodedString() ]
        let url = getLcd() + "cosmos/tx/v1beta1/txs"
        let result = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
        if (!result["tx_response"].isEmpty) {
            var response = Cosmos_Base_Abci_V1beta1_TxResponse()
            response.txhash = result["tx_response"]["txhash"].stringValue
            response.rawLog = result["tx_response"]["raw_log"].stringValue
            return response
        }
        throw AFError.explicitlyCancelled
    }
    
    func fetchTx( _ hash: String) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? {
        let url = getLcd() + "cosmos/tx/v1beta1/txs/${hash}".replacingOccurrences(of: "${hash}", with: hash)
        let result = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        if (!result["tx_response"].isEmpty) {
            var response = Cosmos_Tx_V1beta1_GetTxResponse()
            var txResponse = Cosmos_Base_Abci_V1beta1_TxResponse()
            txResponse.txhash = result["tx_response"]["txhash"].stringValue
            txResponse.code = result["tx_response"]["code"].uInt32Value
            txResponse.rawLog = result["tx_response"]["raw_log"].stringValue
            response.txResponse = txResponse
            return response
        }
        throw AFError.explicitlyCancelled
    }
    
    func fetchIbcClient(_ ibcPath: MintscanPath) async throws -> UInt64? {
        let url = getLcd() + "ibc/core/channel/v1/channels/${channel}/ports/${port}/client_state".replacingOccurrences(of: "${channel}", with: ibcPath.channel!).replacingOccurrences(of: "${port}", with: ibcPath.port!)
        let result = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        if let revision_number = result["identified_client_state"]["client_state"]["latest_height"]["revision_number"].string {
            return UInt64(revision_number)
        }
        return nil
    }
    
    func fetchLastBlock() async throws -> Int64? {
        var url = ""
        if (chain.name.starts(with: "G-Bridge")) {
            url = getLcd() + "/blocks/latest"
        } else {
            url = getLcd() + "cosmos/base/tendermint/v1beta1/blocks/latest"
        }
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        if let height = response?["block"]["header"]["height"].string {
            return Int64(height)!
        }
        return nil
    }
    
    func fetchAllCw20Balance(_ id: Int64) async {
        if (chain.supportCw20 == false) { return }
        Task {
            await mintscanCw20Tokens.concurrentForEach { cw20 in
                await self.fetchCw20Balance(cw20)
            }
        }
    }
    
    func fetchCw20Balance(_ tokenInfo: MintscanToken) async {
        let query: JSON = ["balance" : ["address" : self.chain.bechAddress!]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: tokenInfo.address!).replacingOccurrences(of: "${query_data}", with: queryBase64)
        if let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"] {
            if let balance = response["balance"].string {
                tokenInfo.setAmount(balance)
            }
        }
    }
    
    func fetchAllCw721() {
        cw721Models.removeAll()
        Task {
            await mintscanCw721List.concurrentForEach { list in
                var tokens = [Cw721TokenModel]()
                if let tokenIds = try? await self.fetchCw721TokenIds(list) {
                    await tokenIds?["tokens"].arrayValue.concurrentForEach { tokenId in
                        if let tokenInfo = try? await self.fetchCw721TokenInfo(list, tokenId.stringValue) {
                            let tokenDetail = try? await AF.request(BaseNetWork.msNftDetail(self.chain.apiName, list["contractAddress"].stringValue, tokenId.stringValue), method: .get).serializingDecodable(JSON.self).value
                            tokens.append(Cw721TokenModel.init(tokenId.stringValue, tokenInfo!, tokenDetail))
                        }
                    }
                }
                if (!tokens.isEmpty) {
                    self.cw721Models.append(Cw721Model(list, tokens))
                }
            }
            DispatchQueue.main.async(execute: {
                self.cw721Models.sort {
                    return $0.info["id"].doubleValue < $1.info["id"].doubleValue
                }
                self.cw721Models.forEach { cw721Model in
                    cw721Model.sortId()
                }
                NotificationCenter.default.post(name: Notification.Name("FetchNFTs"), object: self.chain.tag, userInfo: nil)
            })
        }
        
    }
    
    func fetchCw721TokenIds(_ list: JSON) async throws -> JSON? {
        let query: JSON = ["tokens" : ["owner" : self.chain.bechAddress!, "limit" : 50, "start_after" : "0"]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: list["contractAddress"].stringValue).replacingOccurrences(of: "${query_data}", with: queryBase64)
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]
    }
    
    func fetchCw721TokenInfo(_ list: JSON, _ tokenId: String) async throws -> JSON? {
        let query: JSON = ["nft_info" : ["token_id" : tokenId]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: list["contractAddress"].stringValue).replacingOccurrences(of: "${query_data}", with: queryBase64)
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]
    }
    
    func fetchSmartContractState(_ request: Cosmwasm_Wasm_V1_QuerySmartContractStateRequest) async throws -> JSON? {
        let url = getLcd() + "cosmwasm/wasm/v1/contract/${address}/smart/${query_data}".replacingOccurrences(of: "${address}", with: request.address).replacingOccurrences(of: "${query_data}", with: String.init(data: request.queryData, encoding: .utf8)!)
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]
    }
    
    func fetchBaseFee() async throws -> [Cosmos_Base_V1beta1_DecCoin]? {
        if (!chain.supportFeeMarket()) { return nil }
        let url = getLcd() + "feemarket/v1/gas_prices"
        let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
        return response?.feeMarket()
    }
    
    
    func getLcd() -> String {
        return chain.lcdUrl
    }
}



extension CosmosLcdFetcher {
    
    func onCheckVesting() {
        guard let authInfo = cosmosAuth else {
            return
        }
        
        if (authInfo["@type"].stringValue.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)) {
            let periodicVestingAccount = authInfo["baseVestingAccount"]
            cosmosBalances?.forEach({ coin in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                periodicVestingAccount["base_vesting_account"]["original_vesting"].array?.forEach({ coin in
                    if (coin["denom"].stringValue == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin["amount"].stringValue))
                    }
                })
                
                periodicVestingAccount["base_vesting_account"]["delegated_vesting"].array?.forEach({ coin in
                    if (coin["denom"].stringValue == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin["amount"].stringValue))
                    }
                })
                
                remainVesting = onParsePeriodicRemainVestingsAmountByDenom(denom)
                
                dpVesting = remainVesting.subtracting(delegatedVesting)

                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })
            
        } else if (authInfo["@type"].stringValue.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)) {
            let continuousVestingAccount = authInfo["baseVestingAccount"]
            cosmosBalances?.forEach({ coin in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                continuousVestingAccount["base_vesting_account"]["original_vesting"].array?.forEach({ coin in
                    if (coin["denom"].stringValue == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin["amount"].stringValue))
                    }
                })
                
                continuousVestingAccount["base_vesting_account"]["delegated_vesting"].array?.forEach({ coin in
                    if (coin["denom"].stringValue == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin["amount"].stringValue))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingStart = Int64(cosmosAuth?["start_time"].string ?? "0")! * 1000
                let vestingEnd = Int64(cosmosAuth?["base_vesting_account"]["end_time"].string ?? "0")! * 1000
                if (cTime < vestingStart) {
                    remainVesting = originalVesting
                } else if (cTime > vestingEnd) {
                    remainVesting = NSDecimalNumber.zero
                } else {
                    let progress = ((Float)(cTime - vestingStart)) / ((Float)(vestingEnd - vestingStart))
                    remainVesting = originalVesting.multiplying(by: NSDecimalNumber.init(value: 1 - progress), withBehavior: handler0Up)
                }
                
                dpVesting = remainVesting.subtracting(delegatedVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting)
                }
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })
            
        } else if (authInfo["@type"].stringValue.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)) {
            let delayedVestingAccount = authInfo["baseVestingAccount"]
            cosmosBalances?.forEach({ coin in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                delayedVestingAccount["base_vesting_account"]["original_vesting"].array?.forEach({ coin in
                    if (coin["denom"].stringValue == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin["amount"].stringValue))
                    }
                })
                
                delayedVestingAccount["base_vesting_account"]["delegated_vesting"].array?.forEach({ coin in
                    if (coin["denom"].stringValue == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin["amount"].stringValue))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingEnd = Int64(cosmosAuth?["base_vesting_account"]["end_time"].string ?? "0")! * 1000
                if (cTime < vestingEnd) {
                    remainVesting = originalVesting
                }
                
                dpVesting = remainVesting.subtracting(delegatedVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })
            
        }
    }
    
    
    func onParsePeriodicRemainVestingsAmountByDenom(_ denom: String) -> NSDecimalNumber {
        var results = NSDecimalNumber.zero
        let periods = onParsePeriodicRemainVestingsByDenom(denom)
        for vp in periods {
            for coin in vp.amount {
                if (coin.denom ==  denom) {
                    results = results.adding(NSDecimalNumber.init(string: coin.amount))
                }
            }
        }
        return results
    }
    
    func onParsePeriodicRemainVestingsByDenom(_ denom: String) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        for vp in onParsePeriodicRemainVestings() {
            for coin in vp.amount {
                if (coin.denom ==  denom) {
                    results.append(vp)
                }
            }
        }
        return results
    }
    
    func onParsePeriodicRemainVestings() -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        let cTime = Date().millisecondsSince1970
        for i in 0..<(cosmosAuth?["vesting_periods"].array!.count)! {
            let unlockTime = onParsePeriodicUnLockTime(i)
            if (cTime < unlockTime) {
                let temp = Cosmos_Vesting_V1beta1_Period.with {
                    $0.length = unlockTime
                    var coins = [Cosmos_Base_V1beta1_Coin]()
                    cosmosAuth?["vesting_periods"].array?[i]["amount"].array?.forEach({ rawCoin in
                        coins.append(Cosmos_Base_V1beta1_Coin.init(rawCoin["denom"].stringValue, rawCoin["amount"].stringValue))
                    })
                    $0.amount = coins
                }
                results.append(temp)
            }
        }
        return results
    }
    
    func onParsePeriodicUnLockTime(_ position: Int) -> Int64 {
        var result = Int64(cosmosAuth?["start_time"].stringValue ?? "0")
        for i in 0..<(position + 1) {
            let length = Int64(cosmosAuth?["vesting_periods"].array?[i]["length"].stringValue ?? "0")
            result = result! + length!
        }
        return result! * 1000
    }
}


extension JSON {
    
    func validators(_ status: Cosmos_Staking_V1beta1_BondStatus) -> [Cosmos_Staking_V1beta1_Validator]? {
        var result = [Cosmos_Staking_V1beta1_Validator]()
        self["validators"].array?.forEach({ validator in
            var temp = Cosmos_Staking_V1beta1_Validator()
            temp.operatorAddress = validator["operator_address"].stringValue
            temp.jailed = validator["jailed"].boolValue
            temp.tokens = validator["tokens"].stringValue
            temp.status = status
            
            var desription = Cosmos_Staking_V1beta1_Description()
            desription.moniker = validator["description"]["moniker"].stringValue
            desription.identity = validator["description"]["identity"].stringValue
            desription.website = validator["description"]["website"].stringValue
            desription.securityContact = validator["description"]["security_contact"].stringValue
            desription.details = validator["description"]["details"].stringValue
            temp.description_p = desription
            
            var commission = Cosmos_Staking_V1beta1_Commission()
            var commissionRates = Cosmos_Staking_V1beta1_CommissionRates()
            commissionRates.rate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["rate"].string).multiplying(byPowerOf10: 18).stringValue
            commissionRates.maxRate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["max_rate"].string).multiplying(byPowerOf10: 18).stringValue
            commissionRates.maxChangeRate = NSDecimalNumber(string: validator["commission"]["commission_rates"]["max_change_rate"].string).multiplying(byPowerOf10: 18).stringValue
            commission.commissionRates = commissionRates
            temp.commission = commission
            result.append(temp)
        })
        return result
    }
    
    func balances() -> [Cosmos_Base_V1beta1_Coin]? {
        var result = [Cosmos_Base_V1beta1_Coin]()
        self["balances"].array?.forEach({ coin in
            result.append(Cosmos_Base_V1beta1_Coin(coin["denom"].stringValue, coin["amount"].stringValue))
        })
        return result
    }
    
    func delegations() -> [Cosmos_Staking_V1beta1_DelegationResponse]? {
        var result = [Cosmos_Staking_V1beta1_DelegationResponse]()
        self["delegation_responses"].array?.forEach({ delegation in
            var temp = Cosmos_Staking_V1beta1_DelegationResponse()
            
            var staking = Cosmos_Staking_V1beta1_Delegation()
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
    
    func undelegations() -> [Cosmos_Staking_V1beta1_UnbondingDelegation]? {
        var result = [Cosmos_Staking_V1beta1_UnbondingDelegation]()
        self["unbonding_responses"].array?.forEach({ unbonding in
            var temp = Cosmos_Staking_V1beta1_UnbondingDelegation()
            temp.delegatorAddress = unbonding["delegator_address"].stringValue
            temp.validatorAddress = unbonding["validator_address"].stringValue
            
            var entries = [Cosmos_Staking_V1beta1_UnbondingDelegationEntry]()
            unbonding["entries"].array?.forEach({ entry in
                var tempEntry = Cosmos_Staking_V1beta1_UnbondingDelegationEntry()
                tempEntry.balance = entry["balance"].stringValue
                //TODO for refact!!
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
    
    func rewards() -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]? {
        var result = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
        self["rewards"].array?.forEach({ reward in
            var temp = Cosmos_Distribution_V1beta1_DelegationDelegatorReward()
            temp.validatorAddress = reward["validator_address"].stringValue
            
            var coins = [Cosmos_Base_V1beta1_DecCoin]()
            reward["reward"].array?.forEach({ rewardCoin in
                var tempDecoin = Cosmos_Base_V1beta1_DecCoin()
                tempDecoin.denom = rewardCoin["denom"].stringValue
                tempDecoin.amount = NSDecimalNumber(string: rewardCoin["amount"].stringValue).multiplying(byPowerOf10: 18).stringValue
                coins.append(tempDecoin)
            })
            temp.reward = coins
            
            result.append(temp)
        })
        return result
    }
    
    func commission() -> Cosmos_Distribution_V1beta1_ValidatorAccumulatedCommission? {
        var result = Cosmos_Distribution_V1beta1_ValidatorAccumulatedCommission()
        var coins = [Cosmos_Base_V1beta1_DecCoin]()
        self["commission"]["commission"].array?.forEach({ commission in
            var tempDecoin = Cosmos_Base_V1beta1_DecCoin()
            tempDecoin.denom = commission["denom"].stringValue
            tempDecoin.amount = NSDecimalNumber(string: commission["amount"].stringValue).multiplying(byPowerOf10: 18).stringValue
            coins.append(tempDecoin)
        })
        result.commission = coins
        return result
    }
    
    func rewardAddress() -> String? {
        return self["withdraw_address"].string
    }
    
    func feeMarket() -> [Cosmos_Base_V1beta1_DecCoin]? {
        var result = [Cosmos_Base_V1beta1_DecCoin]()
        self["prices"].array?.forEach({ coin in
            var tempDecoin = Cosmos_Base_V1beta1_DecCoin()
            tempDecoin.denom = coin["denom"].stringValue
            tempDecoin.amount = NSDecimalNumber(string: coin["amount"].stringValue).multiplying(byPowerOf10: 18).stringValue
            result.append(tempDecoin)
        })
        return result
    }
    
    func getAccountNum() -> UInt64 {
        if let result = self["account_number"].string {                                                         //BaseAccount
            return UInt64(result)!
        }
        if let result = self["base_vesting_account"]["base_account"]["account_number"].string {                 //PeriodicVestingAccount, ContinuousVestingAccount, DelayedVestingAccount
            return UInt64(result)!
        }
        if let result = self["base_account"]["account_number"].string {                                         //Injective_Types_V1beta1_EthAccount, Ethermint_Types_V1_EthAccount ,Artela_Types_V1_EthAccount
            return UInt64(result)!
        }
        if let result = self["account"]["base_vesting_account"]["base_account"]["account_number"].string {      //Desmos_Profiles_V3_Profile, vesting
            return UInt64(result)!
        }
        if let result = self["account"]["base_account"]["account_number"].string {                              //Desmos_Profiles_V3_Profile
            return UInt64(result)!
        }
        if let result = self["account"]["account_number"]["account_number"].string {                            //Desmos_Profiles_V3_Profile
            return UInt64(result)!
        }
        return 0
    }
    
    
    func getSequenceNum() -> UInt64 {
        if let result = self["sequence"].string {                                                               //BaseAccount
            return UInt64(result)!
        }
        if let result = self["base_vesting_account"]["base_account"]["sequence"].string {                       //PeriodicVestingAccount, ContinuousVestingAccount, DelayedVestingAccount
            return UInt64(result)!
        }
        if let result = self["base_account"]["sequence"].string {                                               //Injective_Types_V1beta1_EthAccount, Ethermint_Types_V1_EthAccount ,Artela_Types_V1_EthAccount
            return UInt64(result)!
        }
        if let result = self["account"]["base_vesting_account"]["base_account"]["sequence"].string {            //Desmos_Profiles_V3_Profile, vesting
            return UInt64(result)!
        }
        if let result = self["account"]["base_account"]["sequence"].string {                                    //Desmos_Profiles_V3_Profile
            return UInt64(result)!
        }
        if let result = self["account"]["account_number"]["sequence"].string {                                  //Desmos_Profiles_V3_Profile
            return UInt64(result)!
        }
        return 0
    }
}
