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
                imgView?.image =  UIImage(named: "tokenPool")
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
                imgView?.image = UIImage(named: "tokenDefault")
                return
                
            } else if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
                if let url = bridgeTokenInfo.getImgUrl() {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
            
        } else if (chainConfig!.chainType == .NYX_MAIN) {
            if (denom == NYX_NYM_DENOM) {
                imgView?.image = UIImage(named: "nyx_nym")
                return
            }
            
        }
        
        else if (chainConfig!.chainType == .BINANCE_MAIN) {
            if let bnbTokenInfo = WUtils.getBnbToken(denom!) {
                if let url = URL(string: BINANCE_TOKEN_IMG_URL + bnbTokenInfo.original_symbol + ".png") {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
            
        } else if (chainConfig!.chainType == .OKEX_MAIN) {
            if let okTokenInfo = WUtils.getOkToken(denom!) {
                if let url = URL(string: OKEX_COIN_IMG_URL + okTokenInfo.original_symbol! + ".png") {
                    imgView?.af_setImage(withURL: url)
                    return
                }
            }
        }
        imgView?.image = UIImage(named: "tokenDefault")!
    }
}
