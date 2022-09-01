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
    static func dpSymbol(_ chainConfig: ChainConfig?, _ denom: String?, _ denomLabel: UILabel?) {
        denomLabel?.text = WUtils.getSymbol(chainConfig, denom)
        if (chainConfig!.stakeDenom == denom) {
            denomLabel?.textColor = chainConfig?.chainColor
            return
        }
        if (chainConfig!.chainType == .KAVA_MAIN) {
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

        } else if (chainConfig!.chainType == .OSMOSIS_MAIN) {
            if (denom == OSMOSIS_ION_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "osmosis_ion")
                return
            }

        } else if (chainConfig!.chainType == .CRESCENT_MAIN) {
            if (denom == CRESCENT_BCRE_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "crescent_bcre")
                return
            }

        } else if (chainConfig!.chainType == .NYX_MAIN) {
            if (denom == NYX_NYM_DENOM) {
                denomLabel?.textColor = UIColor.init(named: "nyx_nym")
                return
            }
        }
        denomLabel?.textColor = UIColor(named: "_font05")
    }
    
    static func dpSymbolImg(_ chainConfig: ChainConfig?, _ denom: String?, _ imgView: UIImageView?) {
        if (chainConfig == nil || denom?.isEmpty == true) {
            imgView?.image = UIImage(named: "tokenDefault")
            return
        }
        if (chainConfig!.stakeDenom == denom) {
            imgView?.image = chainConfig!.stakeDenomImg
            return
        }
        if (chainConfig!.isGrpc && denom!.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom!.replacingOccurrences(of: "ibc/", with: "")),
               let url = URL(string: ibcToken.moniker ?? "") {
                imgView?.af_setImage(withURL: url)
                return
            }
        }
        
        if (chainConfig!.chainType == .KAVA_MAIN) {
            if let url = URL(string: KAVA_COIN_IMG_URL + denom! + ".png") {
                imgView?.af_setImage(withURL: url)
                return
            }
            
        } else if (chainConfig!.chainType == .OSMOSIS_MAIN) {
            if (denom == OSMOSIS_ION_DENOM) {
                imgView?.image = UIImage(named: "tokenIon")
                return
            } else if (denom!.starts(with: "gamm/pool/")) {
                imgView?.image =  UIImage(named: "tokenOsmosisPool")
                return
            }
            
        } else if (chainConfig!.chainType == .SIF_MAIN) {
            if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                if let url = bridgeTokenInfo.getImgUrl() {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
            
        } else if (chainConfig!.chainType == .CRESCENT_MAIN) {
            if (denom == CRESCENT_BCRE_DENOM) {
                imgView?.image = UIImage(named: "tokenBcre")
                return
            }
            
        } else if (chainConfig!.chainType == .EMONEY_MAIN) {
            if let url = URL(string: EMONEY_COIN_IMG_URL + denom! + ".png") {
                imgView?.af_setImage(withURL: url)
                return
            }
            
        } else if (chainConfig!.chainType == .GRAVITY_BRIDGE_MAIN) {
            if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                if let url = bridgeTokenInfo.getImgUrl() {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
            
        } else if (chainConfig!.chainType == .INJECTIVE_MAIN) {
            if (denom!.starts(with: "share")) {
                imgView?.image = UIImage(named: "tokenInjectivePool")
                return
                
            } else if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                if let url = bridgeTokenInfo.getImgUrl() {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
            
        } else if (chainConfig!.chainType == .NYX_MAIN) {
            if (denom == NYX_NYM_DENOM) {
                imgView?.image = UIImage(named: "tokenNym")
                return
            }
            
        }
        
        else if (chainConfig!.chainType == .BINANCE_MAIN) {
            if let bnbTokenInfo = WUtils.getBnbToken(denom!) {
                if let url = URL(string: BinanceTokenImgUrl + bnbTokenInfo.original_symbol + ".png") {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
            
        } else if (chainConfig!.chainType == .OKEX_MAIN) {
            if let okTokenInfo = WUtils.getOkToken(denom!) {
                if let url = URL(string: OKTokenImgUrl + okTokenInfo.original_symbol! + ".png") {
                    imgView?.af_setImage(withURL: url)
                    return
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
                amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, msAsset.decimal, msAsset.decimal)
            } else if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.denom == denom }).first {
                amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, msToken.decimal, msToken.decimal)
            } else {
                let decimal = WUtils.getDenomDecimal(chainConfig, denom)
                amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, decimal, decimal)
            }
            
        } else {
            if (chainConfig?.chainType == .BINANCE_MAIN) {
                amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, 0, 8)
            } else if (chainConfig?.chainType == .OKEX_MAIN ) {
                amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, 0, 18)
            }
        }
    }
    
    static func dpAmount(_ amount: String?, _ font: UIFont, _ inputPoint: Int16, _ dpPoint: Int16) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.roundingMode = .floor
        nf.numberStyle = .decimal
        
        let number = WUtils.plainStringToDecimal(amount)
//        print("number ", number)
        var formatted: String?
        if (number == NSDecimalNumber.zero) {
            nf.minimumSignificantDigits = Int(dpPoint) + 1
            nf.maximumSignificantDigits = Int(dpPoint) + 1
            formatted = nf.string(from: NSDecimalNumber.zero)
            
        } else {
            let calNumber = number.multiplying(byPowerOf10: -Int16(inputPoint))
//            print("calNumber ", calNumber)
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
//                print("count ", count)
                nf.minimumSignificantDigits = Int(dpPoint) + count
                nf.maximumSignificantDigits = Int(dpPoint) + count
                formatted = nf.string(from: calNumber)
            }
            
        }
//        print("formatted ", formatted)

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
    
    static func dpTime(_ timeString: String?) -> String {
        if (timeString == nil) { return "-" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format4", comment: "")
        return localFormatter.string(from: date)
    }
    
    static func dpTime(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "-" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
            return "-"
        }
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = NSLocalizedString("date_format4", comment: "")
        return localFormatter.string(from: date)
    }
    
    static func dpTimeGap(_ timeString: String?) -> String {
        if (timeString == nil) { return "" }
        guard let date = WUtils.timeStringToDate(timeString!) else {
            return ""
        }
        return WUtils.getGapTime(date)
    }
    
    static func dpTimeGap(_ timeInt: Int64?) -> String {
        if (timeInt == nil) { return "" }
        guard let date = WUtils.timeInt64ToDate(timeInt!) else {
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
}
