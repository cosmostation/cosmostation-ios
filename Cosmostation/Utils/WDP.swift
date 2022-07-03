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
        } else {
            denomLabel?.textColor = UIColor(named: "_font05")
        }
        if (chainConfig!.chainType == .KAVA_MAIN) {
            if (denom == KAVA_HARD_DENOM) { denomLabel?.textColor = UIColor.init(named: "kava_hard") }
            else if (denom == KAVA_USDX_DENOM) { denomLabel?.textColor = UIColor.init(named: "kava_usdx") }
            else if (denom == KAVA_SWAP_DENOM) { denomLabel?.textColor = UIColor.init(named: "kava_swp") }
            
        } else if (chainConfig!.chainType == .OSMOSIS_MAIN) {
            if (denom == OSMOSIS_ION_DENOM) { denomLabel?.textColor = UIColor.init(named: "osmosis_ion") }
            
        } else if (chainConfig!.chainType == .CRESCENT_MAIN) {
            if (denom == CRESCENT_BCRE_DENOM) { denomLabel?.textColor = UIColor.init(named: "crescent_bcre") }
            
        } else if (chainConfig!.chainType == .NYX_MAIN) {
            if (denom == NYX_NYM_DENOM) { denomLabel?.textColor = UIColor.init(named: "nyx_nym") }
        }
    }
    
    static func dpSymbolImg(_ chainConfig: ChainConfig?, _ denom: String?, _ imgView: UIImageView?) {
        imgView?.image = WUtils.getSymbolImg(chainConfig, denom)
    }
}
