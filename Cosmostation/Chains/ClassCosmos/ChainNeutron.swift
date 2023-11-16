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
    
    lazy var vaultsList = [JSON]()
    lazy var daosList = [JSON]()
    
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
        supportStaking = false
        
        grpcHost = "grpc-neutron.cosmostation.io"
    }
    
    override func fetchPropertyData(_ channel: ClientConnection, _ id: Int64) {
        Task {
            if let vault = try? await self.fetchVaults(),
               let daos = try? await self.fetchDaos() {
                self.vaultsList = vault
                self.daosList = daos
            }
            
            let group = DispatchGroup()
            
            fetchBalance(group, channel)
            fetchNeutronVesting(group, channel)
            if (vaultsList.count > 0) {
                fetchVaultDeposit(group, channel)
            }
            
            group.notify(queue: .main) {
                try? channel.close()
                WUtils.onParseVestingAccount(self)
                self.fetched = true
                self.allCoinValue = self.allCoinValue()
                self.allCoinUSDValue = self.allCoinValue(true)
                
                BaseData.instance.updateRefAddressesMain(
                    RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                               self.allStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                               nil, self.cosmosBalances?.count))
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
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
    
    func fetchVaults() async throws -> [JSON] {
        return try await AF.request(NEUTRON_MAIN_VAULTS, method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchDaos() async throws -> [JSON] {
        return try await AF.request(NEUTRON_MAIN_DAOS, method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchVaultDeposit(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let query: JSON = ["voting_power_at_height" : ["address" : bechAddress]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = vaultsList[0]["address"].stringValue
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let response = try? Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.wait() {
            if let deposited = try? JSONDecoder().decode(JSON.self, from: response.data),
               let amount = deposited["power"].string {
                self.neutronDeposited = NSDecimalNumber(string: amount)
            }
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func fetchNeutronVesting(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let query: JSON = ["allocation" : ["address" : bechAddress]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = NEUTRON_VESTING_CONTRACT_ADDRESS
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let response = try? Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.wait() {
            if let vestingInfo = try? JSONDecoder().decode(JSON.self, from: response.data) {
                self.neutronVesting = vestingInfo
            }
            group.leave()
        } else {
            group.leave()
        }
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
let NEUTRON_VESTING_CONTRACT_ADDRESS = "neutron1h6828as2z5av0xqtlh4w9m75wxewapk8z9l2flvzc29zeyzhx6fqgp648z"

let NEUTRON_MAIN_VAULTS = "https://raw.githubusercontent.com/cosmostation/chainlist/main/chain/neutron/vaults.json"
let NEUTRON_MAIN_DAOS = "https://raw.githubusercontent.com/cosmostation/chainlist/main/chain/neutron/daos.json"

