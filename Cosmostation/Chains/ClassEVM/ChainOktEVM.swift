//
//  ChainOktEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChainOktEVM: EvmClass  {
    
    //For Legacy Lcd chains
    lazy var lcdNodeInfo = JSON()
    lazy var lcdAccountInfo = JSON()
    lazy var lcdOktDeposits = JSON()
    lazy var lcdOktWithdaws = JSON()
    lazy var lcdOktTokens = Array<JSON>()
    lazy var lcdOktValidators = Array<JSON>()
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "OKT"
        tag = "okt60_Keccak"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        apiName = "okc"
        stakeDenom = "okt"
        
        coinSymbol = "OKT"
        coinGeckoId = "oec-token"
        coinLogo = "tokenOkt"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "ex"
        supportStaking = false
        
        evmRpcURL = "https://exchainrpc.okex.org"
        explorerURL = "https://www.oklink.com/oktc/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
    
    override func fetchData(_ id: Int64) {
        let group = DispatchGroup()
        fetchChainParam2(group)
        fetchErc20Info2(group)
//        fetchEvmBalance(group)
        
        fetchNodeInfo(group)
        fetchAccountInfo(group, bechAddress)
        fetchOktDeposited(group, bechAddress)
        fetchOktWithdraw(group, bechAddress)
        fetchOktTokens(group)
        
        group.notify(queue: .main) {
            self.fetched = true
            self.allCoinValue = self.allCoinValue()
            self.allCoinUSDValue = self.allCoinValue(true)
//            self.fetchEvmBalance2()
            self.fetchAllErc20Balance(id)
            
            BaseData.instance.updateRefAddressesCoinValue(
                RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                           self.lcdAllStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                           nil, self.lcdAccountInfo.oktCoins?.count))
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
        }
    }
    
    override func fetchPreCreate() {
        let group = DispatchGroup()
        fetchAccountInfo(group, bechAddress)
        group.notify(queue: .main) {
            self.fetched = true
            NotificationCenter.default.post(name: Notification.Name("FetchPreCreate"), object: self.tag, userInfo: nil)
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

extension ChainOktEVM {
    
    func fetchValidators() {
        let group = DispatchGroup()
        fetchOktValdators(group)
        
        group.notify(queue: .main) {
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
    
    func fetchNodeInfo(_ group: DispatchGroup) {
//        print("fetchNodeInfo Start ", BaseNetWork.lcdNodeInfoUrl(self))
        group.enter()
        AF.request(BaseNetWork.lcdNodeInfoUrl(self), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdNodeInfo = value
//                    print("fetchNodeInfo ", value)
                case .failure:
                    print("fetchNodeInfo error")
                }
                group.leave()
            }
    }
    
    func fetchAccountInfo(_ group: DispatchGroup, _ address: String) {
//        print("fetchAccountInfo Start ", BaseNetWork.lcdAccountInfoUrl(self, address))
        group.enter()
        AF.request(BaseNetWork.lcdAccountInfoUrl(self, address), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdAccountInfo = value
//                    print("fetchAccountInfo ", value)
                case .failure:
                    print("fetchAccountInfo error")
                }
                group.leave()
            }
    }
    
    func fetchOktDeposited(_ group: DispatchGroup, _ address: String) {
//        print("fetchOktDeposited Start ", BaseNetWork.lcdOktDepositUrl(address))
        group.enter()
        AF.request(BaseNetWork.lcdOktDepositUrl(address), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdOktDeposits = value
//                    print("fetchOktDeposited ", value)
                case .failure:
                    print("fetchOktDeposited error")
                }
                group.leave()
            }
    }
    
    func fetchOktWithdraw(_ group: DispatchGroup, _ address: String) {
//        print("fetchOktWithdraw Start ", BaseNetWork.lcdOktWithdrawUrl(address))
        group.enter()
        AF.request(BaseNetWork.lcdOktWithdrawUrl( address), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdOktWithdaws = value
                case .failure:
                    print("fetchOktWithdraw error")
                }
                group.leave()
            }
    }
    
    func fetchOktTokens(_ group: DispatchGroup) {
        group.enter()
        AF.request(BaseNetWork.lcdOktTokenUrl(), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let values):
                    values["data"].array?.forEach({ value in
                        self.lcdOktTokens.append(value)
                    })
                    
                case .failure:
                    print("fetchOktTokens error")
                }
                group.leave()
            }
    }
    
    func fetchOktValdators(_ group: DispatchGroup) {
        group.enter()
        AF.request(BaseNetWork.lcdOktValidatorsUrl(), method: .get, parameters: ["status":"all"])
            .responseDecodable(of: [JSON].self) { response in
                switch response.result {
                case .success(let values):
                    self.lcdOktValidators.removeAll()
                    values.forEach { validator in
                        self.lcdOktValidators.append(validator)
                    }
                case .failure:
                    print("fetchOktValdators error")
                }
                group.leave()
            }
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
