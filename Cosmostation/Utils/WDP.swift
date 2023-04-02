//
//  DP.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import UIKit

public class WDP {
    static func dpMainSymbol(_ chainConfig: ChainConfig?, _ label: UILabel?) {
        label?.text = chainConfig?.stakeSymbol
        label?.textColor = chainConfig?.chainColor
    }
    
    static func dpSymbol(_ chainConfig: ChainConfig?, _ denom: String?, _ denomLabel: UILabel?) {
        denomLabel?.text = WUtils.getSymbol(chainConfig, denom)
        if (chainConfig?.stakeDenom == denom) {
            denomLabel?.textColor = chainConfig?.chainColor
            return
        }
        if (chainConfig?.chainType == .KAVA_MAIN) {
            if (denom == KAVA_HARD_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "kava_hard")
                return
            } else if (denom == KAVA_USDX_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "kava_usdx")
                return
            } else if (denom == KAVA_SWAP_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "kava_swp")
                return
            }

        } else if (chainConfig?.chainType == .OSMOSIS_MAIN) {
            if (denom == OSMOSIS_ION_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "osmosis_ion")
                return
            }

        } else if (chainConfig?.chainType == .CRESCENT_MAIN) {
            if (denom == CRESCENT_BCRE_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "crescent_bcre")
                return
            }

        } else if (chainConfig?.chainType == .NYX_MAIN) {
            if (denom == NYX_NYM_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "nyx_nym")
                return
            }
        }
        denomLabel?.textColor = UIColor.font05
    }
    
    static func dpSymbolImg(_ chainConfig: ChainConfig?, _ denom: String?, _ imgView: UIImageView?) {
        if (chainConfig == nil || denom?.isEmpty == true) {
            imgView?.image = UIImage(named: "tokenDefault")
            return
        }
        if (chainConfig?.stakeDenom == denom) {
            imgView?.image = chainConfig?.stakeDenomImg
            return
        }
        if chainConfig?.isGrpc == true {
            if let msAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == denom?.lowercased() }).first {
                if let assetImgeUrl = msAsset.assetImg() {
                    imgView?.af_setImage(withURL: assetImgeUrl)
                    return
                }
            }
            
        } else {
            if (chainConfig?.chainType == .BINANCE_MAIN) {
                if let bnbTokenInfo = BaseData.instance.bnbToken(denom) {
                    imgView?.af_setImage(withURL: bnbTokenInfo.assetImg())
                }

            } else if (chainConfig?.chainType == .OKEX_MAIN) {
                if let okTokenInfo = BaseData.instance.okToken(denom) {
                    imgView?.af_setImage(withURL: okTokenInfo.assetImg())
                }
            }
        }
        imgView?.image = UIImage(named: "tokenDefault")!
    }
    
    static func dpCoin(_ chainConfig: ChainConfig?, _ coin: Coin?, _ denomLabel: UILabel?, _ amountLabel: UILabel?) {
        return dpCoin(chainConfig, coin?.denom, coin?.amount, denomLabel, amountLabel)
    }
    
    static func dpCoin(_ chainConfig: ChainConfig?, _ denom: String?, _ amount: String?, _ denomLabel: UILabel?, _ amountLabel: UILabel?) {
        if (chainConfig == nil || denom == nil || amount == nil || amountLabel == nil) { return }
        dpSymbol(chainConfig, denom, denomLabel)
        if (chainConfig?.isGrpc == true) {
            if let msAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == denom }).first {
                amountLabel!.attributedText = dpAmount(amount, amountLabel!.font, msAsset.decimals, msAsset.decimals)
            }
            else if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.address == denom }).first {
                amountLabel!.attributedText = dpAmount(amount, amountLabel!.font, msToken.decimals, msToken.decimals)
            }
            else {
                amountLabel!.attributedText = dpAmount(amount, amountLabel!.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
            }
            
        } else {
            if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.address == denom }).first {
                amountLabel!.attributedText = dpAmount(amount, amountLabel!.font, msToken.decimals, msToken.decimals)
            } else {
                if (chainConfig?.chainType == .BINANCE_MAIN) {
                    amountLabel!.attributedText = dpAmount(amount, amountLabel!.font, 0, 8)
                } else if (chainConfig?.chainType == .OKEX_MAIN ) {
                    amountLabel!.attributedText = dpAmount(amount, amountLabel!.font, 0, 18)
                }
            }
        }
    }
    
    static func dpBnbTxCoin(_ chainConfig: ChainConfig, _ coin:Coin, _ denomLabel: UILabel, _ amountLabel: UILabel) {
        if (coin.denom == BNB_MAIN_DENOM) {
            WDP.dpMainSymbol(chainConfig, denomLabel)
        } else {
            denomLabel.textColor = UIColor.font05
            denomLabel.text = coin.denom.uppercased()
        }
        amountLabel.attributedText = dpAmount(coin.amount, amountLabel.font, 8, 8)
    }
    
    static func dpAmount(_ amount: String?, _ font: UIFont, _ inputPoint: Int16, _ dpPoint: Int16) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.roundingMode = .floor
        nf.numberStyle = .decimal
        
        let number = WUtils.plainStringToDecimal(amount)
        var formatted: String?
        if (number == NSDecimalNumber.zero) {
            nf.minimumSignificantDigits = Int(dpPoint) + 1
            nf.maximumSignificantDigits = Int(dpPoint) + 1
            formatted = nf.string(from: NSDecimalNumber.zero)
            
        } else {
            let calNumber = number.multiplying(byPowerOf10: -Int16(inputPoint))
            if (calNumber.compare(NSDecimalNumber.one).rawValue < 0) {
                var temp = ""
                let decimal = Array(String(calNumber.stringValue.split(separator: ".")[1]))
                for i in 0 ..< Int(dpPoint) {
                    if (decimal.count > i) {
                        temp = temp.appending(String(decimal[i]))
                    } else {
                        temp = temp.appending("0")
                    }
                }
                formatted = "0" + nf.decimalSeparator! + temp
                
            } else {
                let count = calNumber.multiplying(by: NSDecimalNumber.one, withBehavior: WUtils.handler0Down).stringValue.count
                nf.minimumSignificantDigits = Int(dpPoint) + count
                nf.maximumSignificantDigits = Int(dpPoint) + count
                formatted = nf.string(from: calNumber)
            }

        }

        let added       = formatted!
        let endIndex    = added.index(added.endIndex, offsetBy: Int(-dpPoint))
        
        let preString   = added[..<endIndex]
        let postString  = added[endIndex...]
        
        let preAttrs = [NSAttributedString.Key.font : font]
        let postAttrs = [NSAttributedString.Key.font : font.withSize(CGFloat(Int(Double(font.pointSize) * 0.85)))]
        
        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    
    
    //display price & value
    static func dpAssetValue(_ geckoId: String, _ amount: NSDecimalNumber, _ divider: Int16, _ label: UILabel?) {
        let assetValue = WUtils.assetValue(geckoId, amount, divider)
        let nf = WUtils.getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: assetValue)!
        label?.attributedText = WUtils.getDpAttributedString(formatted, 3, label?.font)
    }
    
    static func dpAllAssetValue(_ chainConfig: ChainConfig?, _ label: UILabel?) {
        let totalValue = WUtils.allAssetValue(chainConfig)
        let nf = WUtils.getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: totalValue)!
        label?.attributedText = WUtils.getDpAttributedString(formatted, 3, label?.font)
    }
    
    static func dpBnbTokenPrice(_ symbol: String, _ label: UILabel?) {
        let nf = WUtils.getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: WUtils.bnbTokenPrice(symbol))!
        label?.attributedText = WUtils.getDpAttributedString(formatted, 3, label?.font)
    }
    
    static func dpPrice(_ geckoId: String, _ label: UILabel?) {
        let nf = WUtils.getNumberFormatter(3)
        let formatted = BaseData.instance.getCurrencySymbol() + " " + nf.string(from: WUtils.price(geckoId))!
        label?.attributedText = WUtils.getDpAttributedString(formatted, 3, label?.font)
    }
    
    static func dpPriceChanged(_ geckoId: String, _ label: UILabel?) {
        let nf = WUtils.getNumberFormatter(2)
        let change = WUtils.priceChange(geckoId)
        if (change.compare(NSDecimalNumber.zero).rawValue >= 0) {
            let formatted = "+" + nf.string(from: change)! + "%"
            label?.attributedText = WUtils.getDpAttributedString(formatted, 3, label?.font)
        } else {
            let formatted = nf.string(from: change)! + "%"
            label?.attributedText = WUtils.getDpAttributedString(formatted, 3, label?.font)
        }
    }
    
    
    
    //display time
    static func dpTime(_ timeString: String?) -> String {
        if (timeString == nil) { return "-" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        return localFormatter.string(from: date)
    }
    
    static func dpTime(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "-" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
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
        guard let date = WUtils.timeInt64ToDate(timeInt! + Int64(TimeZone.current.secondsFromGMT()) * 1000) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format", comment: "")
        return localFormatter.string(from: date)
    }
    
    static func okcDpTimeGap(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "" }
        guard let date = WUtils.timeInt64ToDate(timeInt! + Int64(TimeZone.current.secondsFromGMT()) * 1000) else {
            return ""
        }
        return WUtils.getGapTime(date)
    }
    
    static func dpPath(_ path: String) -> String {
        return path.replacingOccurrences(of: "bnb-beacon-chain", with: "binance")
            .replacingOccurrences(of: "ethereum", with: "eth")
            .replacingOccurrences(of: "persistence", with: "persis")
            .replacingOccurrences(of: "gravity-bridge", with: "gravity")
            .replacingOccurrences(of: "konstellation", with: "konstel")
            .replacingOccurrences(of: "assetmantle", with: "assetman")
            .replacingOccurrences(of: ">", with: " ⇝ ")
    }
    
    static func priceUpColor(_ label: UILabel) {
        if (BaseData.instance.getPriceChaingColor() > 0) {
            label.textColor = UIColor(named: "_voteNo")
        } else {
            label.textColor = UIColor(named: "_voteYes")
        }
    }
    
    static func priceDownColor(_ label: UILabel) {
        if (BaseData.instance.getPriceChaingColor() > 0) {
            label.textColor = UIColor(named: "_voteYes")
        } else {
            label.textColor = UIColor(named: "_voteNo")
        }
    }
    
    static func setPriceColor(_ label: UILabel, _ change: NSDecimalNumber) {
        if (change.compare(NSDecimalNumber.zero).rawValue >= 0) {
            priceUpColor(label)
        } else if (change.compare(NSDecimalNumber.zero).rawValue < 0) {
            priceDownColor(label)
        }
    }
}
