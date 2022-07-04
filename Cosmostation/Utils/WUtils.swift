//
//  WUtils.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import UIKit

public class WUtils {
    
    static let handler18 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 18, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler12 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 12, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler8 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 8, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler6 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 6, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler4Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 4, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler2 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler2Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler3Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 3, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler0 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler0Up = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler0Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let handler12Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 12, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

    static let handler24Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 24, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static func getDivideHandler(_ decimal:Int16) -> NSDecimalNumberHandler{
        return NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: decimal, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    }
    
    static func getAccountWithBnbAccountInfo(_ account: Account, _ accountInfo: BnbAccountInfo) -> Account {
        let result = account
        result.account_address = accountInfo.address
        result.account_sequence_number = Int64(accountInfo.sequence)
        result.account_account_numner = Int64(accountInfo.account_number)
        return result
    }
    
    static func getBalancesWithBnbAccountInfo(_ account: Account, _ accountInfo: BnbAccountInfo) -> Array<Balance> {
        var result = Array<Balance>()
        for bnbBalance in accountInfo.balances {
            result.append(Balance(account.account_id, bnbBalance.symbol, bnbBalance.free, Date().millisecondsSince1970, bnbBalance.frozen, bnbBalance.locked))
        }
        return result;
    }
    
    static func getAccountWithOkAccountInfo(_ account: Account, _ accountInfo: OkAccountInfo) -> Account {
        let result = account
        if (accountInfo.type == COSMOS_AUTH_TYPE_OKEX_ACCOUNT) {
            result.account_address = accountInfo.value!.eth_address!
            result.account_sequence_number = Int64(accountInfo.value!.sequence!)!
            result.account_account_numner = Int64(accountInfo.value!.account_number!)!
        }
        return result
    }
    
    static func getBalancesWithOkAccountInfo(_ account: Account, _ accountToken: OkAccountToken) -> Array<Balance> {
        var result = Array<Balance>()
        for okBalance in accountToken.data.currencies {
             result.append(Balance(account.account_id, okBalance.symbol, okBalance.available, Date().millisecondsSince1970, "0", okBalance.locked))
        }
        return result;
    }
    
    static func newApiTimeToInt64(_ input: String?) -> Date? {
        if (input == nil) { return nil }
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return nodeFormatter.date(from: input!)
    }
    
    static func newApiTimeToString(_ input: String?) -> String {
        if (input == nil) { return "" }
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        
        guard let fullDate = nodeFormatter.date(from: input!) else {
            return ""
        }
        return localFormatter.string(from: fullDate)
        
    }
    
    static func newApiTimeGap(_ input: String?) -> String {
        if (input == nil || newApiTimeToInt64(input!) == nil) { return "-" }
        let secondsAgo = Int(Date().timeIntervalSince(newApiTimeToInt64(input!)!))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        if secondsAgo < minute {
            return "(\(secondsAgo) seconds ago)"
        } else if secondsAgo < hour {
            return "(\(secondsAgo / minute) minutes ago)"
        } else if secondsAgo < day {
            return "(\(secondsAgo / hour) hours ago)"
        } else {
            return "(\(secondsAgo / day) days ago)"
        }
    }
    
    
    static func sifNodeTimeToString(_ input: String?) -> String {
        if (input == nil) { return ""}
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        
        guard let fullDate = nodeFormatter.date(from: input!) else { return "" }
        return localFormatter.string(from: fullDate)
    }
    
    static func nodeTimeToInt64(input: String) -> Date {
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return nodeFormatter.date(from: input) ?? Date.init()
    }
    
    static func nodeTimetoString(input: String?) -> String {
        if (input == nil) { return ""}
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        
        if (input != nil) {
            let fullDate = nodeFormatter.date(from: input!)
            return localFormatter.string(from: fullDate!)
        } else {
            return ""
        }
    }
    
    static func txTimeToInt64(input: String) -> Date {
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return nodeFormatter.date(from: input) ?? Date.init()
    }
    
    static func txTimetoString(input: String?) -> String {
        if (input == nil || input!.count == 0) {
            return "??"
        }
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        if (input != nil) {
            let fullDate = nodeFormatter.date(from: input!)
            return localFormatter.string(from: fullDate!)
        } else {
            return ""
        }
    }
    
    
    static func longTimetoString(_ input: Int64) -> String {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        
        let fullDate = Date.init(milliseconds: Int(input))
        return localFormatter.string(from: fullDate)
    }
    
    static func longTimetoString3(_ input: Int64) -> String {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format3", comment: "")
        
        let fullDate = Date.init(milliseconds: Int(input))
        return localFormatter.string(from: fullDate)
    }
    
    static func nodeTimetoString3(_ input: String) -> String {
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = nodeFormatter.date(from: input) ?? Date.init()
        return longTimetoString3(date.millisecondsSince1970)
    }
    
    static func unbondingDateFromNow(_ date:UInt16) -> String {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        
        let afterDate = Calendar.current.date(
            byAdding: .day,
            value: Int(+date),
            to: Date())
        return localFormatter.string(from: afterDate!)
    }
    
    static func getUnbondingTimeleft(_ input: Int64) -> String {
        let secondsLeft = Int(Date().timeIntervalSince(Date.init(milliseconds: Int(input)))) * -1
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        if secondsLeft < minute {
            return "Soon"
        } else if secondsLeft < hour {
            return "(\(secondsLeft / minute) minutes remaining)"
        } else if secondsLeft < day {
            return "(\(secondsLeft / hour) hours remaining)"
        } else {
            return "(\(secondsLeft / day) days remaining)"
        }
    }
    
    static func getUnbondingTimeleft2(_ input: String) -> String {
        let nodeFormatter = DateFormatter()
        nodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        nodeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = nodeFormatter.date(from: input) ?? Date.init()
        
        let secondsLeft = Int(Date().timeIntervalSince(date)) * -1
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        if secondsLeft < minute {
            return "Soon"
        } else if secondsLeft < hour {
            return "(\(secondsLeft / minute) minutes remaining)"
        } else if secondsLeft < day {
            return "(\(secondsLeft / hour) hours remaining)"
        } else {
            return "(\(secondsLeft / day) days remaining)"
        }
    }
    
    static func timeGap(input: String?) -> String {
        if (input == nil) { return "-"}
        let secondsAgo = Int(Date().timeIntervalSince(nodeTimeToInt64(input: input!)))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        if secondsAgo < minute {
            return "(\(secondsAgo) seconds ago)"
        } else if secondsAgo < hour {
            return "(\(secondsAgo / minute) minutes ago)"
        } else if secondsAgo < day {
            return "(\(secondsAgo / hour) hours ago)"
        } else {
            return "(\(secondsAgo / day) days ago)"
        }
    }
    
    static func timeGap2(input: Int64) -> String {
        if (input == nil) { return "-"}
        let secondsAgo = (Int(Date().millisecondsSince1970 - input) / 1000)
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        if secondsAgo < minute {
            return "(\(secondsAgo) seconds ago)"
        } else if secondsAgo < hour {
            return "(\(secondsAgo / minute) minutes ago)"
        } else if secondsAgo < day {
            return "(\(secondsAgo / hour) hours ago)"
        } else {
            return "(\(secondsAgo / day) days ago)"
        }
    }
    
    static func txTimeGap(input: String?) -> String {
        if (input == nil || input!.count == 0) { return "??" }
        let secondsAgo = Int(Date().timeIntervalSince(txTimeToInt64(input: input!)))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        if secondsAgo < minute {
            return "(\(secondsAgo) seconds ago)"
        } else if secondsAgo < hour {
            return "(\(secondsAgo / minute) minutes ago)"
        } else if secondsAgo < day {
            return "(\(secondsAgo / hour) hours ago)"
        } else {
            return "(\(secondsAgo / day) days ago)"
        }
    }
    
    static func checkNAN(_ check: NSDecimalNumber) -> NSDecimalNumber{
        if(check.isEqual(to: NSDecimalNumber.notANumber)) {
            return NSDecimalNumber.zero
        }
        return check
    }
    
    static func decimalNumberToLocaleString(_ input: NSDecimalNumber, _ deciaml:Int16) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = Int(deciaml)
        nf.numberStyle = .decimal
        nf.locale = Locale.current
        nf.groupingSeparator = ""
        return nf.string(from: input)!
    }
    
    static func localeStringToDecimal(_ input: String?) -> NSDecimalNumber {
        let result = NSDecimalNumber(string: input, locale: Locale.current)
        if (NSDecimalNumber.notANumber == result) {
            return NSDecimalNumber.zero
        } else {
            return result
        }
    }
    
    static func plainStringToDecimal(_ input: String?) -> NSDecimalNumber {
        if (input == nil) { return NSDecimalNumber.zero }
        let result = NSDecimalNumber(string: input)
        if (NSDecimalNumber.notANumber == result) {
            return NSDecimalNumber.zero
        } else {
            return result
        }
    }
    
    static func displayAmount2(_ amount: String?, _ font:UIFont, _ inputPoint:Int16, _ dpPoint:Int16) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = Int(dpPoint)
        nf.maximumFractionDigits = Int(dpPoint)
//        nf.maximumSignificantDigits = Int(dpPoint) - 1
//        nf.minimumSignificantDigits = Int(dpPoint) - 1
        nf.roundingMode = .floor
        nf.numberStyle = .decimal
        
        let amount = plainStringToDecimal(amount)
        var formatted: String?
        if (amount == NSDecimalNumber.zero) {
            formatted = nf.string(from: NSDecimalNumber.zero)
        } else {
            let calAmount = amount.multiplying(byPowerOf10: -Int16(inputPoint))
            formatted = nf.string(from: calAmount)
        }
        
        let added       = formatted
        let endIndex    = added!.index(added!.endIndex, offsetBy: -dpPoint)
        
        let preString   = added![..<endIndex]
        let postString  = added![endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func getFormattedNumber(_ amount: NSDecimalNumber, _ dpPoint:Int16) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = Int(dpPoint)
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal
        
        let formatted = nf.string(from: amount)?.replacingOccurrences(of: ",", with: "" )
        return formatted!
    }
    
    //price displaying
    static func tokenCnt(_ chainType: ChainType?) -> String {
        if (isGRPC(chainType)) {
            return String(BaseData.instance.mMyBalances_gRPC.count)
        } else {
            return String(BaseData.instance.mBalances.count)
        }
    }
    
    static func valueChange(_ denom: String) -> NSDecimalNumber {
        let baseData = BaseData.instance
        guard let coinPrice = baseData.getPrice(denom) else {
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler2Down)
        }
        return coinPrice.priceChange()
    }
    
    static func dpValueChange(_ denom: String, font:UIFont ) -> NSMutableAttributedString {
        let nf = getNumberFormatter(2)
        let formatted = nf.string(from: valueChange(denom))! + "% (24h)"
        return getDpAttributedString(formatted, 9, font)
    }
    
    static func perUsdValue(_ denom: String) -> NSDecimalNumber? {
        if (denom.contains("gamm/pool/")) {
            if let pool = BaseData.instance.getOsmoPoolByDenom(denom) {
                return WUtils.getOsmoLpTokenPerUsdPrice(pool)
            }
        }
        if (denom == EMONEY_EUR_DENOM || denom == EMONEY_CHF_DENOM || denom == EMONEY_DKK_DENOM || denom == EMONEY_NOK_DENOM || denom == EMONEY_SEK_DENOM) {
            if let value = BaseData.instance.getPrice("usdt")?.prices.filter{ $0.currency == denom.substring(from: 1) }.first?.current_price {
                return NSDecimalNumber.one.dividing(by: NSDecimalNumber.init(value: value), withBehavior: handler18)
            }
        }
        if let coinPrice = BaseData.instance.getPrice(denom) {
            return coinPrice.currencyPrice("usd").rounding(accordingToBehavior: handler18)
        }
        return nil
    }
    
    static func usdValue(_ denom: String, _ amount: NSDecimalNumber, _ divider: Int16) -> NSDecimalNumber {
        if let perUsdValue = perUsdValue(denom) {
            return perUsdValue.multiplying(by: amount).multiplying(byPowerOf10: -divider, withBehavior: handler3Down)
        }
        return NSDecimalNumber.zero
    }
    
    static func perUserCurrencyValue(_ denom: String) -> NSDecimalNumber {
        let baseData = BaseData.instance
        guard let perUsdValue = perUsdValue(denom), let usdtPrice = baseData.getPrice("usdt") else {
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler3Down)
        }
        if (baseData.getCurrency() == 0) {
            return perUsdValue
        } else {
            let priceUSDT = usdtPrice.currencyPrice(baseData.getCurrencyString().lowercased())
            return perUsdValue.multiplying(by: priceUSDT, withBehavior: handler3Down)
        }
    }
    
    static func perBtcValue(_ denom: String) -> NSDecimalNumber {
        let baseData = BaseData.instance
        guard let perUsdValue = perUsdValue(denom), let usdtPrice = baseData.getPrice("usdt") else {
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler8)
        }
        let priceUSDT = usdtPrice.currencyPrice("btc")
        return perUsdValue.multiplying(by: priceUSDT, withBehavior: handler8)
    }
    
    
    static func dpPerUserCurrencyValue(_ denom: String, _ font:UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: perUserCurrencyValue(denom))!
        return getDpAttributedString(formatted, 3, font)
    }
    
    static func userCurrencyValue(_ denom: String, _ amount: NSDecimalNumber, _ divider: Int16) -> NSDecimalNumber {
        return perUserCurrencyValue(denom).multiplying(by: amount).multiplying(byPowerOf10: -divider, withBehavior: handler3Down)
    }
    
    static func dpUserCurrencyValue(_ denom: String, _ amount: NSDecimalNumber, _ divider: Int16, _ font:UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: userCurrencyValue(denom, amount, divider))!
        return getDpAttributedString(formatted, 3, font)
    }
    
    static func btcValue(_ denom: String, _ amount: NSDecimalNumber, _ divider: Int16) -> NSDecimalNumber {
        return perBtcValue(denom).multiplying(by: amount).multiplying(byPowerOf10: -divider, withBehavior: handler8)
    }
    
    static func allAssetToUserCurrency(_ chainType: ChainType?) -> NSDecimalNumber {
        let baseData = BaseData.instance
        var totalValue = NSDecimalNumber.zero
        if (isGRPC(chainType)) {
            baseData.mMyBalances_gRPC.forEach { coin in
                if (coin.denom == getMainDenom(chainType)) {
                    let amount = getAllMainAsset(coin.denom)
                    let assetValue = userCurrencyValue(coin.denom, amount, mainDivideDecimal(chainType))
                    totalValue = totalValue.adding(assetValue)
                    
                } else if (chainType == ChainType.OSMOSIS_MAIN && coin.denom == OSMOSIS_ION_DENOM) {
                    let amount = baseData.getAvailableAmount_gRPC(coin.denom)
                    let assetValue = userCurrencyValue(coin.denom, amount, 6)
                    totalValue = totalValue.adding(assetValue)
                    
                } else if (chainType! == ChainType.SIF_MAIN && coin.denom.starts(with: "c")) {
                    let available = baseData.getAvailableAmount_gRPC(coin.denom)
                    let decimal = getSifCoinDecimal(coin.denom)
                    if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(coin.denom) {
                        totalValue = totalValue.adding(userCurrencyValue(bridgeTokenInfo.origin_symbol!.lowercased(), available, decimal))
                    }
                    
                } else if (chainType! == ChainType.GRAVITY_BRIDGE_MAIN && coin.denom.starts(with: "gravity0x")) {
                    let available = baseData.getAvailableAmount_gRPC(coin.denom)
                    let decimal = getGBrdigeCoinDecimal(coin.denom)
                    if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(coin.denom) {
                        totalValue = totalValue.adding(userCurrencyValue(bridgeTokenInfo.origin_symbol!.lowercased(), available, decimal))
                    }
                    
                } else if (chainType! == ChainType.EMONEY_MAIN && coin.denom.starts(with: "e")) {
                    let available = baseData.getAvailableAmount_gRPC(coin.denom)
                    totalValue = totalValue.adding(userCurrencyValue(coin.denom, available, 6))
                    
                } else if (chainType == ChainType.OSMOSIS_MAIN && coin.denom.contains("gamm/pool/")) {
                    let amount = baseData.getAvailableAmount_gRPC(coin.denom)
                    let assetValue = userCurrencyValue(coin.denom, amount, 18)
                    totalValue = totalValue.adding(assetValue)
                    
                }  else if (chainType == ChainType.COSMOS_MAIN && coin.denom.starts(with: "pool") && coin.denom.count >= 68) {
                    let amount = baseData.getAvailableAmount_gRPC(coin.denom)
                    let assetValue = userCurrencyValue(coin.denom, amount, 6)
                    totalValue = totalValue.adding(assetValue)
                    
                } else if (chainType! == ChainType.KAVA_MAIN) {
                    let chainConfig = ChainKava.init(.KAVA_MAIN)
                    let baseDenom = BaseData.instance.getBaseDenom(chainConfig, coin.denom)
                    let decimal = WUtils.getKavaCoinDecimal(coin.denom)
                    let amount = WUtils.getKavaTokenAll(coin.denom)
                    let assetValue = userCurrencyValue(baseDenom, amount, decimal)
                    totalValue = totalValue.adding(assetValue)
                    
                } else if (chainType! == ChainType.INJECTIVE_MAIN && coin.denom.starts(with: "peggy0x")) {
                    let available = baseData.getAvailableAmount_gRPC(coin.denom)
                    let decimal = getInjectiveCoinDecimal(coin.denom)
                    if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(coin.denom) {
                        totalValue = totalValue.adding(userCurrencyValue(bridgeTokenInfo.origin_symbol!.lowercased(), available, decimal))
                    }
                    
                } else if (chainType! == ChainType.NYX_MAIN && coin.denom == NYX_NYM_DENOM) {
                    let amount = baseData.getAvailableAmount_gRPC(coin.denom)
                    let assetValue = userCurrencyValue(coin.denom, amount, 6)
                    totalValue = totalValue.adding(assetValue)
                    
                }
                
                else if (coin.isIbc()) {
                    if let ibcToken = BaseData.instance.getIbcToken(coin.getIbcHash()) {
                        if (ibcToken.auth == true) {
                            let amount = baseData.getAvailableAmount_gRPC(coin.denom)
                            let assetValue = userCurrencyValue(ibcToken.base_denom!, amount, ibcToken.decimal!)
                            totalValue = totalValue.adding(assetValue)
                        }
                    }
                }
            }
            
            baseData.getCw20s_gRPC().forEach { cw20Token in
                let available = cw20Token.getAmount()
                let decimal = cw20Token.decimal
                totalValue = totalValue.adding(userCurrencyValue(cw20Token.denom, available, decimal))
            }
        }
        else if (chainType! == ChainType.BINANCE_MAIN) {
            baseData.mBalances.forEach { coin in
                var allBnb = NSDecimalNumber.zero
                let amount = WUtils.getAllBnbToken(coin.balance_denom)
                if (coin.balance_denom == getMainDenom(chainType)) {
                    allBnb = allBnb.adding(amount)
                } else {
                    allBnb = allBnb.adding(getBnbConvertAmount(coin.balance_denom))
                }
                let assetValue = userCurrencyValue(getMainDenom(chainType), allBnb, 0)
                totalValue = totalValue.adding(assetValue)
            }
            
        } else if (chainType! == ChainType.OKEX_MAIN) {
            baseData.mBalances.forEach { coin in
                var allOKT = NSDecimalNumber.zero
                if (coin.balance_denom == getMainDenom(chainType)) {
                    allOKT = allOKT.adding(getAllExToken(coin.balance_denom))
                } else {
                    allOKT = allOKT.adding(convertTokenToOkt(coin.balance_denom))
                }
                let assetValue = userCurrencyValue(getMainDenom(chainType), allOKT, 0)
                totalValue = totalValue.adding(assetValue)
            }
            
        }
        return totalValue
    }
    
    static func dpAllAssetValueUserCurrency(_ chainType: ChainType?, _ font:UIFont) -> NSMutableAttributedString {
        let totalValue = allAssetToUserCurrency(chainType)
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: totalValue)!
        return getDpAttributedString(formatted, 3, font)
    }
    
    static func getNumberFormatter(_ divider: Int) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = divider
        nf.maximumFractionDigits = divider
        return nf
    }
    
    static func getDpAttributedString(_ dpString: String, _ divider: Int, _ font:UIFont)  -> NSMutableAttributedString {
        let endIndex    = dpString.index(dpString.endIndex, offsetBy: -divider)
        let preString   = dpString[..<endIndex]
        let postString  = dpString[endIndex...]
        let preAttrs    = [NSAttributedString.Key.font : font]
        let postAttrs   = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    
    static func displayGasRate(_ rate: NSDecimalNumber, font:UIFont, _ deciaml:Int) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = deciaml
        nf.maximumFractionDigits = deciaml
        nf.numberStyle = .decimal
        
        let formatted   = nf.string(from: rate)!
        let endIndex    = formatted.index(formatted.endIndex, offsetBy: -(deciaml))
        
        let preString   = formatted[..<endIndex]
        let postString  = formatted[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func displayGasRate2(_ rate: NSDecimalNumber, font:UIFont) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        let deciaml = rate.stringValue.count - 2
        nf.minimumFractionDigits = deciaml
        nf.maximumFractionDigits = deciaml
        nf.numberStyle = .decimal
        
        let formatted   = nf.string(from: rate)!
        let endIndex    = formatted.index(formatted.endIndex, offsetBy: -(deciaml))
        
        let preString   = formatted[..<endIndex]
        let postString  = formatted[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func displayPriceUPdown(_ updown:NSDecimalNumber, font:UIFont ) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.numberStyle = .decimal
        
        let formatted   = nf.string(from: updown.rounding(accordingToBehavior: handler2))! + "% (24h)"
        let endIndex    = formatted.index(formatted.endIndex, offsetBy: -9)
        
        let preString   = formatted[..<endIndex]
        let postString  = formatted[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func displayPercent(_ rate:NSDecimalNumber, _ font:UIFont ) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.numberStyle = .decimal
        
        let formatted   = nf.string(from: rate.rounding(accordingToBehavior: handler2Down))! + "%"
        let endIndex    = formatted.index(formatted.endIndex, offsetBy: -3)
        
        let preString   = formatted[..<endIndex]
        let postString  = formatted[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func getDpEstAprCommission(_ font: UIFont, _ commission: NSDecimalNumber, _ chain: ChainType) -> NSMutableAttributedString {
        guard let param = BaseData.instance.mParam else {
            return displayPercent(NSDecimalNumber.zero, font)
        }
        let apr = param.getApr(chain)
        let calCommission = NSDecimalNumber.one.subtracting(commission)
        let aprCommission = apr.multiplying(by: calCommission, withBehavior: handler6).multiplying(byPowerOf10: 2)
        return displayPercent(aprCommission, font)
    }
    
    static func getDailyReward(_ font: UIFont, _ commission: NSDecimalNumber, _ delegated: NSDecimalNumber?, _ chain: ChainType) -> NSMutableAttributedString {
        guard let param = BaseData.instance.mParam, let bondingAmount = delegated else {
            return displayAmount2(NSDecimalNumber.zero.stringValue, font, mainDivideDecimal(chain), mainDivideDecimal(chain))
        }
        var apr = NSDecimalNumber.zero
        if (param.getRealApr(chain) == NSDecimalNumber.zero) { apr = param.getApr(chain) }
        else { apr = param.getRealApr(chain) }
        let calCommission = NSDecimalNumber.one.subtracting(commission)
        let aprCommission = apr.multiplying(by: calCommission, withBehavior: handler6)
        let dayReward = bondingAmount.multiplying(by: aprCommission).dividing(by: NSDecimalNumber.init(string: "365"), withBehavior: WUtils.handler0)
        return displayAmount2(dayReward.stringValue, font, mainDivideDecimal(chain), mainDivideDecimal(chain))
    }
    
    static func getMonthlyReward(_ font: UIFont, _ commission: NSDecimalNumber, _ delegated: NSDecimalNumber?, _ chain: ChainType) -> NSMutableAttributedString {
        guard let param = BaseData.instance.mParam, let bondingAmount = delegated else {
            return displayAmount2(NSDecimalNumber.zero.stringValue, font, mainDivideDecimal(chain), mainDivideDecimal(chain))
        }
        var apr = NSDecimalNumber.zero
        if (param.getRealApr(chain) == NSDecimalNumber.zero) { apr = param.getApr(chain) }
        else { apr = param.getRealApr(chain) }
        let calCommission = NSDecimalNumber.one.subtracting(commission)
        let aprCommission = apr.multiplying(by: calCommission, withBehavior: handler6)
        let dayReward = bondingAmount.multiplying(by: aprCommission).dividing(by: NSDecimalNumber.init(string: "12"), withBehavior: WUtils.handler0)
        return displayAmount2(dayReward.stringValue, font, mainDivideDecimal(chain), mainDivideDecimal(chain))
    }
    
    static func displayCommission(_ rate:String?, font:UIFont ) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.numberStyle = .decimal
        
        let formatted   = nf.string(from: plainStringToDecimal(rate).multiplying(by: 100))! + "%"
        let endIndex    = formatted.index(formatted.endIndex, offsetBy: -3)
        
        let preString   = formatted[..<endIndex]
        let postString  = formatted[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func displaySelfBondRate(_ selfShare: String?, _ totalShare: String?, _ font:UIFont ) ->  NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.numberStyle = .decimal
        
        let selfDecimal = plainStringToDecimal(selfShare)
        let totalDecimal = plainStringToDecimal(totalShare)
        
        var formatted = "0.00%"
        if (selfDecimal != NSDecimalNumber.zero && totalDecimal != NSDecimalNumber.zero) {
            formatted   = nf.string(from: selfDecimal.multiplying(by: 100).dividing(by: totalDecimal, withBehavior: handler2Down))! + "%"
        }
        let endIndex    = formatted.index(formatted.endIndex, offsetBy: -3)
        
        let preString   = formatted[..<endIndex]
        let postString  = formatted[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func getAllMainAsset(_ denom: String) -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        let data = BaseData.instance
        for balance in data.mMyBalances_gRPC {
            if (balance.denom == denom) {
                amount = amount.adding(plainStringToDecimal(balance.amount))
            }
        }
        for balance in data.mMyVestings_gRPC {
            if (balance.denom == denom) {
                amount = amount.adding(plainStringToDecimal(balance.amount))
            }
        }
        for delegation in data.mMyDelegations_gRPC {
            amount = amount.adding(plainStringToDecimal(delegation.balance.amount))
        }
        for unbonding in data.mMyUnbondings_gRPC {
            for entry in unbonding.entries {
                amount = amount.adding(plainStringToDecimal(entry.balance))
            }
        }
        for reward in data.mMyReward_gRPC {
            for coin in reward.reward {
                if (coin.denom == denom) {
                    amount = amount.adding(plainStringToDecimal(coin.amount).multiplying(byPowerOf10: -18))
                }
            }
        }
        return amount
    }
    
    static func getAllExToken(_ symbol: String) -> NSDecimalNumber {
        let dataBase = BaseData.instance
        if (symbol == OKEX_MAIN_DENOM) {
            return dataBase.availableAmount(symbol).adding(dataBase.lockedAmount(symbol)).adding(dataBase.okDepositAmount()).adding(dataBase.okWithdrawAmount())
        } else {
            return dataBase.availableAmount(symbol).adding(dataBase.lockedAmount(symbol))
        }
    }
    
    static func getAllBnbToken(_ symbol: String) -> NSDecimalNumber {
        let dataBase = BaseData.instance
        return dataBase.availableAmount(symbol).adding(dataBase.frozenAmount(symbol)).adding(dataBase.lockedAmount(symbol))
    }
    
    static func getOkexTokenDollorValue(_ okToken: OkToken?, _ amount: NSDecimalNumber) -> NSDecimalNumber {
        if (okToken == nil) { return NSDecimalNumber.zero }
        if (okToken!.original_symbol == "usdt" || okToken!.original_symbol == "usdc" || okToken!.original_symbol == "usdk") {
            return amount
            
        } else if (okToken!.original_symbol == "okb" && BaseData.instance.mOKBPrice != nil) {
            return amount.multiplying(by: BaseData.instance.mOKBPrice)
            
        } else if (BaseData.instance.mOkTickerList != nil) {
            //TODO display with ticker update!
            let okTickers = BaseData.instance.mOkTickerList?.data
            return NSDecimalNumber.zero
        }
        return NSDecimalNumber.zero
    }
    
    static func convertTokenToOkt(_ denom: String) -> NSDecimalNumber {
        let baseData = BaseData.instance
        let okToken = getOkToken(denom)
        let tokenAmount = baseData.availableAmount(denom).adding(baseData.lockedAmount(denom))
        let totalTokenValue = getOkexTokenDollorValue(okToken, tokenAmount)
        if let okTUsd = perUsdValue(OKEX_MAIN_DENOM) {
            return totalTokenValue.dividing(by: okTUsd, withBehavior: handler18)
        }
        return NSDecimalNumber.zero
    }
    
    static func getBnbToken(_ symbol: String?) -> BnbToken? {
        return BaseData.instance.mBnbTokenList.filter{ $0.symbol == symbol }.first
    }
    
    static func getBnbTokenTic(_ symbol: String?) -> BnbTicker? {
        return BaseData.instance.mBnbTokenTicker.filter { $0.symbol == getBnbTicSymbol(symbol!)}.first
    }
    
    static func getBnbConvertAmount(_ symbol: String) -> NSDecimalNumber {
        if let ticker = getBnbTokenTic(symbol) {
            let amount = getAllBnbToken(symbol)
            if (isBnbMarketToken(symbol)) {
                return amount.dividing(by: ticker.getLastPrice(), withBehavior: WUtils.handler8)
            } else {
                return amount.multiplying(by: ticker.getLastPrice(), withBehavior: WUtils.handler8)
            }
        }
        return NSDecimalNumber.zero
    }
    
    static func getBnbTokenUserCurrencyPrice(_ symbol: String) -> NSDecimalNumber {
        if let bnbTicker = getBnbTokenTic(symbol) {
            if (isBnbMarketToken(symbol)) {
                let perPrice = (NSDecimalNumber.one).dividing(by: bnbTicker.getLastPrice(), withBehavior: WUtils.handler8)
                return perPrice.multiplying(by: perUserCurrencyValue(BNB_MAIN_DENOM))
            } else {
                let perPrice = (NSDecimalNumber.one).multiplying(by: bnbTicker.getLastPrice(), withBehavior: WUtils.handler8)
                return perPrice.multiplying(by: perUserCurrencyValue(BNB_MAIN_DENOM))
            }
        }
        return NSDecimalNumber.zero
    }
    
    static func dpBnbTokenUserCurrencyPrice(_ symbol: String, _ font:UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: getBnbTokenUserCurrencyPrice(symbol))!
        return getDpAttributedString(formatted, 3, font)
    }
    
    
    
    static func getBnbMainToken(_ bnbTokens:Array<BnbToken>) -> BnbToken? {
        for bnbToken in bnbTokens {
            if (bnbToken.symbol == BNB_MAIN_DENOM) {
                return bnbToken
            }
        }
        return nil
    }
    
    static func getOkToken(_ symbol:String?) -> OkToken? {
        return BaseData.instance.mOkTokenList?.data?.filter { $0.symbol == symbol}.first
    }
    
    static func getTokenAmount(_ balances:Array<Balance>?, _ symbol:String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        if (balances != nil) {
            balances!.forEach({ (balance) in
                if (balance.balance_denom.caseInsensitiveCompare(symbol) == .orderedSame) {
                    result = result.adding(WUtils.plainStringToDecimal(balance.balance_amount))
                }
            })
        }
        return result
    }
    
    static func getDelegableAmount(_ balances:Array<Balance>?, _ symbol:String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        if (balances != nil) {
            balances!.forEach({ (balance) in
                if (balance.balance_denom.caseInsensitiveCompare(symbol) == .orderedSame) {
                    result = result.adding(WUtils.plainStringToDecimal(balance.balance_amount))
                    result = result.adding(WUtils.plainStringToDecimal(balance.balance_locked))
                }
            })
        }
        return result
    }
    
    static func showBNBTxDp(_ coin:Coin, _ denomLabel:UILabel, _ amountLabel:UILabel, _ chainType:ChainType) {
        if (coin.denom == BNB_MAIN_DENOM) {
            WUtils.setDenomTitle(chainType, denomLabel)
        } else {
            denomLabel.textColor = UIColor(named: "_font05")
            denomLabel.text = coin.denom.uppercased()
        }
        amountLabel.attributedText = displayAmount2(coin.amount, amountLabel.font, 8, 8)
    }
    
    static func showCoinDp(_ coin: Coin, _ denomLabel: UILabel?, _ amountLabel: UILabel, _ chainType: ChainType) {
        return showCoinDp(coin.denom, coin.amount, denomLabel, amountLabel, chainType)
    }
    
    static func showCoinDp(_ denom:String, _ amount:String, _ denomLabel:UILabel?, _ amountLabel:UILabel, _ chainType:ChainType) {
        if (isGRPC(chainType) && denom.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom.replacingOccurrences(of: "ibc/", with: "")) {
                if (ibcToken.auth == true) {
                    denomLabel?.textColor = UIColor(named: "_font05")
                    denomLabel?.text = ibcToken.display_denom?.uppercased()
                    amountLabel.attributedText = displayAmount2(amount, amountLabel.font, ibcToken.decimal!, ibcToken.decimal!)
                    return
                    
                } else {
                    denomLabel?.textColor = UIColor(named: "_font05")
                    denomLabel?.text = "Unknown"
                    amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
                    return
                }
                
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = "Unknown"
                amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
                return
            }
            
        } else if (chainType == ChainType.COSMOS_MAIN || chainType == ChainType.COSMOS_TEST) {
            if (denom == COSMOS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)

        } else if (chainType == ChainType.IRIS_MAIN) {
            if (denom == IRIS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.BINANCE_MAIN) {
            if (denom == BNB_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 0, 8)
            
        } else if (chainType == ChainType.KAVA_MAIN) {
            if (denom == KAVA_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else if (denom == KAVA_HARD_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "kava_hard")
                denomLabel?.text = denom.uppercased()
            } else if (denom == KAVA_USDX_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "kava_usdx")
                denomLabel?.text = denom.uppercased()
            } else if (denom == KAVA_SWAP_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "kava_swp")
                denomLabel?.text = denom.uppercased()
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, getKavaCoinDecimal(denom), getKavaCoinDecimal(denom))
            
        } else if (chainType == ChainType.BAND_MAIN) {
            if (denom == BAND_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.SECRET_MAIN) {
            if (denom == SECRET_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.IOV_MAIN) {
            if (denom == IOV_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.CERTIK_MAIN) {
            if (denom == CERTIK_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            if (denom == OKEX_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 0, 18)
            
        } else if (chainType == ChainType.AKASH_MAIN) {
            if (denom == AKASH_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.PERSIS_MAIN) {
            if (denom == PERSIS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.SENTINEL_MAIN) {
            if (denom == SENTINEL_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.FETCH_MAIN) {
            if (denom == FETCH_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 18, 18)
            
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            if (denom == CRYPTO_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 8, 8)
            
        } else if (chainType == ChainType.SIF_MAIN) {
            let dpDecimal = WUtils.getSifCoinDecimal(denom)
            if (denom == SIF_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else if (denom.starts(with: "c")) {
                denomLabel?.textColor = UIColor(named: "_font05")
                if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom) {
                    denomLabel?.text = bridgeTokenInfo.origin_symbol
                } else {
                    denomLabel?.text = denom.substring(from: 1).uppercased()
                }
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, dpDecimal, dpDecimal)
            
        } else if (chainType == ChainType.KI_MAIN) {
            if (denom == KI_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.OSMOSIS_MAIN) {
            if (denom == OSMOSIS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
                amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            } else if (denom == OSMOSIS_ION_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "osmosis_ion")
                denomLabel?.text = "ION"
                amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            } else if (denom.starts(with: "gamm/pool/")) {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = "GAMM-" + String(denom.split(separator: "/").last!)
                amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 18, 18)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
                amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            }
            
        } else if (chainType == ChainType.IRIS_TEST) {
            if (denom == IRIS_TEST_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.RIZON_MAIN) {
            if (denom == RIZON_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.MEDI_MAIN) {
            if (denom == MEDI_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.ALTHEA_MAIN || chainType == ChainType.ALTHEA_TEST) {
            if (denom == ALTHEA_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.UMEE_MAIN) {
            if (denom == UMEE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.AXELAR_MAIN) {
            if (denom == AXELAR_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.EMONEY_MAIN) {
            if (denom == EMONEY_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else if (denom.starts(with: "e")) {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.substring(from: 1).uppercased()
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.JUNO_MAIN) {
            if (denom == JUNO_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.REGEN_MAIN) {
            if (denom == REGNE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.BITCANA_MAIN) {
            if (denom == BITCANA_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.GRAVITY_BRIDGE_MAIN) {
            let dpDecimal = WUtils.getGBrdigeCoinDecimal(denom)
            if (denom == GRAVITY_BRIDGE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else if (denom.starts(with: "gravity0x")) {
                denomLabel?.textColor = UIColor(named: "_font05")
                if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom) {
                    denomLabel?.text = bridgeTokenInfo.origin_symbol
                } else {
                    denomLabel?.text = denom.uppercased()
                }
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, dpDecimal, dpDecimal)
            
        } else if (chainType == ChainType.STARGAZE_MAIN) {
            if (denom == STARGAZE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.COMDEX_MAIN) {
            if (denom == COMDEX_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.INJECTIVE_MAIN) {
            let dpDecimal = WUtils.getInjectiveCoinDecimal(denom)
            if (denom == INJECTIVE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else if (denom.starts(with: "peggy0x")) {
                denomLabel?.textColor = UIColor(named: "_font05")
                if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom) {
                    denomLabel?.text = bridgeTokenInfo.origin_symbol
                } else {
                    denomLabel?.text = denom.uppercased()
                }
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, dpDecimal, dpDecimal)
            
        } else if (chainType == ChainType.BITSONG_MAIN) {
            if (denom == BITSONG_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.DESMOS_MAIN) {
            if (denom == DESMOS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.LUM_MAIN) {
            if (denom == LUM_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.CHIHUAHUA_MAIN) {
            if (denom == CHIHUAHUA_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.KONSTELLATION_MAIN) {
            if (denom == KONSTELLATION_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.EVMOS_MAIN) {
            if (denom == EVMOS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 18, 18)
            
        } else if (chainType == ChainType.PROVENANCE_MAIN) {
            if (denom == PROVENANCE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 9, 9)
            
        } else if (chainType == ChainType.CUDOS_MAIN) {
            if (denom == CUDOS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 18, 18)
            
        } else if (chainType == ChainType.CERBERUS_MAIN) {
            if (denom == CERBERUS_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.OMNIFLIX_MAIN) {
            if (denom == OMNIFLIX_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.CRESCENT_MAIN || chainType == ChainType.CRESCENT_TEST) {
            if (denom == CRESCENT_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.MANTLE_MAIN) {
            if (denom == MANTLE_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        } else if (chainType == ChainType.NYX_MAIN) {
            if (denom == NYX_MAIN_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else if (denom == NYX_NYM_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "nyx_nym")
                denomLabel?.text = "NYM"
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        }
        
        else if (chainType == ChainType.STATION_TEST) {
            if (denom == STATION_TEST_DENOM) {
                WUtils.setDenomTitle(chainType, denomLabel)
            } else {
                denomLabel?.textColor = UIColor(named: "_font05")
                denomLabel?.text = denom.uppercased()
            }
            amountLabel.attributedText = displayAmount2(amount, amountLabel.font, 6, 6)
            
        }
            
    }
    
    static func isBnbMarketToken(_ symbol:String?) ->Bool {
        switch symbol {
        case "USDT.B-B7C":
            return true
        case "ETH.B-261":
            return true
        case "BTC.B-918":
            return true
        case "USDSB-1AC":
            return true
        case "THKDB-888":
            return true
        case "TUSDB-888":
            return true
        case "BTCB-1DE":
            return true
            
        case "ETH-1C9":
            return true
        case "BUSD-BD1":
            return true
        case "IDRTB-178":
            return true
        case "TAUDB-888":
            return true
            
        default:
            return false
        }
    }
    
    static func getBnbTicSymbol(_ symbol:String) -> String {
        if (isBnbMarketToken(symbol)) {
            return BNB_MAIN_DENOM + "_" + symbol
        } else {
            return  "" + symbol + "_" + BNB_MAIN_DENOM
        }
    }
    
    static func getMainDenom(_ chain:ChainType?) -> String {
        guard let chainConfig = ChainFactory.getChainConfig(chain) else {
            return ""
        }
        return chainConfig.stakeDenom
    }
    
    static func getGasDenom(_ chain:ChainType?) -> String {
        if (chain == ChainType.NYX_MAIN) {
            return NYX_NYM_DENOM
        } else {
            return getMainDenom(chain)
        }
    }
    
    static func getDenomDecimal(_ chainConfig: ChainConfig?, _ denom: String?) -> Int16 {
        if (chainConfig == nil || denom == nil) { return 6 }
        if (denom!.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom!.replacingOccurrences(of: "ibc/", with: "")),
                let decimal = ibcToken.decimal  {
                return decimal
            }
        }
        if (chainConfig!.stakeDenom == denom) {
            return mainDivideDecimal(chainConfig!.chainType)
        }
        if (chainConfig!.chainType == .OSMOSIS_MAIN) {
            if (denom?.caseInsensitiveCompare(OSMOSIS_ION_DENOM) == .orderedSame) { return 6; }
            else if (denom!.starts(with: "gamm/pool/")) { return 18; }
            return 6
            
        } else if (chainConfig!.chainType == .SIF_MAIN) {
            if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                return bridgeTokenInfo.decimal
            }
            return 18
            
        } else if (chainConfig!.chainType == .GRAVITY_BRIDGE_MAIN) {
            if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                return bridgeTokenInfo.decimal
            }
            return 18
            
        } else if (chainConfig!.chainType == .KAVA_MAIN) {
            if (denom?.caseInsensitiveCompare("btc") == .orderedSame) { return 8; }
            else if (denom?.caseInsensitiveCompare("bnb") == .orderedSame) { return 8; }
            else if (denom?.caseInsensitiveCompare("btcb") == .orderedSame || denom?.caseInsensitiveCompare("hbtc") == .orderedSame) { return 8; }
            else if (denom?.caseInsensitiveCompare("busd") == .orderedSame) { return 8; }
            else if (denom?.caseInsensitiveCompare("xrpb") == .orderedSame || denom?.caseInsensitiveCompare("xrbp") == .orderedSame) { return 8; }
            return 6;
            
        } else if (chainConfig!.chainType == .INJECTIVE_MAIN) {
            if (denom?.starts(with: "share") == true) { return 18 }
            else if (denom?.starts(with: "peggy0x") == true) {
                if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom ?? "") {
                    return bridgeTokenInfo.decimal
                }
            }
            return 18
            
        }
        return mainDivideDecimal(chainConfig!.chainType)
    }
    
    static func mainDivideDecimal(_ chain:ChainType?) -> Int16 {
        if (chain == .FETCH_MAIN || chain == .SIF_MAIN || chain == .INJECTIVE_MAIN ||
            chain == .EVMOS_MAIN || chain == .CUDOS_MAIN) {
            return 18
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            return 9
        } else if (chain == ChainType.CRYPTO_MAIN) {
            return 8
        } else if (chain == .BINANCE_MAIN || chain == .OKEX_MAIN) {
            return 0
        } else {
            return 6
        }
    }
    
    static func mainDisplayDecimal(_ chain:ChainType?) -> Int16 {
        if (chain == .FETCH_MAIN || chain == .SIF_MAIN || chain == .INJECTIVE_MAIN ||
            chain == .EVMOS_MAIN || chain == .CUDOS_MAIN || chain == .OKEX_MAIN) {
            return 18
        } else if (chain == .PROVENANCE_MAIN) {
            return 9
        } else if (chain == .BINANCE_MAIN || chain == .CRYPTO_MAIN) {
            return 8
        } else {
            return 6
        }
    }
    
    static func setDenomTitle(_ chain: ChainType?, _ label: UILabel?) {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            label?.text = chainConfig.stakeSymbol
            label?.textColor = chainConfig.chainColor
        }
    }
    
    static func setGasDenomTitle(_ chain: ChainType?, _ label: UILabel?) {
        if (chain == ChainType.NYX_MAIN) {
            label?.text = "NYM"
            label?.textColor = UIColor.init(named: "nyx_nym")
        } else {
            return setDenomTitle(chain, label)
        }
    }
    
    static func getChainDBName(_ chain:ChainType?) -> String {
        guard let chainConfig = ChainFactory.getChainConfig(chain) else {
            return ""
        }
        return chainConfig.chainDBName
    }
    
    static func getChainTypeInt(_ chainS:String) -> Int {
        if (chainS == CHAIN_COSMOS_S ) {
            return 1
        } else if (chainS == CHAIN_IRIS_S) {
            return 2
        } else if (chainS == CHAIN_BINANCE_S) {
            return 3
        }
        return 0
    }
    
    static func clearBackgroundColor(of view: UIView) {
        if let effectsView = view as? UIVisualEffectView {
            effectsView.removeFromSuperview()
            return
        }
        view.backgroundColor = .clear
        view.subviews.forEach { (subview) in
            self.clearBackgroundColor(of: subview)
        }
    }
    
    
    
    static func getPasswordAni() -> CAAnimation{
        let transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        return transition
    }
    
    static func getFeeInfos(_ chainConfig: ChainConfig?) -> Array<FeeInfo> {
        var result = Array<FeeInfo>()
        chainConfig?.getGasRates().forEach { gasInfo in
            result.append(FeeInfo.init(gasInfo))
        }
        if (result.count == 1) {
            result[0].title = "Fixed"
            result[0].msg = NSLocalizedString("fee_speed_title_fixed", comment: "")
        } else if (result.count == 2) {
            result[1].title = "Average"
            result[1].msg = NSLocalizedString("fee_speed_title_average", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = "Zero"
                result[0].msg = NSLocalizedString("fee_speed_title_zero", comment: "")
            } else {
                result[0].title = "Tiny"
                result[0].msg = NSLocalizedString("fee_speed_title_tiny", comment: "")
            }
        } else if (result.count == 3) {
            result[2].title = "Average"
            result[2].msg = NSLocalizedString("fee_speed_title_average", comment: "")
            result[1].title = "Low"
            result[1].msg = NSLocalizedString("fee_speed_title_low", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = "Zero"
                result[0].msg = NSLocalizedString("fee_speed_title_zero", comment: "")
            } else {
                result[0].title = "Tiny"
                result[0].msg = NSLocalizedString("fee_speed_title_tiny", comment: "")
            }
        }
        return result
    }
    
    static func getSymbol(_ chainConfig: ChainConfig?, _ denom: String?) -> String {
        if (chainConfig == nil || denom?.isEmpty == true) { return "Unknown" }
        if (chainConfig!.stakeDenom == denom) {
            return chainConfig!.stakeSymbol
        }
        if (chainConfig!.isGrpc && denom!.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom!.replacingOccurrences(of: "ibc/", with: "")),
               ibcToken.auth == true {
                return ibcToken.display_denom?.uppercased() ?? "Unknown"
            } else {
                return "Unknown"
            }
        }
        if (chainConfig!.chainType == .KAVA_MAIN) {
            if (denom == KAVA_HARD_DENOM) { return "HARD" }
            else if (denom == KAVA_USDX_DENOM) { return "USDX" }
            else if (denom == KAVA_SWAP_DENOM) { return "SWP" }
            else if (denom == TOKEN_HTLC_KAVA_BNB) { return "BNB" }
            else if (denom == TOKEN_HTLC_KAVA_XRPB) { return "XRPB" }
            else if (denom == TOKEN_HTLC_KAVA_BUSD) { return "BUSD" }
            else if (denom == TOKEN_HTLC_KAVA_BTCB) { return "BTCB" }
            else if (denom == "btch") { return "BTCH" }
            
        } else if (chainConfig!.chainType == .OSMOSIS_MAIN) {
            if (denom == OSMOSIS_ION_DENOM) { return "ION" }
            else if (denom!.starts(with: "gamm/pool/")) {
                return "GAMM-" + String(denom!.split(separator: "/").last!)
            }
            
        } else if (chainConfig!.chainType == .SIF_MAIN) {
            if (denom!.starts(with: "c")) { return denom!.substring(from: 1).uppercased() }
            
        } else if (chainConfig!.chainType == .CRESCENT_MAIN) {
            if (denom == CRESCENT_BCRE_DENOM) { return "BCRE" }
            else if (denom!.starts(with: "pool")) { return denom!.uppercased() }
            
        } else if (chainConfig!.chainType == .EMONEY_MAIN) {
            if (denom == EMONEY_EUR_DENOM) { return denom!.uppercased() }
            else if (denom == EMONEY_CHF_DENOM) { return denom!.uppercased() }
            else if (denom == EMONEY_DKK_DENOM) { return denom!.uppercased() }
            else if (denom == EMONEY_NOK_DENOM) { return denom!.uppercased() }
            else if (denom == EMONEY_SEK_DENOM) { return denom!.uppercased() }
            
        } else if (chainConfig!.chainType == .GRAVITY_BRIDGE_MAIN) {
            if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                return bridgeTokenInfo.origin_symbol ?? "Unknown"
            }
            
        } else if (chainConfig!.chainType == .INJECTIVE_MAIN) {
            if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                return bridgeTokenInfo.origin_symbol ?? "Unknown"
            } else if (denom!.starts(with: "share")) { return denom!.uppercased() }
            
        } else if (chainConfig!.chainType == .NYX_MAIN) {
            if (denom == NYX_NYM_DENOM) { return "NYM" }
            
        }
        
        else if (chainConfig!.chainType == .BINANCE_MAIN) {
            if let bnbTokenInfo = getBnbToken(denom!) {
                return bnbTokenInfo.original_symbol.uppercased()
            }
            
        } else if (chainConfig!.chainType == .OKEX_MAIN) {
            if let okTokenInfo = getOkToken(denom!) {
                return okTokenInfo.original_symbol!.uppercased()
            }
        }
        return "Unknown"
    }

    static func getEstimateGasAmount(_ chain:ChainType, _ type:String,  _ valCnt:Int) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.IRIS_MAIN || chain == ChainType.AKASH_MAIN ||
            chain == ChainType.PERSIS_MAIN || chain == ChainType.CRYPTO_MAIN || chain == ChainType.EMONEY_MAIN ||
            chain == ChainType.RIZON_MAIN || chain == ChainType.JUNO_MAIN || chain == ChainType.REGEN_MAIN ||
            chain == ChainType.BITCANA_MAIN || chain == ChainType.STARGAZE_MAIN || chain == ChainType.COMDEX_MAIN ||
            chain == ChainType.BITSONG_MAIN || chain == ChainType.DESMOS_MAIN || chain == ChainType.GRAVITY_BRIDGE_MAIN ||
            chain == ChainType.LUM_MAIN || chain == ChainType.AXELAR_MAIN || chain == ChainType.KONSTELLATION_MAIN ||
            chain == ChainType.UMEE_MAIN || chain == ChainType.PROVENANCE_MAIN || chain == ChainType.EVMOS_MAIN ||
            chain == ChainType.CUDOS_MAIN || chain == ChainType.CERBERUS_MAIN || chain == ChainType.OMNIFLIX_MAIN ||
            chain == ChainType.CRESCENT_MAIN || chain == ChainType.MANTLE_MAIN || chain == ChainType.NYX_MAIN ||
            chain == ChainType.COSMOS_TEST || chain == ChainType.IRIS_TEST || chain == ChainType.ALTHEA_TEST ||
            chain == ChainType.CRESCENT_TEST || chain == ChainType.STATION_TEST) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_LOW))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_LOW))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_LOW))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_IBC_SEND))
            } else if (type == TASK_TYPE_NFT_ISSUE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_NFT_SEND) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_NFT_ISSUE_DENOM) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_DESMOS_GEN_PROFILE || type == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_PROFILE))
            } else if (type == TASK_TYPE_IBC_CW20_TRANSFER) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.OSMOSIS_MAIN ) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_LOW))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_LOW))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_LOW))
            } else if (type == TASK_TYPE_OSMOSIS_SWAP) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_OSMOS_SWAP))
            } else if (type == TASK_TYPE_OSMOSIS_JOIN_POOL) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_OSMOS_JOIN_POOL))
            } else if (type == TASK_TYPE_OSMOSIS_EXIT_POOL) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_OSMOS_EXIT_POOL))
            } else if (type == TASK_TYPE_OSMOSIS_LOCK) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_OSMOS_LOCK))
            } else if (type == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_OSMOS_BEGIN_UNBONDING))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_IBC_SEND))
            }
        }
        
        else if (chain == ChainType.KAVA_MAIN) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_KAVA_CDP_CREATE || type == TASK_TYPE_KAVA_CDP_DEPOSIT || type == TASK_TYPE_KAVA_CDP_WITHDRAW ||
                        type == TASK_TYPE_KAVA_CDP_DRAWDEBT || type == TASK_TYPE_KAVA_CDP_REPAY) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_CDP))
            } else if (type == TASK_TYPE_KAVA_HARD_DEPOSIT || type == TASK_TYPE_KAVA_HARD_WITHDRAW || type == TASK_TYPE_KAVA_HARD_BORROW ||
                        type == TASK_TYPE_KAVA_HARD_REPAY) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_HARD_POOL))
            } else if (type == TASK_TYPE_KAVA_SWAP_TOKEN) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_SWAP_TOKEN))
            } else if (type == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_SWAP_DEPOSIT))
            } else if (type == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_SWAP_WITHDRAW))
            } else if (type == TASK_TYPE_KAVA_INCENTIVE_ALL) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_CLAIM_INCENTIVE_ALL))
            } else if (type == TASK_TYPE_HTLC_SWAP) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_BEP3))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(KAVA_GAS_AMOUNT_BEP3))
            }
            
        } else if (chain == ChainType.BAND_MAIN) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = WUtils.getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(BAND_GAS_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.IOV_MAIN) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = WUtils.getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_STARNAME_REGISTER_DOMAIN || type == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_REGISTER))
            } else if (type == TASK_TYPE_STARNAME_DELETE_DOMAIN || type == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_DELETE))
            } else if (type == TASK_TYPE_STARNAME_RENEW_DOMAIN || type == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_RENEW))
            } else if (type == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_REPLACE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(IOV_GAS_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.OKEX_MAIN) {
            if (type == TASK_TYPE_TRANSFER || type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(OK_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_OK_DEPOSIT || type == TASK_TYPE_OK_WITHDRAW) {
                result = (NSDecimalNumber.init(string: OK_GAS_AMOUNT_STAKE_MUX).multiplying(by: NSDecimalNumber.init(value: valCnt))).adding(NSDecimalNumber.init(string: OK_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_OK_DIRECT_VOTE) {
                result = (NSDecimalNumber.init(string: OK_GAS_AMOUNT_VOTE_MUX).multiplying(by: NSDecimalNumber.init(value: valCnt))).adding(NSDecimalNumber.init(string: OK_GAS_AMOUNT_VOTE))
            }
            
        } else if (chain == ChainType.CERTIK_MAIN) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE || type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.SECRET_MAIN) {
            if (type == TASK_TYPE_TRANSFER || type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(SECRET_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE || type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(SECRET_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(SECRET_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(SECRET_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(SECRET_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(SECRET_GAS_AMOUNT_VOTE))
            }
            
        } else if (chain == ChainType.SENTINEL_MAIN) {
            if (type == TASK_TYPE_TRANSFER || type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(SENTINEL_GAS_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.FETCH_MAIN) {
            if (type == TASK_TYPE_TRANSFER || type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(FETCH_GAS_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.SIF_MAIN) {
            if (type == TASK_TYPE_TRANSFER || type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_IBC_SEND))
            } else if (type == TASK_TYPE_SIF_ADD_LP || type == TASK_TYPE_SIF_REMOVE_LP) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_LP))
            } else if (type == TASK_TYPE_SIF_SWAP_CION) {
                result = NSDecimalNumber.init(string: String(SIF_GAS_AMOUNT_SWAP))
            }
            
        } else if (chain == ChainType.KI_MAIN) {
            if (type == TASK_TYPE_TRANSFER) {
               result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(KI_GAS_AMOUNT_VOTE))
            }
            
        } else if (chain == ChainType.MEDI_MAIN) {
            if (type == TASK_TYPE_TRANSFER || type == TASK_TYPE_IBC_TRANSFER) {
               result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_SEND))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_STAKE))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_REINVEST))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_REWARD_ADDRESS_CHANGE))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_VOTE))
            } else if (type == TASK_TYPE_IBC_TRANSFER) {
                result = NSDecimalNumber.init(string: String(MEDI_GAS_AMOUNT_IBC_SEND))
            }
            
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_REDELEGATE))
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(CERTIK_GAS_AMOUNT_REINVEST))
            } else {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            }
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            if (type == TASK_TYPE_TRANSFER) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_DELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_UNDELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_REDELEGATE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_CLAIM_STAKE_REWARD) {
                result = getGasAmountForKavaRewards()[valCnt - 1]
            } else if (type == TASK_TYPE_REINVEST) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_HIGH))
            } else if (type == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            } else if (type == TASK_TYPE_VOTE) {
                result = NSDecimalNumber.init(string: String(GAS_FEE_AMOUNT_MID))
            }
            
        }
        return result
    }
    
    static func getEstimateGasFeeAmount(_ chain:ChainType, _ type:String,  _ valCnt:Int) -> NSDecimalNumber {
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.AKASH_MAIN || chain == ChainType.RIZON_MAIN ||
            chain == ChainType.JUNO_MAIN || chain == ChainType.REGEN_MAIN || chain == ChainType.BITCANA_MAIN ||
            chain == ChainType.STARGAZE_MAIN || chain == ChainType.COMDEX_MAIN ||
            chain == ChainType.COSMOS_TEST || chain == ChainType.ALTHEA_TEST || chain == ChainType.CRESCENT_TEST || chain == ChainType.STATION_TEST) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.IRIS_MAIN || chain == ChainType.IRIS_TEST) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_IRIS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.PERSIS_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_PERSIS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.CRYPTO_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CRYPTO)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.SENTINEL_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_SENTINEL)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_OSMOSIS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.BAND_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_BAND)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.IOV_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_IOV)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.SIF_MAIN) {
            return NSDecimalNumber.init(string: "100000000000000000")
            
        } else if (chain == ChainType.MEDI_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_MEDI)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.CERTIK_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CERTIK)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.EMONEY_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_EMONEY)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.FETCH_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_FETCH)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.KI_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_KI)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.SECRET_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_SECRET)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_INJECTIVE)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.BITSONG_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_BITSONG)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.DESMOS_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_DESMOS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_GRAV)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.LUM_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_LUM)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CHIHUAHUA)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.KAVA_MAIN) {
            if (type == TASK_TYPE_HTLC_SWAP) {
                return NSDecimalNumber.init(string: "12500")
            } else {
                let gasRate = NSDecimalNumber.init(string: KAVA_GAS_RATE_AVERAGE)
                let gasAmount = getEstimateGasAmount(chain, type, valCnt)
                return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            }
            
        } else if (chain == ChainType.AXELAR_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_AXELAR)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.JUNO_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_JUNO)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_KONSTELLATION)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.UMEE_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_UMEE)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_PROVENANCE)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.EVMOS_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_EVMOS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.CUDOS_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CUDOS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.CERBERUS_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CERBERUS)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.OMNIFLIX_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_OMNIFLIX)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.CRESCENT_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CRESCENT)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.MANTLE_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_MANTLE)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        } else if (chain == ChainType.NYX_MAIN) {
            let gasRate = NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_NYX)
            let gasAmount = getEstimateGasAmount(chain, type, valCnt)
            return gasRate.multiplying(by: gasAmount, withBehavior: handler0)
            
        }
        
        else if (chain == ChainType.OKEX_MAIN) {
           let gasRate = NSDecimalNumber.init(string: OK_GAS_RATE_AVERAGE)
           let gasAmount = getEstimateGasAmount(chain, type, valCnt)
           return gasRate.multiplying(by: gasAmount, withBehavior: handler18)
           
       }
        return NSDecimalNumber.zero
    }
    
    static func getGasRate(_ chain:ChainType, _ position: Int) -> NSDecimalNumber {
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.AKASH_MAIN || chain == ChainType.RIZON_MAIN ||
            chain == ChainType.REGEN_MAIN ||
            chain == ChainType.COSMOS_TEST || chain == ChainType.ALTHEA_TEST || chain == ChainType.CRESCENT_TEST || chain == ChainType.STATION_TEST) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE)
            }
            
        } else if (chain == ChainType.IRIS_MAIN || chain == ChainType.IRIS_TEST) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_IRIS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_IRIS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_IRIS)
            }
            
        } else if (chain == ChainType.PERSIS_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_PERSIS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_PERSIS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_PERSIS)
            }
            
        } else if (chain == ChainType.CRYPTO_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_CRYPTO)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_CRYPTO)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CRYPTO)
            }
            
        } else if (chain == ChainType.SENTINEL_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_SENTINEL)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_SENTINEL)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_SENTINEL)
            }
            
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_OSMOSIS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_OSMOSIS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_OSMOSIS)
            }
            
        } else if (chain == ChainType.BAND_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_BAND)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_BAND)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_BAND)
            }
            
        } else if (chain == ChainType.IOV_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_IOV)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_IOV)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_IOV)
            }
            
        } else if (chain == ChainType.MEDI_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_MEDI)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_MEDI)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_MEDI)
            }
            
        } else if (chain == ChainType.CERTIK_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_CERTIK)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_CERTIK)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CERTIK)
            }
            
        } else if (chain == ChainType.EMONEY_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_EMONEY)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_EMONEY)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_EMONEY)
            }
            
        } else if (chain == ChainType.FETCH_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_FETCH)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_FETCH)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_FETCH)
            }
            
        } else if (chain == ChainType.BITCANA_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_BITCANNA)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_BITCANNA)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_BITCANNA)
            }
            
        } else if (chain == ChainType.STARGAZE_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_STARGAZER)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_STARGAZER)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_STARGAZER)
            }
            
        } else if (chain == ChainType.KI_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_KI)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_KI)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_KI)
            }
            
        } else if (chain == ChainType.COMDEX_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_COMDEX)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_COMDEX)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_COMDEX)
            }
            
        } else if (chain == ChainType.SECRET_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_SECRET)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_SECRET)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_SECRET)
            }
            
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_INJECTIVE)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_INJECTIVE)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_INJECTIVE)
            }
            
        } else if (chain == ChainType.BITSONG_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_BITSONG)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_BITSONG)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_BITSONG)
            }
            
        } else if (chain == ChainType.DESMOS_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_DESMOS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_DESMOS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_DESMOS)
            }
            
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_GRAV)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_GRAV)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_GRAV)
            }
            
        } else if (chain == ChainType.LUM_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_LUM)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_LUM)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_LUM)
            }
            
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_CHIHUAHUA)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_CHIHUAHUA)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CHIHUAHUA)
            }
            
        } else if (chain == ChainType.KAVA_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: KAVA_GAS_RATE_TINY)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: KAVA_GAS_RATE_LOW)
            } else {
                return NSDecimalNumber.init(string: KAVA_GAS_RATE_AVERAGE)
            }
            
        } else if (chain == ChainType.AXELAR_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_AXELAR)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_AXELAR)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_AXELAR)
            }
            
        } else if (chain == ChainType.JUNO_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_JUNO)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_JUNO)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_JUNO)
            }
            
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_KONSTELLATION)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_KONSTELLATION)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_KONSTELLATION)
            }
            
        } else if (chain == ChainType.UMEE_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_UMEE)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_UMEE)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_UMEE)
            }
        
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_PROVENANCE)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_PROVENANCE)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_PROVENANCE)
            }
        
        } else if (chain == ChainType.EVMOS_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_EVMOS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_EVMOS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_EVMOS)
            }
        
        } else if (chain == ChainType.CUDOS_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_CUDOS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_CUDOS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CUDOS)
            }
            
        } else if (chain == ChainType.CERBERUS_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_CERBERUS)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_CERBERUS)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CERBERUS)
            }
            
        } else if (chain == ChainType.OMNIFLIX_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_OMNIFLIX)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_OMNIFLIX)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_OMNIFLIX)
            }
            
        } else if (chain == ChainType.CRESCENT_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_CRESCENT)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_CRESCENT)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_CRESCENT)
            }
            
        } else if (chain == ChainType.MANTLE_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_MANTLE)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_MANTLE)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_MANTLE)
            }
            
        } else if (chain == ChainType.NYX_MAIN) {
            if (position == 0) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_TINY_NYX)
            } else if (position == 1) {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_LOW_NYX)
            } else {
                return NSDecimalNumber.init(string: GAS_FEE_RATE_AVERAGE_NYX)
            }
        }
        
        else if (chain == ChainType.OKEX_MAIN) {
            return NSDecimalNumber.init(string: OK_GAS_RATE_AVERAGE)
        }
        return NSDecimalNumber.zero
    }
    
    static func getGasAmountForRewards() -> Array<NSDecimalNumber> {
        var gasAmounts = Array<NSDecimalNumber>()
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_1))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_2))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_3))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_4))
        
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_5))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_6))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_7))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_8))
        
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_9))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_10))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_11))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_12))
        
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_13))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_14))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_15))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_REWARD_GAS_16))
        return gasAmounts
    }
    
    static func getGasAmountForKavaRewards() -> Array<NSDecimalNumber> {
        var gasAmounts = Array<NSDecimalNumber>()
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_1))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_2))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_3))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_4))
        
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_5))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_6))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_7))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_8))
        
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_9))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_10))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_11))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_12))
        
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_13))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_14))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_15))
        gasAmounts.append(NSDecimalNumber.init(string: FEE_KAVA_REWARD_GAS_16))
        return gasAmounts
    }
    
    static func getDPRawDollor(_ price:String, _ scale:Int, _ font:UIFont) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = scale
        nf.maximumFractionDigits = scale
        nf.numberStyle = .decimal
        
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: Int16(scale), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let amount = plainStringToDecimal(price).rounding(accordingToBehavior: handler)
        
        let added       = "$ " + nf.string(from: amount)!
        let endIndex    = added.index(added.endIndex, offsetBy: -scale)
        
        let preString   = added[..<endIndex]
        let postString  = added[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func dpChainInfo(_ chain: ChainType, _ img: UIImageView?, _ label: UILabel) {
        if (chain == ChainType.COSMOS_MAIN) {
            label.text = NSLocalizedString("chain_title_cosmos", comment: "")
            img?.image = UIImage(named: "chainCosmos")
        } else if (chain == ChainType.IRIS_MAIN) {
            label.text = NSLocalizedString("chain_title_iris", comment: "")
            img?.image = UIImage(named: "chainIris")
        } else if (chain == ChainType.BINANCE_MAIN) {
            label.text = NSLocalizedString("chain_title_bnb", comment: "")
            img?.image = UIImage(named: "chainBinance")
        } else if (chain == ChainType.KAVA_MAIN) {
            label.text = NSLocalizedString("chain_title_kava", comment: "")
           img?.image = UIImage(named: "chainKava")
        } else if (chain == ChainType.IOV_MAIN) {
            label.text = NSLocalizedString("chain_title_iov", comment: "")
            img?.image = UIImage(named: "chainStarname")
        } else if (chain == ChainType.BAND_MAIN) {
            label.text = NSLocalizedString("chain_title_band", comment: "")
            img?.image = UIImage(named: "chainBand")
        }
    }
    
    static func dpChainName(_ chain: ChainType) -> String {
        if (chain == ChainType.COSMOS_MAIN) {
            return NSLocalizedString("chain_title_cosmos", comment: "")
        } else if (chain == ChainType.IRIS_MAIN) {
            return NSLocalizedString("chain_title_iris", comment: "")
        } else if (chain == ChainType.BINANCE_MAIN) {
            return NSLocalizedString("chain_title_bnb", comment: "")
        } else if (chain == ChainType.KAVA_MAIN) {
            return NSLocalizedString("chain_title_kava", comment: "")
        } else if (chain == ChainType.IOV_MAIN) {
            return NSLocalizedString("chain_title_iov", comment: "")
        } else if (chain == ChainType.BAND_MAIN) {
            return NSLocalizedString("chain_title_band", comment: "")
        }
        return ""
    }
    
    static func onDpSwapChain(_ chain: ChainType, _ img: UIImageView?, _ label: UILabel) {
        if (chain == ChainType.BINANCE_MAIN) {
            label.text = "BINANCE"
            img?.image = UIImage(named: "chainBinance")
        } else if (chain == ChainType.KAVA_MAIN) {
            label.text = "KAVA"
           img?.image = UIImage(named: "chainKava")
        }
    }
    
    static func getRealBlockTime(_ chain: ChainType?) -> NSDecimalNumber {
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.COSMOS_TEST) {
            return BLOCK_TIME_COSMOS
            
        } else if (chain == ChainType.IRIS_MAIN || chain == ChainType.IRIS_TEST) {
            return BLOCK_TIME_IRIS
            
        } else if (chain == ChainType.IOV_MAIN) {
            return BLOCK_TIME_IOV
            
        } else if (chain == ChainType.KAVA_MAIN) {
            return BLOCK_TIME_KAVA
            
        } else if (chain == ChainType.BAND_MAIN) {
            return BLOCK_TIME_BAND
            
        } else if (chain == ChainType.CERTIK_MAIN) {
            return BLOCK_TIME_CERTIK
            
        } else if (chain == ChainType.SECRET_MAIN) {
            return BLOCK_TIME_SECRET
            
        } else if (chain == ChainType.AKASH_MAIN) {
            return BLOCK_TIME_AKASH
            
        } else if (chain == ChainType.SENTINEL_MAIN) {
            return BLOCK_TIME_SENTINEL
            
        } else if (chain == ChainType.PERSIS_MAIN) {
            return BLOCK_TIME_PERSISTENCE
            
        } else if (chain == ChainType.FETCH_MAIN) {
            return BLOCK_TIME_FETCH
            
        } else if (chain == ChainType.CRYPTO_MAIN) {
            return BLOCK_TIME_CRYPTO
            
        } else if (chain == ChainType.SIF_MAIN) {
            return BLOCK_TIME_SIF
            
        } else if (chain == ChainType.KI_MAIN) {
            return BLOCK_TIME_KI
            
        } else if (chain == ChainType.MEDI_MAIN) {
            return BLOCK_TIME_MEDI
            
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            return BLOCK_TIME_OSMOSIS
            
        } else if (chain == ChainType.EMONEY_MAIN) {
            return BLOCK_TIME_EMONEY
            
        } else if (chain == ChainType.EMONEY_MAIN) {
            return BLOCK_TIME_EMONEY
            
        } else if (chain == ChainType.RIZON_MAIN) {
            return BLOCK_TIME_RIZON
            
        } else if (chain == ChainType.JUNO_MAIN) {
            return BLOCK_TIME_JUNO
            
        } else if (chain == ChainType.BITCANA_MAIN) {
            return BLOCK_TIME_BITCANNA
            
        } else if (chain == ChainType.REGEN_MAIN) {
            return BLOCK_TIME_REGEN
            
        } else if (chain == ChainType.STARGAZE_MAIN) {
            return BLOCK_TIME_STARGAZE
            
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            return BLOCK_TIME_INJECTIVE
            
        } else if (chain == ChainType.BITSONG_MAIN) {
            return BLOCK_TIME_BITSONG
            
        } else if (chain == ChainType.DESMOS_MAIN) {
            return BLOCK_TIME_DESMOS
            
        } else if (chain == ChainType.COMDEX_MAIN) {
            return BLOCK_TIME_COMDEX
            
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            return BLOCK_TIME_GRAV
            
        } else if (chain == ChainType.LUM_MAIN) {
            return BLOCK_TIME_LUM
            
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            return BLOCK_TIME_CHIHUAHUA
            
        } else if (chain == ChainType.AXELAR_MAIN) {
            return BLOCK_TIME_AXELAR
            
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            return BLOCK_TIME_KONSTEALLTION
            
        } else if (chain == ChainType.UMEE_MAIN) {
            return BLOCK_TIME_UMEE
            
        } else if (chain == ChainType.EVMOS_MAIN) {
            return BLOCK_TIME_EVMOS
            
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            return BLOCK_TIME_PROVENANCE
            
        } else if (chain == ChainType.CERBERUS_MAIN) {
            return BLOCK_TIME_CERBERUS
            
        } else if (chain == ChainType.OMNIFLIX_MAIN) {
            return BLOCK_TIME_OMNIFLIX
            
        }
        return NSDecimalNumber.zero
    }
    
    static func getRealBlockPerYear(_ chain: ChainType?) -> NSDecimalNumber {
        if (getRealBlockTime(chain) == NSDecimalNumber.zero) {
            return NSDecimalNumber.zero
        }
        return YEAR_SEC.dividing(by: getRealBlockTime(chain), withBehavior: handler2)
    }
    
    
    static func getMonikerImgUrl(_ chainConfig: ChainConfig?, _ opAddress: String) -> String {
        if (chainConfig == nil) { return "" }
        return chainConfig!.validatorImgUrl + opAddress + ".png"
    }
    
    static func getTxExplorer(_ chainConfig: ChainConfig?, _ hash: String) -> String {
        if (chainConfig == nil) { return "" }
        if (chainConfig?.chainType == .OKEX_MAIN) {
            return chainConfig!.explorerUrl + "tx/" + hash
        }
        return chainConfig!.explorerUrl + "txs/" + hash
    }
    
    static func getAccountExplorer(_ chainConfig: ChainConfig?, _ address: String) -> String {
        if (chainConfig == nil) { return "" }
        if (chainConfig?.chainType == .OKEX_MAIN) {
            return chainConfig!.explorerUrl + "address/" + address
        }
        return chainConfig!.explorerUrl + "account/" + address
    }
    
    static func getProposalExplorer(_ chainConfig: ChainConfig?, _ proposalId: String) -> String {
        if (chainConfig == nil) { return "" }
        return chainConfig!.explorerUrl + "proposals/" + proposalId
    }
    
    static func getChainNameByBaseChain(_ chainConfig: ChainConfig?) -> String {
        if (chainConfig == nil) { return "" }
        return chainConfig!.chainAPIName
    }
    
    static func getDefaultRlayerImg(_ chainConfig: ChainConfig?) -> String {
        if (chainConfig == nil) { return "" }
        return chainConfig!.relayerImgUrl
    }
    
    static func getChainTypeByChainId(_ chainId: String?) -> ChainType? {
        if (chainId?.contains("cosmoshub-") == true) {
            return ChainType.COSMOS_MAIN
        } else if (chainId?.contains("irishub-") == true) {
            return ChainType.IRIS_MAIN
        } else if (chainId?.contains("iov-") == true) {
            return ChainType.IOV_MAIN
        } else if (chainId?.contains("akashnet-") == true) {
            return ChainType.AKASH_MAIN
        } else if (chainId?.contains("sentinelhub-") == true) {
            return ChainType.SENTINEL_MAIN
        } else if (chainId?.contains("core-") == true) {
            return ChainType.PERSIS_MAIN
        } else if (chainId?.contains("sifchain-") == true) {
            return ChainType.SIF_MAIN
        } else if (chainId?.contains("osmosis-") == true) {
            return ChainType.OSMOSIS_MAIN
        } else if (chainId?.contains("crypto-org-") == true) {
            return ChainType.CRYPTO_MAIN
        } else if (chainId?.contains("laozi-mainnet") == true) {
            return ChainType.BAND_MAIN
        } else if (chainId?.contains("shentu-") == true) {
            return ChainType.CERTIK_MAIN
        } else if (chainId?.contains("fetchhub-") == true) {
            return ChainType.FETCH_MAIN
        } else if (chainId?.contains("panacea-") == true) {
            return ChainType.MEDI_MAIN
        } else if (chainId?.contains("emoney-") == true) {
            return ChainType.EMONEY_MAIN
        } else if (chainId?.contains("titan-") == true) {
            return ChainType.RIZON_MAIN
        } else if (chainId?.contains("juno-") == true) {
            return ChainType.JUNO_MAIN
        } else if (chainId?.contains("regen-") == true) {
            return ChainType.REGEN_MAIN
        } else if (chainId?.contains("bitcanna-") == true) {
            return ChainType.BITCANA_MAIN
        } else if (chainId?.contains("althea-") == true) {
            return ChainType.ALTHEA_MAIN
        } else if (chainId?.contains("stargaze-") == true) {
            return ChainType.STARGAZE_MAIN
        } else if (chainId?.contains("comdex-") == true) {
            return ChainType.COMDEX_MAIN
        } else if (chainId?.contains("injective-") == true) {
            return ChainType.INJECTIVE_MAIN
        } else if (chainId?.contains("kichain-") == true) {
            return ChainType.KI_MAIN
        } else if (chainId?.contains("secret-") == true) {
            return ChainType.SECRET_MAIN
        } else if (chainId?.contains("bitsong-") == true) {
            return ChainType.BITSONG_MAIN
        } else if (chainId?.contains("desmos-") == true) {
            return ChainType.DESMOS_MAIN
        } else if (chainId?.contains("gravity-bridge-") == true) {
            return ChainType.GRAVITY_BRIDGE_MAIN
        } else if (chainId?.contains("lum-") == true) {
            return ChainType.LUM_MAIN
        } else if (chainId?.contains("chihuahua-") == true) {
            return ChainType.CHIHUAHUA_MAIN
        } else if (chainId?.contains("kava_") == true) {
            return ChainType.KAVA_MAIN
        } else if (chainId?.contains("axelar-") == true) {
            return ChainType.AXELAR_MAIN
        } else if (chainId?.contains("darchub") == true) {
            return ChainType.KONSTELLATION_MAIN
        } else if (chainId?.contains("umee-") == true) {
            return ChainType.UMEE_MAIN
        } else if (chainId?.contains("evmos_") == true) {
            return ChainType.EVMOS_MAIN
        } else if (chainId?.contains("pio-mainnet-") == true) {
            return ChainType.PROVENANCE_MAIN
        } else if (chainId?.contains("cudos-") == true) {
            return ChainType.CUDOS_MAIN
        } else if (chainId?.contains("cerberus-") == true) {
            return ChainType.CERBERUS_MAIN
        } else if (chainId?.contains("omniflixhub-") == true) {
            return ChainType.OMNIFLIX_MAIN
        } else if (chainId?.contains("crescent-") == true) {
            return ChainType.CRESCENT_MAIN
        } else if (chainId?.contains("mantle-") == true) {
            return ChainType.MANTLE_MAIN
        } else if (chainId?.contains("nyx") == true) {
            return ChainType.NYX_MAIN
        }
        
        else if (chainId?.contains("mooncat-") == true) {
            return ChainType.CRESCENT_TEST
        } else if (chainId?.contains("station") == true) {
            return ChainType.STATION_TEST
        }
        
        return nil
    }
    
    static func isValidChainAddress(_ chain: ChainType?, _ address: String?) -> Bool {
        if (address?.starts(with: "0x") == true) {
            if (!WKey.isValidEthAddress(address!)) { return false }
            if (chain == ChainType.OKEX_MAIN) { return true }
            return false
        }
        
        if (!WKey.isValidateBech32(address ?? "")) { return false }
        if (address?.starts(with: "cosmos1") == true && chain == ChainType.COSMOS_MAIN) { return true }
        else if (address?.starts(with: "iaa1") == true && chain == ChainType.IRIS_MAIN) { return true }
        else if (address?.starts(with: "bnb1") == true && chain == ChainType.BINANCE_MAIN) { return true }
        else if (address?.starts(with: "kava1") == true && chain == ChainType.KAVA_MAIN) { return true }
        else if (address?.starts(with: "star1") == true && chain == ChainType.IOV_MAIN) { return true }
        else if (address?.starts(with: "band1") == true && chain == ChainType.BAND_MAIN) { return true }
        else if (address?.starts(with: "secret1") == true && chain == ChainType.SECRET_MAIN) { return true }
        else if (address?.starts(with: "certik1") == true && chain == ChainType.CERTIK_MAIN) { return true }
        else if (address?.starts(with: "akash1") == true && chain == ChainType.AKASH_MAIN) { return true }
        else if (address?.starts(with: "persistence1") == true && chain == ChainType.PERSIS_MAIN) { return true }
        else if (address?.starts(with: "sent1") == true && chain == ChainType.SENTINEL_MAIN) { return true }
        else if (address?.starts(with: "fetch1") == true && chain == ChainType.FETCH_MAIN) { return true }
        else if (address?.starts(with: "cro1") == true && chain == ChainType.CRYPTO_MAIN) { return true }
        else if (address?.starts(with: "sif1") == true && chain == ChainType.SIF_MAIN) { return true }
        else if (address?.starts(with: "ki1") == true && chain == ChainType.KI_MAIN) { return true }
        else if (address?.starts(with: "panacea1") == true && chain == ChainType.MEDI_MAIN) { return true }
        else if (address?.starts(with: "osmo1") == true && chain == ChainType.OSMOSIS_MAIN) { return true }
        else if (address?.starts(with: "emoney1") == true && chain == ChainType.EMONEY_MAIN) { return true }
        else if (address?.starts(with: "rizon1") == true && chain == ChainType.RIZON_MAIN) { return true }
        else if (address?.starts(with: "juno1") == true && chain == ChainType.JUNO_MAIN) { return true }
        else if (address?.starts(with: "regen1") == true && chain == ChainType.REGEN_MAIN) { return true }
        else if (address?.starts(with: "bcna1") == true && chain == ChainType.BITCANA_MAIN) { return true }
        else if (address?.starts(with: "althea1") == true && chain == ChainType.ALTHEA_MAIN) { return true }
        else if (address?.starts(with: "stars1") == true && chain == ChainType.STARGAZE_MAIN) { return true }
        else if (address?.starts(with: "comdex1") == true && chain == ChainType.COMDEX_MAIN)  { return true }
        else if (address?.starts(with: "inj1") == true && chain == ChainType.INJECTIVE_MAIN) { return true }
        else if (address?.starts(with: "bitsong1") == true && chain == ChainType.BITSONG_MAIN) { return true }
        else if (address?.starts(with: "desmos1") == true && chain == ChainType.DESMOS_MAIN) { return true }
        else if (address?.starts(with: "gravity1") == true && chain == ChainType.GRAVITY_BRIDGE_MAIN) { return true }
        else if (address?.starts(with: "lum1") == true && chain == ChainType.LUM_MAIN) { return true }
        else if (address?.starts(with: "chihuahua1") == true && chain == ChainType.CHIHUAHUA_MAIN) { return true }
        else if (address?.starts(with: "axelar1") == true && chain == ChainType.AXELAR_MAIN) { return true }
        else if (address?.starts(with: "darc1") == true && chain == ChainType.KONSTELLATION_MAIN) { return true }
        else if (address?.starts(with: "umee1") == true && chain == ChainType.UMEE_MAIN) { return true }
        else if (address?.starts(with: "evmos1") == true && chain == ChainType.EVMOS_MAIN) { return true }
        else if (address?.starts(with: "pb1") == true && chain == ChainType.PROVENANCE_MAIN) { return true }
        else if (address?.starts(with: "cudos1") == true && chain == ChainType.CUDOS_MAIN) { return true }
        else if (address?.starts(with: "cerberus1") == true && chain == ChainType.CERBERUS_MAIN) { return true }
        else if (address?.starts(with: "omniflix1") == true && chain == ChainType.OMNIFLIX_MAIN) { return true }
        else if (address?.starts(with: "cre1") == true && chain == ChainType.CRESCENT_MAIN) { return true }
        else if (address?.starts(with: "mantle") == true && chain == ChainType.MANTLE_MAIN) { return true }
        else if (address?.starts(with: "station1") == true && chain == ChainType.STATION_TEST) { return true }
        else if (address?.starts(with: "n1") == true && chain == ChainType.NYX_MAIN) { return true }
        return false
    }
    
    static func getChainsFromAddress(_ address: String?) -> Array<ChainType>? {
        if (address?.starts(with: "0x") == true) {
            if (WKey.isValidEthAddress(address!)) {
                return [ChainType.OKEX_MAIN]
            } else {
                return nil
            }
        }
        
        if (!WKey.isValidateBech32(address ?? "")) { return nil }
        if (address?.starts(with: "cosmos1") == true) { return [ChainType.COSMOS_MAIN, ChainType.COSMOS_TEST] }
        else if (address?.starts(with: "iaa1") == true) { return [ChainType.IRIS_MAIN, ChainType.IRIS_TEST] }
        else if (address?.starts(with: "bnb1") == true) { return [ChainType.BINANCE_MAIN] }
        else if (address?.starts(with: "kava1") == true) { return [ChainType.KAVA_MAIN] }
        else if (address?.starts(with: "star1") == true) { return [ChainType.IOV_MAIN] }
        else if (address?.starts(with: "band1") == true) { return [ChainType.BAND_MAIN] }
        else if (address?.starts(with: "secret1") == true) { return [ChainType.SECRET_MAIN] }
        else if (address?.starts(with: "certik1") == true) { return [ChainType.CERTIK_MAIN] }
        else if (address?.starts(with: "akash1") == true) { return [ChainType.AKASH_MAIN] }
        else if (address?.starts(with: "persistence1") == true) { return [ChainType.PERSIS_MAIN] }
        else if (address?.starts(with: "sent1") == true) { return [ChainType.SENTINEL_MAIN] }
        else if (address?.starts(with: "fetch1") == true) { return [ChainType.FETCH_MAIN] }
        else if (address?.starts(with: "cro1") == true) { return [ChainType.CRYPTO_MAIN] }
        else if (address?.starts(with: "sif1") == true) { return [ChainType.SIF_MAIN] }
        else if (address?.starts(with: "ki1") == true) { return [ChainType.KI_MAIN] }
        else if (address?.starts(with: "panacea1") == true) { return [ChainType.MEDI_MAIN] }
        else if (address?.starts(with: "osmo1") == true) { return [ChainType.OSMOSIS_MAIN] }
        else if (address?.starts(with: "emoney1") == true) { return [ChainType.EMONEY_MAIN] }
        else if (address?.starts(with: "rizon1") == true) { return [ChainType.RIZON_MAIN] }
        else if (address?.starts(with: "juno1") == true) { return [ChainType.JUNO_MAIN] }
        else if (address?.starts(with: "regen1") == true) { return [ChainType.REGEN_MAIN] }
        else if (address?.starts(with: "bcna1") == true) { return [ChainType.BITCANA_MAIN] }
        else if (address?.starts(with: "althea1") == true) { return [ChainType.ALTHEA_MAIN] }
        else if (address?.starts(with: "stars1") == true) { return [ChainType.STARGAZE_MAIN] }
        else if (address?.starts(with: "comdex1") == true) { return [ChainType.COMDEX_MAIN] }
        else if (address?.starts(with: "inj1") == true) { return [ChainType.INJECTIVE_MAIN] }
        else if (address?.starts(with: "bitsong1") == true) { return [ChainType.BITSONG_MAIN] }
        else if (address?.starts(with: "desmos1") == true) { return [ChainType.DESMOS_MAIN] }
        else if (address?.starts(with: "gravity1") == true) { return [ChainType.GRAVITY_BRIDGE_MAIN] }
        else if (address?.starts(with: "lum1") == true) { return [ChainType.LUM_MAIN] }
        else if (address?.starts(with: "chihuahua1") == true) { return [ChainType.CHIHUAHUA_MAIN] }
        else if (address?.starts(with: "axelar1") == true) { return [ChainType.AXELAR_MAIN] }
        else if (address?.starts(with: "darc1") == true) { return [ChainType.KONSTELLATION_MAIN] }
        else if (address?.starts(with: "umee1") == true) { return [ChainType.UMEE_MAIN] }
        else if (address?.starts(with: "evmos1") == true) { return [ChainType.EVMOS_MAIN] }
        else if (address?.starts(with: "pb1") == true) { return [ChainType.PROVENANCE_MAIN] }
        else if (address?.starts(with: "cudos1") == true) { return [ChainType.CUDOS_MAIN] }
        else if (address?.starts(with: "cerberus1") == true) { return [ChainType.CERBERUS_MAIN] }
        else if (address?.starts(with: "omniflix1") == true) { return [ChainType.OMNIFLIX_MAIN] }
        else if (address?.starts(with: "cre1") == true) { return [ChainType.CRESCENT_MAIN] }
        else if (address?.starts(with: "mantle1") == true) { return [ChainType.MANTLE_MAIN] }
        else if (address?.starts(with: "n1") == true) { return [ChainType.NYX_MAIN] }
        
        else if (address?.starts(with: "station1") == true) { return [ChainType.STATION_TEST] }
        
        return nil
    }
    
    
    static func systemQuorum(_ chain: ChainType?) -> NSDecimalNumber {
        if (BaseData.instance.mParam != nil) {
            return BaseData.instance.mParam!.getQuorum()
        }
        return NSDecimalNumber.zero
    }
    
    
    //address, accountnumber, sequencenumber
    static func onParseAuthGrpc(_ response :Cosmos_Auth_V1beta1_QueryAccountResponse) -> (String?, UInt64?, UInt64?) {
        var rawAccount = response.account
        if (rawAccount.typeURL.contains(Desmos_Profiles_V1beta1_Profile.protoMessageName)) {
            rawAccount = try! Desmos_Profiles_V1beta1_Profile.init(serializedData: rawAccount.value).account
        }
        
        if (rawAccount.typeURL.contains(Cosmos_Auth_V1beta1_BaseAccount.protoMessageName)) {
            let auth = try! Cosmos_Auth_V1beta1_BaseAccount.init(serializedData: rawAccount.value)
            return (auth.address, auth.accountNumber, auth.sequence)
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)) {
            let auth = try! Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value).baseVestingAccount.baseAccount
            return (auth.address, auth.accountNumber, auth.sequence)
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)) {
            let auth = try! Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value).baseVestingAccount.baseAccount
            return (auth.address, auth.accountNumber, auth.sequence)
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)) {
            let auth = try! Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value).baseVestingAccount.baseAccount
            return (auth.address, auth.accountNumber, auth.sequence)
            
        } else if (rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)) {
            let auth = try! Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value).baseAccount
            return (auth.address, auth.accountNumber, auth.sequence)
        
        } else if (rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)) {
            let auth = try! Ethermint_Types_V1_EthAccount.init(serializedData: rawAccount.value).baseAccount
            return (auth.address, auth.accountNumber, auth.sequence)
        }
        
        return (nil, nil, nil)
    }
    
    
    static func onParseAuthAccount(_ chain: ChainType, _ accountId: Int64) {
        print("onParseAuthAccount")
        guard let rawAccount = BaseData.instance.mAccount_gRPC else { return }
        if (chain == ChainType.DESMOS_MAIN && rawAccount.typeURL.contains(Desmos_Profiles_V1beta1_Profile.protoMessageName)) {
            if let profileAccount = try? Desmos_Profiles_V1beta1_Profile.init(serializedData: rawAccount.value) {
                onParseVestingAccount(chain, profileAccount.account)
            } else {
                onParseVestingAccount(chain, rawAccount)
            }
            
        } else if (chain == ChainType.INJECTIVE_MAIN && rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)) {
//            print("rawAccount.typeURL ", rawAccount.typeURL)
//            if let ethAccount = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
//                onParseVestingAccount(chain, ethAccount.baseAccount)
//            } else {
//                onParseVestingAccount(chain, rawAccount)
//            }
            onParseVestingAccount(chain, rawAccount)
            
        } else if (chain == ChainType.EVMOS_MAIN && rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)) {
            onParseVestingAccount(chain, rawAccount)
        } else {
            onParseVestingAccount(chain, rawAccount)
        }
        
        //Update local BD for save availabe(balance)to snap (ex kava bep3 swap check)
        var snapBalance = Array<Balance>()
        for balance_grpc in BaseData.instance.mMyBalances_gRPC {
            snapBalance.append(Balance(accountId, balance_grpc.denom, balance_grpc.amount, Date().millisecondsSince1970))
        }
        BaseData.instance.updateBalances(accountId, snapBalance)
    }
    
    static func onParseVestingAccount(_ chain: ChainType, _ rawAccount: Google_Protobuf2_Any) {
        var sBalace = Array<Coin>()
        BaseData.instance.mMyBalances_gRPC.forEach { coin in
            sBalace.append(coin)
        }
//        print("sBalace ", sBalace)
        if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)) {
//            print("PeriodicVestingAccount")
            let vestingAccount = try! Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value)
            sBalace.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
//                print("dpBalance ", denom, "  ", dpBalance)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
//                print("originalVesting ", denom, "  ", originalVesting)
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
//                print("delegatedVesting ", denom, "  ", delegatedVesting)
                
                remainVesting = WUtils.onParsePeriodicRemainVestingsAmountByDenom(vestingAccount, denom)
//                print("remainVesting ", denom, "  ", remainVesting)
                
                dpVesting = remainVesting.subtracting(delegatedVesting);
//                print("dpVestingA ", denom, "  ", dpVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
//                print("dpVestingB ", denom, "  ", dpVesting)
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
//                print("final dpBalance ", denom, "  ", dpBalance)
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Coin.init(denom, dpVesting.stringValue)
                    BaseData.instance.mMyVestings_gRPC.append(vestingCoin)
                    var replace = -1
                    for i in 0..<BaseData.instance.mMyBalances_gRPC.count {
                        if (BaseData.instance.mMyBalances_gRPC[i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        BaseData.instance.mMyBalances_gRPC[replace] = Coin.init(denom, dpBalance.stringValue)
                    }
                }
            })
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)) {
//            print("ContinuousVestingAccount")
            let vestingAccount = try! Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value)
            sBalace.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
//                print("dpBalance ", denom, "  ", dpBalance)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
//                print("originalVesting ", denom, "  ", originalVesting)
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
//                print("delegatedVesting ", denom, "  ", delegatedVesting)
                
                let cTime = Date().millisecondsSince1970
                let vestingStart = vestingAccount.startTime * 1000
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingStart) {
                    remainVesting = originalVesting
                } else if (cTime > vestingEnd) {
                    remainVesting = NSDecimalNumber.zero
                } else {
                    let progress = ((Float)(cTime - vestingStart)) / ((Float)(vestingEnd - vestingStart))
//                    print("progress ", progress)
                    remainVesting = originalVesting.multiplying(by: NSDecimalNumber.init(value: 1 - progress), withBehavior: handler0Up)
                }
//                print("remainVesting ", denom, "  ", remainVesting)
                
                dpVesting = remainVesting.subtracting(delegatedVesting);
//                print("dpVestingA ", denom, "  ", dpVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
//                print("dpVestingB ", denom, "  ", dpVesting)
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
//                print("final dpBalance ", denom, "  ", dpBalance)
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Coin.init(denom, dpVesting.stringValue)
                    BaseData.instance.mMyVestings_gRPC.append(vestingCoin)
                    var replace = -1
                    for i in 0..<BaseData.instance.mMyBalances_gRPC.count {
                        if (BaseData.instance.mMyBalances_gRPC[i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        BaseData.instance.mMyBalances_gRPC[replace] = Coin.init(denom, dpBalance.stringValue)
                    }
                }
                
            })
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)) {
//            print("DelayedVestingAccount")
            let vestingAccount = try! Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value)
            sBalace.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
//                print("dpBalance ", denom, "  ", dpBalance)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
//                print("originalVesting ", denom, "  ", originalVesting)
                
                let cTime = Date().millisecondsSince1970
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingEnd) {
                    remainVesting = originalVesting
                }
//                print("remainVesting ", denom, "  ", remainVesting)
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
//                print("delegatedVesting ", denom, "  ", delegatedVesting)
                
                dpVesting = remainVesting.subtracting(delegatedVesting);
//                print("dpVestingA ", denom, "  ", dpVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
//                print("dpVestingB ", denom, "  ", dpVesting)
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
//                print("final dpBalance ", denom, "  ", dpBalance)
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Coin.init(denom, dpVesting.stringValue)
                    BaseData.instance.mMyVestings_gRPC.append(vestingCoin)
                    var replace = -1
                    for i in 0..<BaseData.instance.mMyBalances_gRPC.count {
                        if (BaseData.instance.mMyBalances_gRPC[i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        BaseData.instance.mMyBalances_gRPC[replace] = Coin.init(denom, dpBalance.stringValue)
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
    
    static func onParseAllPeriodicRemainVestingsCnt(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount) -> Int {
        return onParsePeriodicRemainVestings(vestingAccount).count
    }
    
    static func onParsePeriodicRemainVestingsCntByDenom(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String) -> Int {
        return onParsePeriodicRemainVestingsByDenom(vestingAccount, denom).count
    }

    static func onParsePeriodicRemainVestingTime(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String, _ position: Int) -> Int64 {
        return onParsePeriodicRemainVestingsByDenom(vestingAccount, denom)[position].length
    }
    
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
    
    static func onParsePeriodicRemainVestingAmount(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String, _ position: Int) -> NSDecimalNumber {
        let periods = onParsePeriodicRemainVestingsByDenom(vestingAccount, denom)
        if (periods.count > position && periods[position] != nil) {
            let coin = periods[position].amount.filter { $0.denom == denom }.first
            return NSDecimalNumber.init(string: coin?.amount)
        }
        return NSDecimalNumber.zero
    }
    
    static func getAmountVp(_ vp: Cosmos_Vesting_V1beta1_Period, _ denom: String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        vp.amount.forEach { (coin) in
            if (coin.denom == denom) {
                result = NSDecimalNumber.init(string: coin.amount)
            }
        }
        return result
    }
    
    static func onParseFeeGrpc(_ chainType: ChainType, _ tx: Cosmos_Tx_V1beta1_GetTxResponse) -> Coin {
        if (tx.tx.authInfo.fee.amount.count > 0) {
            return Coin.init(tx.tx.authInfo.fee.amount[0].denom, tx.tx.authInfo.fee.amount[0].amount)
        } else {
            return Coin.init(getMainDenom(chainType), "0")
        }
    }
    
    
    static func onParseAutoRewardGrpc(_ tx: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) -> Array<Coin> {
        var result = Array<Coin>()
        if (tx.txResponse.logs == nil || tx.txResponse.logs.count <= position || tx.txResponse.logs[position] == nil)  { return result }
        tx.txResponse.logs[position].events.forEach { (event) in
            if (event.type == "transfer") {
                for i in 0...event.attributes.count - 1 {
                    if (event.attributes[i].key == "amount") {
                        let rawValue = event.attributes[i].value
                        for rawCoin in rawValue.split(separator: ","){
                            let coin = String(rawCoin)
                            if let range = coin.range(of: "[0-9]*", options: .regularExpression) {
                                let amount = String(coin[range])
                                let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                let denom = String(coin[denomIndex...])
                                result.append(Coin.init(denom, amount))
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    
    
    static func onParseStakeRewardGrpc(_ tx: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) -> Array<Coin> {
        var result = Array<Coin>()
        if (tx.txResponse.logs == nil || tx.txResponse.logs.count <= position || tx.txResponse.logs[position] == nil)  { return result }
        tx.txResponse.logs[position].events.forEach { (event) in
            if (event.type == "withdraw_rewards") {
                for i in 0...event.attributes.count - 1 {
                    if (event.attributes[i].key == "amount") {
                        let rawValue = event.attributes[i].value
                        for rawCoin in rawValue.split(separator: ","){
                            let coin = String(rawCoin)
                            if let range = coin.range(of: "[0-9]*", options: .regularExpression) {
                                let amount = String(coin[range])
                                let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                let denom = String(coin[denomIndex...])
                                result.append(Coin.init(denom, amount))
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    static func onParseCommisiondGrpc(_ tx: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) -> Array<Coin> {
        var result = Array<Coin>()
        if (tx.txResponse.logs == nil || tx.txResponse.logs.count <= position || tx.txResponse.logs[position] == nil)  { return result }
        tx.txResponse.logs[position].events.forEach { (event) in
            if (event.type == "withdraw_commission") {
                for i in 0...event.attributes.count - 1 {
                    if (event.attributes[i].key == "amount") {
                        let rawValue = event.attributes[i].value
                        for rawCoin in rawValue.split(separator: ","){
                            let coin = String(rawCoin)
                            if let range = coin.range(of: "[0-9]*", options: .regularExpression) {
                                let amount = String(coin[range])
                                let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                let denom = String(coin[denomIndex...])
                                result.append(Coin.init(denom, amount))
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    static func onParseKavaIncentiveGrpc(_ tx: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) -> Array<Coin> {
        var result = Array<Coin>()
        if (tx.txResponse.logs == nil || tx.txResponse.logs.count <= position || tx.txResponse.logs[position] == nil)  { return result }
        tx.txResponse.logs[position].events.forEach { (event) in
            if (event.type == "claim_reward") {
                for i in 0...event.attributes.count - 1 {
                    if (event.attributes[i].key == "claim_amount") {
                        let rawValue = event.attributes[i].value
                        for rawCoin in rawValue.split(separator: ","){
                            let coin = String(rawCoin)
                            if let range = coin.range(of: "[0-9]*", options: .regularExpression) {
                                let amount = String(coin[range])
                                let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                let denom = String(coin[denomIndex...])
                                result.append(Coin.init(denom, amount))
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    static func onParseBep3ClaimAmountGrpc(_ tx: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) -> Array<Coin> {
        var result = Array<Coin>()
        if (tx.txResponse.logs == nil || tx.txResponse.logs.count <= position || tx.txResponse.logs[position] == nil)  { return result }
        tx.txResponse.logs[position].events.forEach { (event) in
            if (event.type == "transfer") {
                for i in 0...event.attributes.count - 1 {
                    if (event.attributes[i].key == "amount") {
                        let rawValue = event.attributes[i].value
                        for rawCoin in rawValue.split(separator: ","){
                            let coin = String(rawCoin)
                            if let range = coin.range(of: "[0-9]*", options: .regularExpression) {
                                let amount = String(coin[range])
                                let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                let denom = String(coin[denomIndex...])
                                result.append(Coin.init(denom, amount))
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    static func onProposalProposer(_ proposal: MintscanProposalDetail?) -> String? {
        if (proposal?.moniker?.isEmpty == true) {
            return proposal?.proposer
        } else {
            return proposal?.moniker
        }
    }
    
    static func onProposalStatusTxt(_ proposal: MintscanProposalDetail?) -> String {
        if (proposal?.proposal_status?.localizedCaseInsensitiveContains("DEPOSIT") == true) {
            return "DepositPeriod"
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("VOTING") == true) {
            return "VotingPeriod"
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("PASSED") == true) {
            return "Passed"
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("REJECTED") == true) {
            return "Rejected"
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("FAILED") == true) {
            return "Failed"
        }
        return "unKnown"
    }
    
    static func onProposalStatusImg(_ proposal: MintscanProposalDetail?) -> UIImage? {
        if (proposal?.proposal_status?.localizedCaseInsensitiveContains("DEPOSIT") == true) {
            return UIImage.init(named: "ImgGovDoposit")
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("VOTING") == true) {
            return UIImage.init(named: "ImgGovVoting")
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("PASSED") == true) {
            return UIImage.init(named: "ImgGovPassed")
        } else if (proposal?.proposal_status?.localizedCaseInsensitiveContains("REJECTED") == true) {
            return UIImage.init(named: "ImgGovRejected")
        }
        return UIImage.init(named: "ImgGovFailed")
    }
    
    static func onParseProposalStartTime(_ proposal: Cosmos_Gov_V1beta1_Proposal) -> String {
        if (proposal.status == Cosmos_Gov_V1beta1_ProposalStatus.depositPeriod) {
            return "Waiting Deposit"
        } else {
            return longTimetoString(proposal.votingStartTime.seconds * 1000)
        }
    }
    
    static func onParseProposalEndTime(_ proposal: Cosmos_Gov_V1beta1_Proposal) -> String {
        if (proposal.status == Cosmos_Gov_V1beta1_ProposalStatus.depositPeriod) {
            return "Waiting Deposit"
        } else {
            return longTimetoString(proposal.votingEndTime.seconds * 1000)
        }
    }
    
    public static func isGRPC(_ chain: ChainType?) -> Bool {
        if (chain == ChainType.BINANCE_MAIN || chain == ChainType.OKEX_MAIN) {
            return false
        }
        return true
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
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else { return nil }
        return data
    }

    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
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


extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
            delays.append(Int(delaySeconds * 3000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 3000.0)
        
        return animation
    }
}


open class CustomSlider : UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }

    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}
