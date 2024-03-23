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
        chainId = "exchain-66"
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
        lcdNodeInfo = JSON()
        lcdAccountInfo = JSON()
        lcdOktDeposits = JSON()
        lcdOktWithdaws = JSON()
        lcdOktTokens.removeAll()
        
        Task {
            if let nodeInfo = try? await fetchNodeInfo(),
               let accountInfo = try? await fetchAccountInfo(bechAddress),
               let okDeposit = try? await fetchOktDeposited(bechAddress),
               let okWithdraw = try? await fetchOktWithdraw(bechAddress),
               let okTokens = try? await fetchOktTokens() {
                self.lcdNodeInfo = nodeInfo ?? JSON()
                self.lcdAccountInfo = accountInfo ?? JSON()
                self.lcdOktDeposits = okDeposit ?? JSON()
                self.lcdOktWithdaws = okWithdraw ?? JSON()
                okTokens?["data"].array?.forEach({ value in
                    self.lcdOktTokens.append(value)
                })
            }
            
            DispatchQueue.main.async {
                self.fetched = true
                self.allCoinValue = self.allCoinValue()
                self.allCoinUSDValue = self.allCoinValue(true)
                
                BaseData.instance.updateRefAddressesCoinValue(
                    RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                               self.lcdAllStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                               nil, self.lcdAccountInfo.oktCoins?.count))
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
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
                self.fetched = true
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
    
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "okc/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
}


extension ChainOkt996Keccak {
    
    func fetchNodeInfo() async throws -> JSON? {
        return try? await AF.request(BaseNetWork.lcdNodeInfoUrl(self), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchAccountInfo(_ address: String) async throws -> JSON? {
        return try? await AF.request(BaseNetWork.lcdAccountInfoUrl(self, address), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktDeposited(_ address: String) async throws -> JSON? {
        return try? await AF.request(BaseNetWork.lcdOktDepositUrl(address), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktWithdraw(_ address: String) async throws -> JSON? {
        return try? await AF.request(BaseNetWork.lcdOktWithdrawUrl(address), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktTokens() async throws -> JSON? {
        return try? await AF.request(BaseNetWork.lcdOktTokenUrl(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchOktValdators() async throws -> [JSON]? {
        return try? await AF.request(BaseNetWork.lcdOktValidatorsUrl(), method: .get, parameters: ["status":"all"]).serializingDecodable([JSON].self).value
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

let OKT_LCD = "https://exchainrpc.okex.org/okexchain/v1/"
let OKT_EXPLORER = "https://www.oklink.com/oktc/"
let OKT_BASE_FEE = "0.008"
let OKT_GECKO_ID = "oec-token"
