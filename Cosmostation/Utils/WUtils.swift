//
//  WUtils.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import UIKit
import SwiftProtobuf
import web3swift
import BigInt



public class WUtils {
    
    static func getHtlcSwappableCoin(_ chain: BaseChain) -> Array<String> {
        var result = Array<String>()
        if (chain is ChainBinanceBeacon) {
            result.append(TOKEN_HTLC_BINANCE_BNB)
            result.append(TOKEN_HTLC_BINANCE_BTCB)
            result.append(TOKEN_HTLC_BINANCE_XRPB)
            result.append(TOKEN_HTLC_BINANCE_BUSD)
            
        } else if (chain.tag.starts(with: "kava")) {
            result.append(TOKEN_HTLC_KAVA_BNB)
            result.append(TOKEN_HTLC_KAVA_BTCB)
            result.append(TOKEN_HTLC_KAVA_XRPB)
            result.append(TOKEN_HTLC_KAVA_BUSD)
            
        }
        return result
    }
    
    static func isHtlcSwappableCoin(_ chain: BaseChain, _ denom: String?) -> Bool {
        if (chain is ChainBinanceBeacon) {
            if (denom == TOKEN_HTLC_BINANCE_BNB) { return true }
            if (denom == TOKEN_HTLC_BINANCE_BTCB) { return true }
            if (denom == TOKEN_HTLC_BINANCE_XRPB) { return true }
            if (denom == TOKEN_HTLC_BINANCE_BUSD) { return true }
        }  else if (chain.tag.starts(with: "kava")) {
            if (denom == TOKEN_HTLC_KAVA_BNB) { return true }
            if (denom == TOKEN_HTLC_KAVA_BTCB) { return true }
            if (denom == TOKEN_HTLC_KAVA_XRPB) { return true }
            if (denom == TOKEN_HTLC_KAVA_BUSD) { return true }
        }
        return false
    }
    
    static func timeStringToDate(_ input: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let result = dateFormatter.date(from: input) {
            return result
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let result = dateFormatter.date(from: input) {
            return result
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        if let result = dateFormatter.date(from: input) {
            return result
        }
        return nil
    }

    static func timeInt64ToDate(_ input: Int64) -> Date? {
        return Date.init(milliseconds: Int(input))
    }

    static func getGapTime(_ date: Date) -> String {
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        var gapTime = Int(Date().timeIntervalSince(date))
        if (gapTime > 0) {
            if gapTime < minute {
                return "\(gapTime) seconds ago"
            } else if gapTime < hour {
                return "\(gapTime / minute) minutes ago"
            } else if gapTime < day {
                return "\(gapTime / hour) hours ago"
            } else {
                return "\(gapTime / day) days ago"
            }

        } else {
            gapTime = gapTime * -1
            if gapTime < day {
                return "H-\(gapTime / hour)"
            } else {
                return "D-\(gapTime / day)"
            }
        }
    }
    
    //for okt ("0.1"  -> "0.10000000000000000")
    static func getFormattedNumber(_ amount: NSDecimalNumber, _ dpPoint:Int16) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = Int(dpPoint)
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal

        let formatted = nf.string(from: amount)?.replacingOccurrences(of: ",", with: "" )
        return formatted!
    }
    
    
    static func assetValue(_ geckoId: String?, _ amount: String?, _ decimals: Int16) -> NSDecimalNumber {
        let price = BaseData.instance.getPrice(geckoId)
        let amount = NSDecimalNumber(string: amount)
        return price.multiplying(by: amount).multiplying(byPowerOf10: -decimals, withBehavior: handler3Down)
    }
    
    static func getNumberFormatter(_ divider: Int) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = divider
        nf.maximumFractionDigits = divider
        return nf
    }

    static func getDpAttributedString(_ dpString: String, _ divider: Int, _ font: UIFont?) -> NSMutableAttributedString? {
        if (font == nil) { return nil }
        let endIndex    = dpString.index(dpString.endIndex, offsetBy: -divider)
        let preString   = dpString[..<endIndex]
        let postString  = dpString[endIndex...]
        let preAttrs    = [NSAttributedString.Key.font : font]
        let postAttrs   = [NSAttributedString.Key.font : font!.withSize(CGFloat(Int(Double(font!.pointSize) * 0.85)))]

        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func getMintscanPath(_ fromChain: CosmosClass, _ toChain: CosmosClass, _ denom: String) -> MintscanPath? {
        let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom?.lowercased() == denom.lowercased() }).first
        var msToken: MintscanToken?
        if let tokenInfo = fromChain.mintscanCw20Tokens.filter({ $0.address == denom }).first {
            msToken = tokenInfo
        } 
        
//        else if let tokenInfo = fromChain.mintscanErc20Tokens.filter({ $0.address == denom }).first {
//            msToken = tokenInfo
//        }
        var result: MintscanPath?
        BaseData.instance.mintscanAssets?.forEach { asset in
            if (msAsset != nil) {
                if (asset.chain == fromChain.apiName &&
                    asset.beforeChain(fromChain.apiName) == toChain.apiName &&
                    asset.denom?.lowercased() == denom.lowercased()) {
                    result = MintscanPath.init(asset.channel!, asset.port!)
                    return
                }
                if (asset.chain == toChain.apiName &&
                    asset.beforeChain(toChain.apiName) == fromChain.apiName &&
                    asset.counter_party?.denom?.lowercased() == denom.lowercased()) {
                    result = MintscanPath.init(asset.counter_party!.channel!, asset.counter_party!.port!)
                    return
                }

            } else if (msToken != nil) {
                if (asset.chain == toChain.apiName &&
                    asset.beforeChain(toChain.apiName) == fromChain.apiName &&
                    asset.counter_party?.denom?.lowercased() == msToken?.address!.lowercased()) {
                    result = MintscanPath.init(asset.counter_party!.channel!, asset.counter_party!.port!)
                    return
                }
            }
        }
        return result
    }
    
    
    static func isValidBechAddress(_ chain: CosmosClass, _ address: String?) -> Bool {
        if (address?.isEmpty == true) {
            return false
        }
        if (address!.starts(with: "0x")) {
            //TODO
            return false
        }
        guard let _ = try? Bech32().decode(address!) else {
            return false
        }
        
        if (!address!.starts(with: chain.bechAccountPrefix! + "1")) {
            return false
        }
        return true
        
    }
    
    static func isValidEvmAddress(_ address: String?) -> Bool {
        if (address?.isEmpty == true) {
            return false
        }
        if let evmAddess = EthereumAddress.init(address!) {
            return true
        }
        return false
    }
//
//    static func getChainsFromAddress(_ address: String?) -> ChainType? {
//        if let address = address, address.starts(with: "0x") {
//            if (WKey.isValidEthAddress(address)) { return .OKEX_MAIN }
//            return nil
//        }
//        if (!WKey.isValidateBech32(address ?? "")) { return nil }
//        let allConfigs = ChainFactory.SUPPRT_CONFIG()
//        for i in 0..<allConfigs.count {
//            let addressPrfix = allConfigs[i].addressPrefix + "1"
//            if (address?.starts(with: addressPrfix) == true) {
//                return allConfigs[i].chainType
//            }
//        }
//        return nil
//    }
//
//
//    static func systemQuorum() -> NSDecimalNumber {
//        if (BaseData.instance.mParam != nil) {
//            return BaseData.instance.mParam!.getQuorum()
//        }
//        return NSDecimalNumber.zero
//    }
//
//    static func expeditedQuorum() -> NSDecimalNumber {
//        if (BaseData.instance.mParam != nil) {
//            return BaseData.instance.mParam!.getExpeditedQuorum()
//        }
//        return NSDecimalNumber.zero
//    }
//
//    static func systemThreshold() -> NSDecimalNumber {
//        if (BaseData.instance.mParam != nil) {
//            return BaseData.instance.mParam!.getThreshold()
//        }
//        return NSDecimalNumber.zero
//    }
//
//    static func systemVetoThreshold() -> NSDecimalNumber {
//        if (BaseData.instance.mParam != nil) {
//            return BaseData.instance.mParam!.getVetoThreshold()
//        }
//        return NSDecimalNumber.zero
//    }
//
//
    //address, accountnumber, sequencenumber
    static func onParseAuthGrpc(_ response :Cosmos_Auth_V1beta1_QueryAccountResponse) -> (address: String?, accountNum: UInt64?, sequenceNum: UInt64?) {
        var rawAccount = response.account
        if (rawAccount.typeURL.contains(Desmos_Profiles_V3_Profile.protoMessageName)),
            let account = try? Desmos_Profiles_V3_Profile.init(serializedData: rawAccount.value).account {
            rawAccount = account
        }

        if (rawAccount.typeURL.contains(Cosmos_Auth_V1beta1_BaseAccount.protoMessageName)),
           let auth = try? Cosmos_Auth_V1beta1_BaseAccount.init(serializedData: rawAccount.value) {
            return (auth.address, auth.accountNumber, auth.sequence)

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value){
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)),
                  let auth = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)),
                    let auth = try? Ethermint_Types_V1_EthAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        }  else if (rawAccount.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName)),
                  let auth = try? Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: rawAccount.value){
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)
        }

        return (nil, nil, nil)
    }
    
    static func onParseAuthPubkeyType(_ response :Cosmos_Auth_V1beta1_QueryAccountResponse?) -> String? {
        if (response == nil) { return nil }
        
        var rawAccount = response!.account
        if (rawAccount.typeURL.contains(Desmos_Profiles_V3_Profile.protoMessageName)),
            let account = try? Desmos_Profiles_V3_Profile.init(serializedData: rawAccount.value).account {
            rawAccount = account
        }

        if (rawAccount.typeURL.contains(Cosmos_Auth_V1beta1_BaseAccount.protoMessageName)),
           let auth = try? Cosmos_Auth_V1beta1_BaseAccount.init(serializedData: rawAccount.value) {
            return auth.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value) {
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value){
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value) {
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)),
                  let auth = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
            return auth.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)),
                    let auth = try? Ethermint_Types_V1_EthAccount.init(serializedData: rawAccount.value) {
            return auth.baseAccount.pubKey.typeURL

        }  else if (rawAccount.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName)),
                  let auth = try? Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: rawAccount.value){
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL
        }
        return nil
    }
//
//
//    static func onParseAuthAccount(_ chain: ChainType, _ accountId: Int64) {
//        guard let rawAccount = BaseData.instance.mAccount_gRPC else { return }
//        if (chain == .DESMOS_MAIN && rawAccount.typeURL.contains(Desmos_Profiles_V1beta1_Profile.protoMessageName)) {
//            if let profileAccount = try? Desmos_Profiles_V1beta1_Profile.init(serializedData: rawAccount.value) {
//                onParseVestingAccount(chain, profileAccount.account)
//            } else {
//                onParseVestingAccount(chain, rawAccount)
//            }
//
//        } else if (chain == .INJECTIVE_MAIN && rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)) {
////            print("rawAccount.typeURL ", rawAccount.typeURL)
////            if let ethAccount = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
////                onParseVestingAccount(chain, ethAccount.baseAccount)
////            } else {
////                onParseVestingAccount(chain, rawAccount)
////            }
//            onParseVestingAccount(chain, rawAccount)
//
//        } else if (chain == .EVMOS_MAIN && rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)) {
//            onParseVestingAccount(chain, rawAccount)
//        } else {
//            onParseVestingAccount(chain, rawAccount)
//        }
//
//        //Update local BD for save availabe(balance)to snap (ex kava bep3 swap check)
//        var snapBalance = Array<Balance>()
//        for balance_grpc in BaseData.instance.mMyBalances_gRPC {
//            snapBalance.append(Balance(accountId, balance_grpc.denom, balance_grpc.amount, Date().millisecondsSince1970))
//        }
//        BaseData.instance.updateBalances(accountId, snapBalance)
//    }
//
    static func onParseAvailableCoins(_ auth: Google_Protobuf_Any?, _ inCoin: [Cosmos_Base_V1beta1_Coin]?) -> [Cosmos_Base_V1beta1_Coin] {
        var result = Array<Cosmos_Base_V1beta1_Coin>()
        guard let authInfo = auth, let checkCoins = inCoin else {
            return result
        }
        if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
           let vestingAccount = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: authInfo.value) {
            checkCoins.forEach { checkCoin in
                var dpBalance = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: checkCoin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == checkCoin.denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == checkCoin.denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                remainVesting = onParsePeriodicRemainVestingsAmountByDenom(vestingAccount, checkCoin.denom)
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = checkCoin.denom; $0.amount = dpBalance.stringValue })
            }
            
        } else if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                  let vestingAccount = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: authInfo.value) {
            checkCoins.forEach { checkCoin in
                var dpBalance = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: checkCoin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == checkCoin.denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == checkCoin.denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingStart = vestingAccount.startTime * 1000
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingStart) {
                    remainVesting = originalVesting
                } else if (cTime > vestingEnd) {
                    remainVesting = NSDecimalNumber.zero
                } else {
                    let progress = ((Float)(cTime - vestingStart)) / ((Float)(vestingEnd - vestingStart))
                    remainVesting = originalVesting.multiplying(by: NSDecimalNumber.init(value: 1 - progress), withBehavior: handler0Up)
                }
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting)
                }
                result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = checkCoin.denom; $0.amount = dpBalance.stringValue })
            }
            
            
        } else if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                  let vestingAccount = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: authInfo.value) {
            checkCoins.forEach { checkCoin in
                var dpBalance = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: checkCoin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == checkCoin.denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingEnd) {
                    remainVesting = originalVesting
                }
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == checkCoin.denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = checkCoin.denom; $0.amount = dpBalance.stringValue })
            }
            
        } else {
            result = checkCoins
        }
        return result
    }
    
    static func onParseVestingAccount(_ baseChain: CosmosClass) {
        guard let authInfo = baseChain.cosmosAuth else {
            return
        }
        
        if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
           let vestingAccount = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: authInfo.value) {

            baseChain.cosmosBalances?.forEach({ coin in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero

                dpBalance = NSDecimalNumber.init(string: coin.amount)

                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                remainVesting = onParsePeriodicRemainVestingsAmountByDenom(vestingAccount, denom)

                dpVesting = remainVesting.subtracting(delegatedVesting)

                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting

                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    baseChain.cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(baseChain.cosmosBalances?.count ?? 0) {
                        if (baseChain.cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        baseChain.cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })

        } else if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                    let vestingAccount = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: authInfo.value) {

            baseChain.cosmosBalances?.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingStart = vestingAccount.startTime * 1000
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
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
                    baseChain.cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(baseChain.cosmosBalances?.count ?? 0) {
                        if (baseChain.cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        baseChain.cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })

        } else if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                    let vestingAccount = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: authInfo.value) {

            baseChain.cosmosBalances?.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingEnd) {
                    remainVesting = originalVesting
                }
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                dpVesting = remainVesting.subtracting(delegatedVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    baseChain.cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(baseChain.cosmosBalances?.count ?? 0) {
                        if (baseChain.cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        baseChain.cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })

        } else if (authInfo.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName)),
                  let vestingAccount = try? Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: authInfo.value) {
            
            baseChain.cosmosBalances?.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                var delegatedFree = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                vestingAccount.baseVestingAccount.delegatedFree.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedFree = delegatedFree.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                remainVesting = WUtils.onParseStridePeriodicRemainVestingsAmountByDenom(vestingAccount, denom)
                dpVesting = remainVesting.subtracting(delegatedVesting).subtracting(delegatedFree);
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting.adding(delegatedFree)).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    baseChain.cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(baseChain.cosmosBalances?.count ?? 0) {
                        if (baseChain.cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        baseChain.cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })
        }
    }
    static func onParsePeriodicUnLockTime(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ position: Int) -> Int64 {
        var result = vestingAccount.startTime
        for i in 0..<(position + 1) {
            result = result + vestingAccount.vestingPeriods[i].length
        }
        return result * 1000
    }

    static func onParsePeriodicRemainVestings(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        let cTime = Date().millisecondsSince1970
        for i in 0..<vestingAccount.vestingPeriods.count {
            let unlockTime = onParsePeriodicUnLockTime(vestingAccount, i)
            if (cTime < unlockTime) {
                let temp = Cosmos_Vesting_V1beta1_Period.with {
                    $0.length = unlockTime
                    $0.amount = vestingAccount.vestingPeriods[i].amount
                }
                results.append(temp)
            }
        }
        return results
    }

    static func onParsePeriodicRemainVestingsByDenom(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        for vp in onParsePeriodicRemainVestings(vestingAccount) {
            for coin in vp.amount {
                if (coin.denom ==  denom) {
                    results.append(vp)
                }
            }
        }
        return results
    }
//
//    static func onParseAllPeriodicRemainVestingsCnt(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount) -> Int {
//        return onParsePeriodicRemainVestings(vestingAccount).count
//    }
//
//    static func onParsePeriodicRemainVestingsCntByDenom(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String) -> Int {
//        return onParsePeriodicRemainVestingsByDenom(vestingAccount, denom).count
//    }
//
//    static func onParsePeriodicRemainVestingTime(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String, _ position: Int) -> Int64 {
//        return onParsePeriodicRemainVestingsByDenom(vestingAccount, denom)[position].length
//    }
//
    static func onParsePeriodicRemainVestingsAmountByDenom(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String) -> NSDecimalNumber {
        var results = NSDecimalNumber.zero
        let periods = onParsePeriodicRemainVestingsByDenom(vestingAccount, denom)
        for vp in periods {
            for coin in vp.amount {
                if (coin.denom ==  denom) {
                    results = results.adding(NSDecimalNumber.init(string: coin.amount))
                }
            }
        }
        return results
    }
//
//    static func onParsePeriodicRemainVestingAmount(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String, _ position: Int) -> NSDecimalNumber {
//        let periods = onParsePeriodicRemainVestingsByDenom(vestingAccount, denom)
//        if position < periods.count {
//            let coin = periods[position].amount.filter { $0.denom == denom }.first
//            return NSDecimalNumber.init(string: coin?.amount)
//        }
//        return NSDecimalNumber.zero
//    }
//
    static func onParseStridePeriodicRemainVestingsByDenom(_ vestingAccount: Stride_Vesting_StridePeriodicVestingAccount, _ denom: String) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        let cTime = Date().millisecondsSince1970
        vestingAccount.vestingPeriods.forEach { (period) in
            let vestingEnd = (period.startTime + period.length) * 1000
            if cTime < vestingEnd {
                period.amount.forEach { (vesting) in
                    if (vesting.denom == denom) {
                        let temp = Cosmos_Vesting_V1beta1_Period.with {
                            $0.length = vestingEnd
                            $0.amount = period.amount
                        }
                        results.append(temp)
                    }
                }
            }
        }
        return results
    }

    static func onParseStridePeriodicRemainVestingsAmountByDenom(_ vestingAccount: Stride_Vesting_StridePeriodicVestingAccount, _ denom: String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        let vpList = onParseStridePeriodicRemainVestingsByDenom(vestingAccount, denom)
        vpList.forEach { (vp) in
            vp.amount.forEach { (coin) in
                if (coin.denom == denom) {
                    result = result.adding(NSDecimalNumber.init(string: coin.amount))
                }
            }
        }
        return result
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var StringmillisecondsSince1970:String {
        return String((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var Stringmilli3MonthAgo:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0) - TimeInterval(7776000000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension String {
    func hexToNSDecimal() -> NSDecimalNumber{
        if (self.isEmpty) { return NSDecimalNumber.zero }
        return NSDecimalNumber(string: String(BigUInt(self.stripHexPrefix(), radix: 16) ?? "0"))
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func hexToString() -> String{
        var finalString = ""
        let chars = Array(self)
        
        for count in stride(from: 0, to: chars.count - 1, by: 2){
            let firstDigit =  Int.init("\(chars[count])", radix: 16) ?? 0
            let lastDigit = Int.init("\(chars[count + 1])", radix: 16) ?? 0
            let decimal = firstDigit * 16 + lastDigit
            let decimalString = String(format: "%c", decimal) as String
            finalString.append(Character.init(decimalString))
        }
        return finalString
    }
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else { return nil }
        return data
    }
    
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = "#".endIndex
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
