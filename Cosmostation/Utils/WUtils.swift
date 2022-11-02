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
                return "(\(gapTime) seconds ago)"
            } else if gapTime < hour {
                return "(\(gapTime / minute) minutes ago)"
            } else if gapTime < day {
                return "(\(gapTime / hour) hours ago)"
            } else {
                return "(\(gapTime / day) days ago)"
            }
            
        } else {
            gapTime = gapTime * -1
            if gapTime < day {
                return "(D-day)"
            } else {
                return "(D-\(gapTime / day))"
            }
        }
    }
    
    static func unbondingDateFromNow(_ date: UInt16) -> String {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        
        let afterDate = Calendar.current.date(
            byAdding: .day,
            value: Int(+date),
            to: Date())
        return localFormatter.string(from: afterDate!)
    }
    
    static func decimalNumberToLocaleString(_ input: NSDecimalNumber, _ deciaml: Int16) -> String {
        let nf = NumberFormatter()
        nf.roundingMode = .floor
        nf.numberStyle = .decimal
        nf.groupingSeparator = ""
        
        var formatted: String?
        if (input == NSDecimalNumber.zero) {
            nf.minimumSignificantDigits = Int(deciaml) + 1
            nf.maximumSignificantDigits = Int(deciaml) + 1
            formatted = nf.string(from: NSDecimalNumber.zero)
            
        } else {
            if (input.compare(NSDecimalNumber.one).rawValue < 0) {
                var temp = ""
                let decimal = Array(String(input.stringValue.split(separator: ".")[1]))
                for i in 0 ..< Int(deciaml) {
                    if (decimal.count > i) {
                        temp = temp.appending(String(decimal[i]))
                    } else {
                        temp = temp.appending("0")
                    }
                }
                formatted = "0" + nf.decimalSeparator! + temp
                
            } else {
                let count = input.multiplying(by: NSDecimalNumber.one, withBehavior: WUtils.handler0).stringValue.count
                nf.minimumSignificantDigits = Int(deciaml) + count
                nf.maximumSignificantDigits = Int(deciaml) + count
                formatted = nf.string(from: input)
            }
        }
        return formatted ?? "0"
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
    
    static func getFormattedNumber(_ amount: NSDecimalNumber, _ dpPoint:Int16) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = Int(dpPoint)
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal
        
        let formatted = nf.string(from: amount)?.replacingOccurrences(of: ",", with: "" )
        return formatted!
    }
    
    static func tokenCnt(_ chainType: ChainType?) -> String {
        if (isGRPC(chainType)) {
            return String(BaseData.instance.mMyBalances_gRPC.count)
        } else {
            return String(BaseData.instance.mBalances.count)
        }
    }
    
    static func priceChange(_ denom: String) -> NSDecimalNumber {
        guard let coinPrice = BaseData.instance.getPrice(denom) else {
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler2Down)
        }
        return NSDecimalNumber.init(value: coinPrice.daily_price_change_in_percent ?? 0).rounding(accordingToBehavior: handler2Down)
    }
    
    static func dpPriceChange(_ denom: String, _ font:UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(2)
        let change = priceChange(denom)
        if (change.compare(NSDecimalNumber.zero).rawValue >= 0) {
            let formatted = "+" + nf.string(from: change)! + "%"
            return getDpAttributedString(formatted, 3, font)
        } else {
            let formatted = nf.string(from: change)! + "%"
            return getDpAttributedString(formatted, 3, font)
        }
    }
    
    static func price(_ denom: String) -> NSDecimalNumber {
        guard let coinPrice = BaseData.instance.getPrice(denom) else {
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler12Down)
        }
        return NSDecimalNumber.init(value: coinPrice.current_price ?? 0).rounding(accordingToBehavior: handler12Down)
    }
    
    static func dpPrice(_ denom: String, _ font:UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: price(denom))!
        return getDpAttributedString(formatted, 3, font)
    }
    
    static func assetValue(_ denom: String, _ amount: NSDecimalNumber, _ divider: Int16) -> NSDecimalNumber {
        return price(denom).multiplying(by: amount).multiplying(byPowerOf10: -divider, withBehavior: handler3Down)
    }
    
    static func dpAssetValue(_ denom: String, _ amount: NSDecimalNumber, _ divider: Int16, _ font: UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: assetValue(denom, amount, divider))!
        return getDpAttributedString(formatted, 3, font)
    }
    
    
    //TODO using to display TVL with USD, need to update
    static func perUsdValue(_ denom: String) -> NSDecimalNumber? {
//        if (denom == EMONEY_EUR_DENOM || denom == EMONEY_CHF_DENOM || denom == EMONEY_DKK_DENOM || denom == EMONEY_NOK_DENOM || denom == EMONEY_SEK_DENOM) {
//            if let value = BaseData.instance.getPrice("usdt")?.prices.filter{ $0.currency == denom.substring(from: 1) }.first?.current_price {
//                return NSDecimalNumber.one.dividing(by: NSDecimalNumber.init(value: value), withBehavior: handler18)
//            }
//        }
//        if let coinPrice = BaseData.instance.getPrice(denom) {
//            return coinPrice.currencyPrice("usd").rounding(accordingToBehavior: handler18)
//        }
//        return nil
        return NSDecimalNumber.zero
    }
    
    static func usdValue(_ chainConfig: ChainConfig, _ denom: String, _ amount: NSDecimalNumber) -> NSDecimalNumber {
//        let baseDenom = BaseData.instance.getBaseDenom(chainConfig, denom)
//        let decimalDenom = getDenomDecimal(chainConfig, denom)
//        if let perUsdValue = perUsdValue(baseDenom) {
//            return perUsdValue.multiplying(by: amount).multiplying(byPowerOf10: -decimalDenom, withBehavior: handler3Down)
//        }
        return NSDecimalNumber.zero
    }
    
    static func allAssetValue(_ chainConfig: ChainConfig?) -> NSDecimalNumber {
        let baseData = BaseData.instance
        var totalValue = NSDecimalNumber.zero
        if (chainConfig?.isGrpc == true) {
            baseData.mMyBalances_gRPC.forEach { coin in
                if (coin.denom == getMainDenom(chainConfig)) {
                    let amount = getAllMainAsset(coin.denom)
                    let assetValue = assetValue(coin.denom, amount, chainConfig!.divideDecimal)
                    totalValue = totalValue.adding(assetValue)
                    
                } else if (chainConfig?.chainType == .KAVA_MAIN) {
                    if let msAsset = BaseData.instance.getMSAsset(chainConfig!, coin.denom) {
                        let amount = WUtils.getKavaTokenAll(coin.denom)
                        let assetValue = assetValue(msAsset.base_denom, amount, msAsset.decimal)
                        totalValue = totalValue.adding(assetValue)
                    }
                    
                } else {
                    if let msAsset = BaseData.instance.getMSAsset(chainConfig!, coin.denom) {
                        let amount = baseData.getAvailableAmount_gRPC(coin.denom)
                        let priceDenom = msAsset.priceDenom()
                        let assetValue = assetValue(priceDenom, amount, msAsset.decimal)
                        totalValue = totalValue.adding(assetValue)
                    }
                }
            }
        }
        
        //cal for legacy chains
        else if (chainConfig?.chainType == .BINANCE_MAIN) {
            baseData.mBalances.forEach { coin in
                var allBnb = NSDecimalNumber.zero
                let amount = BaseData.instance.allBnbTokenAmount(coin.balance_denom)
                if (coin.balance_denom == getMainDenom(chainConfig)) {
                    allBnb = allBnb.adding(amount)
                } else {
                    allBnb = allBnb.adding(bnbConvertAmount(coin.balance_denom))
                }
                let assetValue = assetValue(getMainDenom(chainConfig), allBnb, 0)
                totalValue = totalValue.adding(assetValue)
            }
            
        } else if (chainConfig?.chainType == .OKEX_MAIN) {
            baseData.mBalances.forEach { coin in
                var allOKT = NSDecimalNumber.zero
                if (coin.balance_denom == getMainDenom(chainConfig)) {
                    allOKT = allOKT.adding(getAllExToken(coin.balance_denom))
                } else {
                    allOKT = allOKT.adding(convertTokenToOkt(coin.balance_denom))
                }
                let assetValue = assetValue(getMainDenom(chainConfig), allOKT, 0)
                totalValue = totalValue.adding(assetValue)
            }
            
        }
        
        //Add contract token value
        if (chainConfig?.wasmSupport == true || chainConfig?.evmSupport == true) {
            BaseData.instance.mMyTokens.forEach { msToken in
                let amount = NSDecimalNumber.init(string: msToken.amount)
                let assetValue = assetValue(msToken.denom, amount, msToken.decimal)
                totalValue = totalValue.adding(assetValue)
            }
        }
        return totalValue
    }
    
    static func dpAllAssetValue(_ chainConfig: ChainConfig?, _ font:UIFont) -> NSMutableAttributedString {
        let totalValue = allAssetValue(chainConfig)
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
    
    static func getDpAttributedString(_ dpString: String, _ divider: Int, _ font:UIFont) -> NSMutableAttributedString {
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
    
    static func getDailyReward(_ font: UIFont, _ commission: NSDecimalNumber, _ delegated: NSDecimalNumber?, _ chainConfig: ChainConfig) -> NSMutableAttributedString {
        guard let param = BaseData.instance.mParam, let bondingAmount = delegated else {
            return WDP.dpAmount(NSDecimalNumber.zero.stringValue, font, chainConfig.divideDecimal, chainConfig.displayDecimal)
        }
        var apr = NSDecimalNumber.zero
        if (param.getRealApr(chainConfig.chainType) == NSDecimalNumber.zero) { apr = param.getApr(chainConfig.chainType) }
        else { apr = param.getRealApr(chainConfig.chainType) }
        let calCommission = NSDecimalNumber.one.subtracting(commission)
        let aprCommission = apr.multiplying(by: calCommission, withBehavior: handler6)
        let dayReward = bondingAmount.multiplying(by: aprCommission).dividing(by: NSDecimalNumber.init(string: "365"), withBehavior: WUtils.handler0)
        return WDP.dpAmount(dayReward.stringValue, font, chainConfig.divideDecimal, chainConfig.displayDecimal)
    }
    
    static func getMonthlyReward(_ font: UIFont, _ commission: NSDecimalNumber, _ delegated: NSDecimalNumber?, _ chainConfig: ChainConfig) -> NSMutableAttributedString {
        guard let param = BaseData.instance.mParam, let bondingAmount = delegated else {
            return WDP.dpAmount(NSDecimalNumber.zero.stringValue, font, chainConfig.divideDecimal, chainConfig.displayDecimal)
        }
        var apr = NSDecimalNumber.zero
        if (param.getRealApr(chainConfig.chainType) == NSDecimalNumber.zero) { apr = param.getApr(chainConfig.chainType) }
        else { apr = param.getRealApr(chainConfig.chainType) }
        let calCommission = NSDecimalNumber.one.subtracting(commission)
        let aprCommission = apr.multiplying(by: calCommission, withBehavior: handler6)
        let dayReward = bondingAmount.multiplying(by: aprCommission).dividing(by: NSDecimalNumber.init(string: "12"), withBehavior: WUtils.handler0)
        return WDP.dpAmount(dayReward.stringValue, font, chainConfig.divideDecimal, chainConfig.displayDecimal)
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
    
    //for binance utils
    static func bnbConvertAmount(_ symbol: String) -> NSDecimalNumber {
        if let bnbTicker = BaseData.instance.bnbTicker(symbol) {
            let amount = BaseData.instance.allBnbTokenAmount(symbol)
            if (bnbTicker.baseAssetName == BNB_MAIN_DENOM) {
                return amount.dividing(by: bnbTicker.getLastPrice(), withBehavior: WUtils.handler8)
            } else {
                return amount.multiplying(by: bnbTicker.getLastPrice(), withBehavior: WUtils.handler8)
            }
        }
        return NSDecimalNumber.zero
    }
    
    static func bnbTokenPrice(_ symbol: String) -> NSDecimalNumber {
        if let bnbTicker = BaseData.instance.bnbTicker(symbol) {
            if (bnbTicker.baseAssetName == BNB_MAIN_DENOM) {
                let perPrice = (NSDecimalNumber.one).dividing(by: bnbTicker.getLastPrice(), withBehavior: WUtils.handler8)
                return perPrice.multiplying(by: price(BNB_MAIN_DENOM))
            } else {
                let perPrice = (NSDecimalNumber.one).multiplying(by: bnbTicker.getLastPrice(), withBehavior: WUtils.handler8)
                return perPrice.multiplying(by: price(BNB_MAIN_DENOM))
            }
        }
        return NSDecimalNumber.zero
    }
    
    static func dpBnbTokenPrice(_ symbol: String, _ font:UIFont) -> NSMutableAttributedString {
        let nf = getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: bnbTokenPrice(symbol))!
        return getDpAttributedString(formatted, 3, font)
    }
    
    static func showBNBTxDp(_ coin:Coin, _ denomLabel:UILabel, _ amountLabel:UILabel, _ chainType:ChainType) {
        if (coin.denom == BNB_MAIN_DENOM) {
            WUtils.setDenomTitle(chainType, denomLabel)
        } else {
            denomLabel.textColor = UIColor.font05
            denomLabel.text = coin.denom.uppercased()
        }
        amountLabel.attributedText = WDP.dpAmount(coin.amount, amountLabel.font, 8, 8)
    }
    
    //for okx utils
    static func getAllExToken(_ symbol: String) -> NSDecimalNumber {
        let dataBase = BaseData.instance
        if (symbol == OKEX_MAIN_DENOM) {
            return dataBase.availableAmount(symbol).adding(dataBase.lockedAmount(symbol)).adding(dataBase.okDepositAmount()).adding(dataBase.okWithdrawAmount())
        } else {
            return dataBase.availableAmount(symbol).adding(dataBase.lockedAmount(symbol))
        }
    }
    
    static func getOkexTokenDollorValue(_ okToken: OkToken?, _ amount: NSDecimalNumber) -> NSDecimalNumber {
        if (okToken == nil) { return NSDecimalNumber.zero }
        if (okToken!.original_symbol == "usdt" || okToken!.original_symbol == "usdc" || okToken!.original_symbol == "usdk") {
            return amount
            
        } else if (okToken!.original_symbol == "okb") {
            return amount.multiplying(by: BaseData.instance.mOKBPrice)
            
        } else if (BaseData.instance.mOkTickerList != nil) {
            //TODO display with ticker update!
            return NSDecimalNumber.zero
        }
        return NSDecimalNumber.zero
    }
    
    //disable okc old type tokens(KIP10) value
    static func convertTokenToOkt(_ denom: String) -> NSDecimalNumber {
//        let baseData = BaseData.instance
//        let okToken = getOkToken(denom)
//        let tokenAmount = baseData.availableAmount(denom).adding(baseData.lockedAmount(denom))
//        let totalTokenValue = getOkexTokenDollorValue(okToken, tokenAmount)
//        if let okTUsd = perUsdValue(OKEX_MAIN_DENOM) {
//            return totalTokenValue.dividing(by: okTUsd, withBehavior: handler18)
//        }
        return NSDecimalNumber.zero
    }
    
    static func getOkToken(_ symbol:String?) -> OkToken? {
        return BaseData.instance.mOkTokenList?.data?.filter { $0.symbol == symbol}.first
    }
    
    static func getTokenAmount(_ balances: Array<Balance>?, _ symbol:String) -> NSDecimalNumber {
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
    
    static func getMainDenom(_ chainConfig: ChainConfig?) -> String {
        return chainConfig?.stakeDenom ?? ""
    }
    
    static func getDenomDecimal(_ chainConfig: ChainConfig?, _ denom: String?) -> Int16 {
        if (chainConfig == nil || denom == nil) { return 6 }
        if (chainConfig!.isGrpc) {
            if let msAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == denom?.lowercased() }).first {
                return msAsset.decimal
            } else if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.denom.lowercased() == denom?.lowercased() }).first {
                return msToken.decimal
            }
        }
        return chainConfig!.divideDecimal
    }
    
    static func setDenomTitle(_ chain: ChainType?, _ label: UILabel?) {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            label?.text = chainConfig.stakeSymbol
            label?.textColor = chainConfig.chainColor
        }
    }
    
    static func getChainDBName(_ chain:ChainType?) -> String {
        guard let chainConfig = ChainFactory.getChainConfig(chain) else {
            return ""
        }
        return chainConfig.chainDBName
    }
    
    static func getMintscanPath(_ fromChain: ChainConfig, _ toChain: ChainConfig, _ denom: String) -> MintscanPath? {
        let msAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == denom.lowercased() }).first
        let msTokens = BaseData.instance.mMintscanTokens.filter({ $0.denom.lowercased() == denom.lowercased() }).first
        var result: MintscanPath?
        BaseData.instance.mMintscanAssets.forEach { asset in
            if (msAsset != nil) {
                if (asset.chain == fromChain.chainAPIName &&
                    asset.beforeChain(fromChain) == toChain.chainAPIName &&
                    asset.denom.lowercased() == denom.lowercased()) {
                    result = MintscanPath.init(asset.channel, asset.port)
                    return
                }
                if (asset.chain == toChain.chainAPIName &&
                    asset.beforeChain(toChain) == fromChain.chainAPIName &&
                    asset.counter_party?.denom?.lowercased() == denom.lowercased()) {
                    result = MintscanPath.init(asset.counter_party!.channel!, asset.counter_party!.port!)
                    return
                }
                
            } else if (msTokens != nil) {
                if (asset.chain == toChain.chainAPIName &&
                    asset.beforeChain(toChain) == fromChain.chainAPIName &&
                    asset.counter_party?.denom?.lowercased() == msTokens?.contract_address.lowercased()) {
                    result = MintscanPath.init(asset.counter_party!.channel!, asset.counter_party!.port!)
                    return
                }
            }
        }
        return result
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
            result[0].title = NSLocalizedString("str_fixed", comment: "")
            result[0].msg = NSLocalizedString("fee_speed_title_fixed", comment: "")
        } else if (result.count == 2) {
            result[1].title = NSLocalizedString("str_average", comment: "")
            result[1].msg = NSLocalizedString("fee_speed_title_average", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_tiny", comment: "")
            }
        } else if (result.count == 3) {
            result[2].title = NSLocalizedString("str_average", comment: "")
            result[2].msg = NSLocalizedString("fee_speed_title_average", comment: "")
            result[1].title = NSLocalizedString("str_low", comment: "")
            result[1].msg = NSLocalizedString("fee_speed_title_low", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_tiny", comment: "")
            }
        }
        return result
    }
    
    static func getSymbol(_ chainConfig: ChainConfig?, _ denom: String?) -> String {
        if (chainConfig == nil || denom == nil || denom?.isEmpty == true) { return "Unknown" }
        if (chainConfig!.stakeDenom == denom) {
            return chainConfig!.stakeSymbol
        }
        if (chainConfig?.isGrpc == true) {
            if let msAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == denom?.lowercased() }).first {
                return msAsset.dp_denom
            } else if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.denom.lowercased() == denom?.lowercased() }).first {
                return msToken.denom.uppercased()
            }
            
        } else {
            if (chainConfig!.chainType == .BINANCE_MAIN) {
                if let bnbTokenInfo = BaseData.instance.bnbToken(denom) {
                    return bnbTokenInfo.original_symbol.uppercased()
                }
                
            } else if (chainConfig!.chainType == .OKEX_MAIN) {
                if let okTokenInfo = getOkToken(denom!) {
                    return okTokenInfo.original_symbol!.uppercased()
                }
            }
        }
        return "Unknown"
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
    
    static func getRealBlockTime(_ chain: ChainType?) -> NSDecimalNumber {
        if (chain == .COSMOS_MAIN || chain == .COSMOS_TEST) {
            return BLOCK_TIME_COSMOS
            
        } else if (chain == .IRIS_MAIN || chain == .IRIS_TEST) {
            return BLOCK_TIME_IRIS
            
        } else if (chain == .IOV_MAIN) {
            return BLOCK_TIME_IOV
            
        } else if (chain == .KAVA_MAIN) {
            return BLOCK_TIME_KAVA
            
        } else if (chain == .BAND_MAIN) {
            return BLOCK_TIME_BAND
            
        } else if (chain == .CERTIK_MAIN) {
            return BLOCK_TIME_CERTIK
            
        } else if (chain == .SECRET_MAIN) {
            return BLOCK_TIME_SECRET
            
        } else if (chain == .AKASH_MAIN) {
            return BLOCK_TIME_AKASH
            
        } else if (chain == .SENTINEL_MAIN) {
            return BLOCK_TIME_SENTINEL
            
        } else if (chain == .PERSIS_MAIN) {
            return BLOCK_TIME_PERSISTENCE
            
        } else if (chain == .FETCH_MAIN) {
            return BLOCK_TIME_FETCH
            
        } else if (chain == .CRYPTO_MAIN) {
            return BLOCK_TIME_CRYPTO
            
        } else if (chain == .SIF_MAIN) {
            return BLOCK_TIME_SIF
            
        } else if (chain == .KI_MAIN) {
            return BLOCK_TIME_KI
            
        } else if (chain == .MEDI_MAIN) {
            return BLOCK_TIME_MEDI
            
        } else if (chain == .OSMOSIS_MAIN) {
            return BLOCK_TIME_OSMOSIS
            
        } else if (chain == .EMONEY_MAIN) {
            return BLOCK_TIME_EMONEY
            
        } else if (chain == .EMONEY_MAIN) {
            return BLOCK_TIME_EMONEY
            
        } else if (chain == .RIZON_MAIN) {
            return BLOCK_TIME_RIZON
            
        } else if (chain == .JUNO_MAIN) {
            return BLOCK_TIME_JUNO
            
        } else if (chain == .BITCANA_MAIN) {
            return BLOCK_TIME_BITCANNA
            
        } else if (chain == .REGEN_MAIN) {
            return BLOCK_TIME_REGEN
            
        } else if (chain == .STARGAZE_MAIN) {
            return BLOCK_TIME_STARGAZE
            
        } else if (chain == .INJECTIVE_MAIN) {
            return BLOCK_TIME_INJECTIVE
            
        } else if (chain == .BITSONG_MAIN) {
            return BLOCK_TIME_BITSONG
            
        } else if (chain == .DESMOS_MAIN) {
            return BLOCK_TIME_DESMOS
            
        } else if (chain == .COMDEX_MAIN) {
            return BLOCK_TIME_COMDEX
            
        } else if (chain == .GRAVITY_BRIDGE_MAIN) {
            return BLOCK_TIME_GRAV
            
        } else if (chain == .LUM_MAIN) {
            return BLOCK_TIME_LUM
            
        } else if (chain == .CHIHUAHUA_MAIN) {
            return BLOCK_TIME_CHIHUAHUA
            
        } else if (chain == .AXELAR_MAIN) {
            return BLOCK_TIME_AXELAR
            
        } else if (chain == .KONSTELLATION_MAIN) {
            return BLOCK_TIME_KONSTEALLTION
            
        } else if (chain == .UMEE_MAIN) {
            return BLOCK_TIME_UMEE
            
        } else if (chain == .EVMOS_MAIN) {
            return BLOCK_TIME_EVMOS
            
        } else if (chain == .PROVENANCE_MAIN) {
            return BLOCK_TIME_PROVENANCE
            
        } else if (chain == .CERBERUS_MAIN) {
            return BLOCK_TIME_CERBERUS
            
        } else if (chain == .OMNIFLIX_MAIN) {
            return BLOCK_TIME_OMNIFLIX
            
        } else if (chain == .PASSAGE_MAIN) {
            return BLOCK_TIME_PASSAGE
            
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
    
    static func getChainTypeByChainId(_ chainId: String?) -> ChainType? {
        let allConfigs = ChainFactory.SUPPRT_CONFIG()
        for i in 0..<allConfigs.count {
            if (chainId?.contains(allConfigs[i].chainIdPrefix) == true) {
                return allConfigs[i].chainType
            }
        }
        return nil
    }
    
    static func isValidChainAddress(_ chainConfig: ChainConfig?, _ address: String?) -> Bool {
        if (chainConfig == nil) { return false }
        if (address?.starts(with: "0x") == true) {
            if (WKey.isValidEthAddress(address!) && chainConfig?.chainType == .OKEX_MAIN) { return true }
            return false
        }
        if (!WKey.isValidateBech32(address ?? "")) { return false }
        let addressPrfix = chainConfig!.addressPrefix + "1"
        if (address?.starts(with: addressPrfix) == true) { return true }
        return false
    }
    
    static func getChainsFromAddress(_ address: String?) -> ChainType? {
        if (address?.starts(with: "0x") == true) {
            if (WKey.isValidEthAddress(address!)) { return .OKEX_MAIN }
            return nil
        }
        if (!WKey.isValidateBech32(address ?? "")) { return nil }
        let allConfigs = ChainFactory.SUPPRT_CONFIG()
        for i in 0..<allConfigs.count {
            let addressPrfix = allConfigs[i].addressPrefix + "1"
            if (address?.starts(with: addressPrfix) == true) {
                return allConfigs[i].chainType
            }
        }
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
        if (chain == .DESMOS_MAIN && rawAccount.typeURL.contains(Desmos_Profiles_V1beta1_Profile.protoMessageName)) {
            if let profileAccount = try? Desmos_Profiles_V1beta1_Profile.init(serializedData: rawAccount.value) {
                onParseVestingAccount(chain, profileAccount.account)
            } else {
                onParseVestingAccount(chain, rawAccount)
            }
            
        } else if (chain == .INJECTIVE_MAIN && rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)) {
//            print("rawAccount.typeURL ", rawAccount.typeURL)
//            if let ethAccount = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
//                onParseVestingAccount(chain, ethAccount.baseAccount)
//            } else {
//                onParseVestingAccount(chain, rawAccount)
//            }
            onParseVestingAccount(chain, rawAccount)
            
        } else if (chain == .EVMOS_MAIN && rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)) {
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
        if position < periods.count {
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
    
    static func onParseFeeGrpc(_ chainConfig: ChainConfig, _ tx: Cosmos_Tx_V1beta1_GetTxResponse) -> Coin {
        if (tx.tx.authInfo.fee.amount.count > 0) {
            return Coin.init(tx.tx.authInfo.fee.amount[0].denom, tx.tx.authInfo.fee.amount[0].amount)
        } else {
            return Coin.init(getMainDenom(chainConfig), "0")
        }
    }
    
    
    static func onParseAutoRewardGrpc(_ tx: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) -> Array<Coin> {
        var result = Array<Coin>()
        if (tx.txResponse.logs.count <= position) {
            return result
        }
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
        if (tx.txResponse.logs.count <= position) {
            return result
        }
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
        if (tx.txResponse.logs.count <= position) {
            return result
        }
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
        if (tx.txResponse.logs.count <= position) {
            return result
        }
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
        if (tx.txResponse.logs.count <= position) {
            return result
        }
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
    
    public static func isGRPC(_ chain: ChainType?) -> Bool {
        if (chain == .BINANCE_MAIN || chain == .OKEX_MAIN) {
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


extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL: URL = URL(string: gifUrl) else {
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
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
