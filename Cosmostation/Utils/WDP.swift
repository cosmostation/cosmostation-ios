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
        dpSymbol(chainConfig, denom, denomLabel)
        if (amountLabel == nil ) { return }
        var divideDecimal: Int16 = 6
        var displayDecimal: Int16 = 6
        if (chainConfig!.isGrpc && denom!.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom!.replacingOccurrences(of: "ibc/", with: "")),
               ibcToken.auth == true {
                divideDecimal = ibcToken.decimal!
                displayDecimal = ibcToken.decimal!
            }
            amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, divideDecimal, displayDecimal)
            return
        }
        
        if (chainConfig?.chainType == .BINANCE_MAIN || chainConfig?.chainType == .OKEX_MAIN ) {
            divideDecimal = 0
            displayDecimal = WUtils.mainDisplayDecimal(chainConfig?.chainType)
        } else {
            divideDecimal = WUtils.getDenomDecimal(chainConfig, denom)
            displayDecimal = WUtils.getDenomDecimal(chainConfig, denom)
        }
        amountLabel!.attributedText = WDP.dpAmount(amount, amountLabel!.font, divideDecimal, displayDecimal)
    }
    
    static func dpAmount(_ amount: String?, _ font: UIFont, _ inputPoint: Int16, _ dpPoint: Int16) -> NSMutableAttributedString {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = Int(dpPoint)
        nf.maximumFractionDigits = Int(dpPoint)
        nf.roundingMode = .floor
        nf.numberStyle = .decimal
        
        let amount = WUtils.plainStringToDecimal(amount)
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
}
