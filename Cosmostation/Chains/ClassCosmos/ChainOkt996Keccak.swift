//
//  ChainOkt996Keccak.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChainOkt996Keccak: BaseChain  {
    
    var oktFetcher: OktFetcher?
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt996_Keccak"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        isDefault = false
        supportCosmos = true
        apiName = "okc"
        
        stakeDenom = "okt"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/996'/0'/0/X")
        bechAccountPrefix = "ex"
        supportStaking = false
        isGrpc = false
        
        initFetcher()
    }
    
    override func getLcdfetcher() -> FetcherLcd? {
        return oktFetcher
    }
    
    override func initFetcher() {
        oktFetcher = OktFetcher.init(self)
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let result = await oktFetcher?.fetchLcdData(id)
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let oktFetcher = oktFetcher, fetchState == .Success {
                allCoinValue = oktFetcher.allCoinValue()
                allCoinUSDValue = oktFetcher.allCoinValue(true)
                
                BaseData.instance.updateRefAddressesCoinValue(
                    RefAddress(id, self.tag, self.bechAddress!, self.evmAddress ?? "",
                               oktFetcher.lcdAllStakingDenomAmount().stringValue, allCoinUSDValue.stringValue,
                               nil, oktFetcher.lcdAccountInfo.oktCoins?.count))
            }
            
            DispatchQueue.main.async(execute: {
                print("", self.tag, " FetchData post")
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
        
    }
}

class OktFetcher: FetcherLcd {
    var lcdOktDeposits = JSON()
    var lcdOktWithdaws = JSON()
    var lcdOktTokens = Array<JSON>()
    var lcdOktValidators = Array<JSON>()
    
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
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return lcdBalanceValue(chain.stakeDenom!, usd).adding(lcdOktDepositValue(usd)).adding(lcdOktWithdrawValue(usd))
    }
    
    func lcdAllStakingDenomAmount() -> NSDecimalNumber {
        return lcdBalanceAmount(chain.stakeDenom!).adding(lcdOktDepositAmount()).adding(lcdOktWithdrawAmount())
    }
    
    func lcdBalanceAmount(_ denom: String) -> NSDecimalNumber {
        if let balance = lcdAccountInfo.oktCoins?.filter({ $0["denom"].string == denom }).first {
            return NSDecimalNumber.init(string: balance["amount"].string ?? "0")
        }
        return NSDecimalNumber.zero
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
        return try await AF.request(url, method: .get, parameters: ["status":"all"]).serializingDecodable([JSON].self).value
    }
}
/*
class ChainOkt996Keccak: CosmosClass  {
    
    //For Legacy Lcd chains
    lazy var lcdNodeInfo = JSON()
    lazy var lcdAccountInfo = JSON()
    lazy var lcdOktDeposits = JSON()
    lazy var lcdOktWithdaws = JSON()
    lazy var lcdOktTokens = Array<JSON>()
    lazy var lcdOktValidators = Array<JSON>()
    
    override init() {
        super.init()
        
        isDefault = false
        
        name = "OKT"
        tag = "okt996_Keccak"
        chainIdCosmos = "exchain-66"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        apiName = "okc"
        stakeDenom = "okt"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/996'/0'/0/X")
        bechAccountPrefix = "ex"
        supportStaking = false
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        lcdNodeInfo = JSON()
        lcdAccountInfo = JSON()
        lcdOktDeposits = JSON()
        lcdOktWithdaws = JSON()
        lcdOktTokens.removeAll()
        
        Task {
            do {
                if let nodeInfo = try await fetchNodeInfo(),
                   let accountInfo = try await fetchAccountInfo(bechAddress),
                   let okDeposit = try await fetchOktDeposited(bechAddress),
                   let okWithdraw = try await fetchOktWithdraw(bechAddress),
                   let okTokens = try await fetchOktTokens() {
                    self.lcdNodeInfo = nodeInfo
                    self.lcdAccountInfo = accountInfo
                    self.lcdOktDeposits = okDeposit
                    self.lcdOktWithdaws = okWithdraw
                    okTokens["data"].array?.forEach({ value in
                        self.lcdOktTokens.append(value)
                    })
                }
                
                DispatchQueue.main.async {
                    self.fetchState = .Success
                    self.allCoinValue = self.allCoinValue()
                    self.allCoinUSDValue = self.allCoinValue(true)
                    
                    BaseData.instance.updateRefAddressesCoinValue(
                        RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                                   self.lcdAllStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                                   nil, self.lcdAccountInfo.oktCoins?.count))
                    NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                }
                
            } catch {
//                print("Error Cosmos", self.tag,  error)
                DispatchQueue.main.async {
                    self.fetchState = .Fail
                    NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                }
            }
        }
    }
    
    override func fetchPreCreate() {
        lcdAccountInfo = JSON()
        Task {
            if let accountInfo = try? await fetchAccountInfo(bechAddress) {
                self.lcdAccountInfo = accountInfo ?? JSON()
            }
            
            DispatchQueue.main.async {
                self.fetchState = .Success
                NotificationCenter.default.post(name: Notification.Name("FetchPreCreate"), object: self.tag, userInfo: nil)
            }
        }
    }
    
    func fetchValidators() {
        lcdOktValidators.removeAll()
        Task {
            if let okValidators = try? await fetchOktValdators() {
                okValidators?.forEach { validator in
                    self.lcdOktValidators.append(validator)
                }
            }
            
            DispatchQueue.main.async {
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
                NotificationCenter.default.post(name: Notification.Name("FetchStakeData"), object: self.tag, userInfo: nil)
            }
        }
    }
    
    override func isTxFeePayable() -> Bool {
        let availableAmount = lcdBalanceAmount(stakeDenom)
        return availableAmount.compare(NSDecimalNumber(string: OKT_BASE_FEE)).rawValue > 0
    }
    
    override func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return lcdBalanceValue(stakeDenom, usd).adding(lcdOktDepositValue(usd)).adding(lcdOktWithdrawValue(usd))
    }
    
    
    
}


extension ChainOkt996Keccak {
    
    func fetchNodeInfo() async throws -> JSON? {
        return try await AF.request(BaseNetWork.lcdNodeInfoUrl(self), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchAccountInfo(_ address: String) async throws -> JSON? {
        return try await AF.request(BaseNetWork.lcdAccountInfoUrl(self, address), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktDeposited(_ address: String) async throws -> JSON? {
        return try await AF.request(BaseNetWork.lcdOktDepositUrl(address), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktWithdraw(_ address: String) async throws -> JSON? {
        return try await AF.request(BaseNetWork.lcdOktWithdrawUrl(address), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktTokens() async throws -> JSON? {
        return try await AF.request(BaseNetWork.lcdOktTokenUrl(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktValdators() async throws -> [JSON]? {
        return try await AF.request(BaseNetWork.lcdOktValidatorsUrl(), method: .get, parameters: ["status":"all"]).serializingDecodable([JSON].self).value
    }
    
    
    
    func lcdAllStakingDenomAmount() -> NSDecimalNumber {
        return lcdBalanceAmount(stakeDenom).adding(lcdOktDepositAmount()).adding(lcdOktWithdrawAmount())
    }
    
    func lcdBalanceAmount(_ denom: String) -> NSDecimalNumber {
        if let balance = lcdAccountInfo.oktCoins?.filter({ $0["denom"].string == denom }).first {
            return NSDecimalNumber.init(string: balance["amount"].string ?? "0")
        }
        return NSDecimalNumber.zero
        
    }
    
    func lcdBalanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
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
*/

let OKT_LCD = "https://exchainrpc.okex.org/okexchain/v1/"
let OKT_BASE_FEE = "0.008"
let OKT_GECKO_ID = "oec-token"
