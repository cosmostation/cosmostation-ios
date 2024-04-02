//
//  ChainNeutron.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Alamofire
import SwiftyJSON

class ChainNeutron: CosmosClass  {
    
    var vaultsList: [JSON]?
    var daosList: [JSON]?
    var neutronDeposited = NSDecimalNumber.zero
    var neutronVesting: JSON?
    
    override init() {
        super.init()
        
        name = "Neutron"
        tag = "neutron118"
        logo1 = "chainNeutron"
        logo2 = "chainNeutron2"
        apiName = "neutron"
        stakeDenom = "untrn"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "neutron"
        validatorPrefix = "neutronvaloper"
        supportStaking = false
        supportCw20 = true
        
        grpcHost = "grpc-neutron.cosmostation.io"
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        cosmosAuth = nil
        cosmosBalances = nil
        neutronDeposited = NSDecimalNumber.zero
        neutronVesting = nil
        vaultsList = getChainListParam()["vaults"].arrayValue
        daosList = getChainListParam()["daos"].arrayValue
        
        Task {
            do {
                let channel = getConnection()
                if let cw20Tokens = try await fetchCw20Info(),
                   let auth = try await fetchAuth(channel),
                   let balance = try await fetchBalance(channel),
                   let vault = try? await fetchVaultDeposit(channel),
                   let vesting = try? await fetchNeutronVesting(channel) {
                    self.mintscanCw20Tokens = cw20Tokens
                    self.cosmosAuth = auth
                    self.cosmosBalances = balance
                    if let vault = vault,
                       let deposited = try? JSONDecoder().decode(JSON.self, from: vault) {
                        self.neutronDeposited = NSDecimalNumber(string: deposited["power"].string)
                    }
                    if let vesting = vesting,
                       let vestingInfo = try? JSONDecoder().decode(JSON.self, from: vesting) {
                        self.neutronVesting = vestingInfo
                    }
                }
                
                DispatchQueue.main.async {
                    WUtils.onParseVestingAccount(self)
                    self.fetchState = .Success
                    self.allCoinValue = self.allCoinValue()
                    self.allCoinUSDValue = self.allCoinValue(true)
//                    print("Done ", self.tag, "  ", self.allCoinValue)
                    if (self.supportCw20) { self.fetchAllCw20Balance(id) }
                    
                    BaseData.instance.updateRefAddressesCoinValue(
                        RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                                   self.allStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                                   nil, self.cosmosBalances?.filter({ BaseData.instance.getAsset(self.apiName, $0.denom) != nil }).count))
                    NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                    try? channel.close()
                }
                
            } catch {
                print("error ",tag, "  ", error)
                DispatchQueue.main.async {
                    if let errorMessage = (error as? GRPCStatus)?.message,
                       errorMessage.contains(self.bechAddress) == true,
                       errorMessage.contains("not found") == true {
                        self.fetchState = .Success
                        BaseData.instance.updateRefAddressesCoinValue(
                            RefAddress(id, self.tag, self.bechAddress, self.evmAddress))
                    } else {
                        self.fetchState = .Fail
                    }
                    NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                }
            }
        }
    }
    
    override func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
            return balanceValue(denom, usd).adding(neutronVestingValue(usd)).adding(neutronDepositedValue(usd))
        } else {
            return balanceValue(denom, usd)
        }
    }
    
    override func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(stakeDenom).adding(neutronVestingAmount()).adding(neutronDeposited)
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(neutronVestingValue(usd)).adding(neutronDepositedValue(usd))
    }
}

extension ChainNeutron {
    
    func fetchVaultDeposit(_ channel: ClientConnection?) async throws -> Data? {
        if (channel == nil) { return nil }
        let query: JSON = ["voting_power_at_height" : ["address" : bechAddress]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = NEUTRON_VAULT_ADDRESS
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel!).smartContractState(req, callOptions: getCallOptions()).response.get().data
    }
    
    func fetchNeutronVesting(_ channel: ClientConnection?) async throws -> Data? {
        if (channel == nil) { return nil }
        let query: JSON = ["allocation" : ["address" : bechAddress]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = NEUTRON_VESTING_CONTRACT_ADDRESS
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel!).smartContractState(req, callOptions: getCallOptions()).response.get().data
    }
    
    func neutronVestingAmount() -> NSDecimalNumber  {
        if let allocated = neutronVesting?["allocated_amount"].string,
           let withdrawn = neutronVesting?["withdrawn_amount"].string {
            let allocatedAmount = NSDecimalNumber(string: allocated)
            let withdrawnAmount = NSDecimalNumber(string: withdrawn)
            return allocatedAmount.subtracting(withdrawnAmount)
        }
        return NSDecimalNumber.zero
    }
    
    func neutronVestingValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = neutronVestingAmount()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func neutronDepositedValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = neutronDeposited
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
}

//Neutron Contract Address
let NEUTRON_VAULT_ADDRESS = "neutron1qeyjez6a9dwlghf9d6cy44fxmsajztw257586akk6xn6k88x0gus5djz4e"
let NEUTRON_VESTING_CONTRACT_ADDRESS = "neutron1h6828as2z5av0xqtlh4w9m75wxewapk8z9l2flvzc29zeyzhx6fqgp648z"
