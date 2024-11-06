//
//  DP.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

public class WDP {
    
    static func dpCoin(_ msAsset: MintscanAsset, _ coin: Cosmos_Base_V1beta1_Coin?, _ coinImg: UIImageView?, _ denomLabel: UILabel?, _ amountLabel: UILabel?, _ showDecimal: Int16?) {
        if (coin == nil) {
            amountLabel?.attributedText = dpAmount("0", amountLabel!.font, showDecimal ?? msAsset.decimals)
            denomLabel?.text = msAsset.symbol
            coinImg?.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        } else {
            let amount = NSDecimalNumber(string: coin?.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            amountLabel?.attributedText = dpAmount(amount.stringValue, amountLabel!.font, showDecimal ?? msAsset.decimals)
            denomLabel?.text = msAsset.symbol
            coinImg?.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        }
    }
    
    static func dpCoin(_ msAsset: MintscanAsset, _ amount: NSDecimalNumber, _ coinImg: UIImageView?, _ denomLabel: UILabel?, _ amountLabel: UILabel?, _ showDecimal: Int16?) {
        
        let deAmount = amount.multiplying(byPowerOf10: -msAsset.decimals!)
        amountLabel?.attributedText = dpAmount(deAmount.stringValue, amountLabel!.font, showDecimal ?? msAsset.decimals)
        denomLabel?.text = msAsset.symbol
        coinImg?.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
    }
    
    static func dpToken(_ msToken: MintscanToken, _ coinImg: UIImageView?, _ denomLabel: UILabel?, _ amountLabel: UILabel?, _ showDecimal: Int16?) {
        dpToken(msToken, msToken.getAmount(), coinImg, denomLabel, amountLabel, showDecimal)
    }
    
    static func dpToken(_ msToken: MintscanToken, _ amount: NSDecimalNumber, _ coinImg: UIImageView?, _ denomLabel: UILabel?, _ amountLabel: UILabel?, _ showDecimal: Int16?) {
        let deAmount = amount.multiplying(byPowerOf10: -msToken.decimals!)
        amountLabel?.attributedText = dpAmount(deAmount.stringValue, amountLabel!.font, showDecimal ?? msToken.decimals)
        denomLabel?.text = msToken.symbol
        coinImg?.sd_setImage(with: msToken.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
    }
    
    static func dpAmount(_ amount: String?, _ font: UIFont, _ showDecimal: Int16? = 6) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US")
        nf.roundingMode = .floor
        nf.numberStyle = .decimal

        let deciaml = Int(showDecimal!)
        let number = NSDecimalNumber(string: amount)
        var formatted: String?
        if (number == NSDecimalNumber.zero) {
            nf.minimumSignificantDigits = deciaml + 1
            nf.maximumSignificantDigits = deciaml + 1
            formatted = nf.string(from: NSDecimalNumber.zero)

        } else {
            if (number.compare(NSDecimalNumber.one).rawValue < 0) {
                var temp = ""
                let decimal = Array(String(number.stringValue.split(separator: ".")[1]))
                for i in 0 ..< deciaml {
                    if (decimal.count > i) {
                        temp = temp.appending(String(decimal[i]))
                    } else {
                        temp = temp.appending("0")
                    }
                }
                formatted = "0" + nf.decimalSeparator! + temp

            } else {
                let count = number.multiplying(by: NSDecimalNumber.one, withBehavior: handler0Down).stringValue.count
                nf.minimumSignificantDigits = deciaml + count
                nf.maximumSignificantDigits = deciaml + count
                formatted = nf.string(from: number)
            }

        }

        let added       = formatted!
        let endIndex    = added.index(added.endIndex, offsetBy: -deciaml)

        let preString   = added[..<endIndex]
        let postString  = added[endIndex...]

        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]

        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])

        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    static func dpValue(_ value: NSDecimalNumber, _ currencyLabel: UILabel?, _ priceLabel: UILabel?) {
        let nf = WUtils.getNumberFormatter(3)
        let formatted = nf.string(from: value)!
        currencyLabel?.text = BaseData.instance.getCurrencySymbol()
        priceLabel?.attributedText = WUtils.getDpAttributedString(formatted, 3, priceLabel?.font)
    }
    
    static func dpUSDValue(_ value: NSDecimalNumber, _ currencyLabel: UILabel?, _ priceLabel: UILabel?) {
        let nf = WUtils.getNumberFormatter(3)
        let formatted = nf.string(from: value)!
        currencyLabel?.text = "$"
        priceLabel?.attributedText = WUtils.getDpAttributedString(formatted, 3, priceLabel?.font)
    }
    
    static func dpPrice(_ msAsset: MintscanAsset, _ currencyLabel: UILabel?, _ priceLabel: UILabel?) {
        dpPrice(msAsset.coinGeckoId, currencyLabel, priceLabel)
    }
    
    static func dpPrice(_ coinGeckoId: String?, _ currencyLabel: UILabel?, _ priceLabel: UILabel?) {
        let msPrice = BaseData.instance.getPrice(coinGeckoId)
        let nf = WUtils.getNumberFormatter(3)
        let formatted = nf.string(from: msPrice)!
        currencyLabel?.text = BaseData.instance.getCurrencySymbol()
        priceLabel?.attributedText = WUtils.getDpAttributedString(formatted, 3, priceLabel?.font)
    }
    
    static func dpPriceChanged(_ msAsset: MintscanAsset, _ valueLabel: UILabel?, _ percentLabel: UILabel?) {
        dpPriceChanged(msAsset.coinGeckoId, valueLabel, percentLabel)
    }
    
    static func dpPriceChanged(_ coinGeckoId: String?, _ valueLabel: UILabel?, _ percentLabel: UILabel?) {
        let priceChanged = BaseData.instance.priceChange(coinGeckoId)
        let nf = WUtils.getNumberFormatter(2)
        percentLabel?.text = "%"
        if (priceChanged.compare(NSDecimalNumber.zero).rawValue >= 0) {
            let formatted = nf.string(from: priceChanged)!
            valueLabel?.attributedText = WUtils.getDpAttributedString("+"+formatted, 2, valueLabel?.font)
            dpPriceUpColor(valueLabel)
            dpPriceUpColor(percentLabel)
        } else {
            let formatted = nf.string(from: priceChanged)!
            valueLabel?.attributedText = WUtils.getDpAttributedString(formatted, 2, valueLabel?.font)
            dpPriceDownColor(valueLabel)
            dpPriceDownColor(percentLabel)
        }
    }
    
    static func dpPriceUpColor(_ label: UILabel?) {
        if (BaseData.instance.getPriceChaingColor() > 0) {
            label?.textColor = .colorRed
        } else {
            label?.textColor = .colorGreen
        }
    }

    static func dpPriceDownColor(_ label: UILabel?) {
        if (BaseData.instance.getPriceChaingColor() > 0) {
            label?.textColor = .colorGreen
        } else {
            label?.textColor = .colorRed
        }
    }
    

    /*
     * Display Times
     */
    static func toDate(_ timeString: String?) -> Date? {
        if (timeString == nil) { return nil }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return nil
        }
        return date
    }
    
    
    static func dpDate(_ timeString: String?) -> String {
        if (timeString == nil) { return "-" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        return localFormatter.string(from: date)
    }
    
    static func dpDate(_ milliseconds: Int) -> String {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        return localFormatter.string(from: Date(milliseconds: milliseconds))
    }
    
    static func dpTime(_ timeString: String?) -> String {
        if (timeString == nil) { return "-" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("HH:mm:ss", comment: "")
        return localFormatter.string(from: date)
    }
    
    static func dpTime(_ milliseconds: Int) -> String {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("HH:mm:ss", comment: "")
        return localFormatter.string(from: Date(milliseconds: milliseconds))
    }
    
    static func dpFullTime(_ timeString: String?) -> String {
        if (timeString == nil) { return "-" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("full_time_format", comment: "")
        return localFormatter.string(from: date)
    }

    static func dpFullTime(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "-" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("full_time_format", comment: "")
        return localFormatter.string(from: date)
    }

    static func dpTimeGap(_ timeString: String?, _ bracket: Bool = true) -> String {
        if (timeString == nil) { return "" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return ""
        }
        if (bracket) {
            return "(" + WUtils.getGapTime(date) + ")"
        }
        return WUtils.getGapTime(date)
    }

    static func dpTimeGap(_ timeInt: Int64?, _ bracket: Bool = true) -> String {
        if (timeInt == nil) { return "" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
            return ""
        }
        if (bracket) {
            return "(" + WUtils.getGapTime(date) + ")"
        }
        return WUtils.getGapTime(date)
    }

    static func okcDpTime(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "-" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("full_time_format", comment: "")
        return localFormatter.string(from: date)
    }

    static func okcDpTimeGap(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
            return ""
        }
        return WUtils.getGapTime(date)
    }
    
    static func protoDpTime(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "-" }
        guard let date = WUtils.timeInt64ToDate(timeInt! * 1000) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("full_time_format", comment: "")
        return localFormatter.string(from: date)
    }

    static func protoDpTimeGap(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "" }
        guard let date = WUtils.timeInt64ToDate(timeInt! * 1000) else {
            return ""
        }
        return WUtils.getGapTime(date)
    }
    
}
