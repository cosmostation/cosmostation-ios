//
//  TokenDetailNativeCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TokenDetailNativeCell: TokenDetailCell {
    
//    @IBOutlet weak var tokenImg: UIImageView!
//    @IBOutlet weak var tokenSymbol: UILabel!
//    @IBOutlet weak var tokenDenom: UILabel!
    
    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var totalAmount: UILabel!
//    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var lockedAmount: UILabel!
    @IBOutlet weak var fronzenAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    
    @IBOutlet weak var lockedLayer: UIView!
    @IBOutlet weak var frozenLayer: UIView!
    @IBOutlet weak var vestingLayer: UIView!
    
    
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        lockedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        fronzenAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    override func prepareForReuse() {
        lockedLayer.isHidden = true
        frozenLayer.isHidden = true
        vestingLayer.isHidden = true
    }
    
    func onBindNativeToken(_ chainType: ChainType?, _ denom: String?) {
        if (WUtils.isGRPC(chainType)) {
            onBindNativeToken_gRPC(chainType, denom)
            
        } else if (chainType! == ChainType.BINANCE_MAIN) {
            onBindBNBTokens(denom)
            
        } else if (chainType! == ChainType.OKEX_MAIN) {
            onBindOKTokens(denom)
            
        }
    }
    
    func onBindPoolToken(_ chainType: ChainType?, _ denom: String?) {
        if (chainType! == ChainType.OSMOSIS_MAIN) {
            divideDecimal = 18
            displayDecimal = 18
            
            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        } else if (chainType! == ChainType.COSMOS_MAIN) {
            divideDecimal = 6
            displayDecimal = 6

            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        } else if (chainType! == ChainType.INJECTIVE_MAIN) {
            divideDecimal = 18
            displayDecimal = 18
            
            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        } else if (chainType! == ChainType.CRESCENT_MAIN) {
            divideDecimal = 12
            displayDecimal = 12
            
            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        }
    }
    
    func onBindBridgeToken(_ chainType: ChainType?, _ denom: String?) {
        if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(denom!) {
            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            divideDecimal = bridgeTokenInfo.decimal
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, divideDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, divideDecimal)
        }
    }
    
    
    func onBindNativeToken_gRPC(_ chainType: ChainType?, _ denom: String?) {
        if (chainType == ChainType.OSMOSIS_MAIN) {
            if (denom == OSMOSIS_ION_DENOM) {
                divideDecimal = 6
                displayDecimal = 6
                
                let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
                totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
                availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            }
            
        } else if (chainType == ChainType.EMONEY_MAIN) {
            divideDecimal = 6
            displayDecimal = 6
            
            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        } else if (chainType! == ChainType.KAVA_MAIN) {
            onBindKavaTokens(denom)
            
        } else if (chainType! == ChainType.CRESCENT_MAIN || chainType! == ChainType.CRESCENT_TEST) {
            divideDecimal = 6
            displayDecimal = 6
            
            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        } else if (chainType! == ChainType.NYX_MAIN) {
            divideDecimal = 6
            displayDecimal = 6

            let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, divideDecimal, displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, divideDecimal, displayDecimal)
            
        }
    }
    
    func onBindBNBTokens(_ denom: String?) {
        let balance = BaseData.instance.getBalance(denom)
        let bnbToken = WUtils.getBnbToken(denom)
        if (balance != nil && bnbToken != nil) {
            frozenLayer.isHidden = false
            lockedLayer.isHidden = false
            
            let available = BaseData.instance.availableAmount(denom!)
            let locked = BaseData.instance.lockedAmount(denom!)
            let frozen = BaseData.instance.frozenAmount(denom!)
            let total = available.adding(locked).adding(frozen)
            
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, 0, 8)
            availableAmount.attributedText = WDP.dpAmount(available.stringValue, availableAmount.font, 0, 8)
            lockedAmount.attributedText = WDP.dpAmount(locked.stringValue, availableAmount.font, 0, 8)
            fronzenAmount.attributedText = WDP.dpAmount(frozen.stringValue, availableAmount.font, 0, 8)
        }
    }
    
    func onBindKavaTokens(_ denom: String?) {
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        let dpDecimal = WUtils.getDenomDecimal(chainConfig, denom!)
        let available = BaseData.instance.getAvailableAmount_gRPC(denom!)
        let vesting = BaseData.instance.getVestingAmount_gRPC(denom!)
        
        totalAmount.attributedText = WDP.dpAmount(available.adding(vesting).stringValue, totalAmount.font, dpDecimal, dpDecimal)
        availableAmount.attributedText = WDP.dpAmount(available.stringValue, availableAmount.font, dpDecimal, dpDecimal)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WDP.dpAmount(vesting.stringValue, vestingAmount.font!, dpDecimal, dpDecimal)
        }
        
        if (denom == KAVA_HARD_DENOM) {
            rootCardView.backgroundColor = UIColor.init(named: "_card_bg")
        } else if (denom == KAVA_USDX_DENOM) {
            rootCardView.backgroundColor = UIColor.init(named: "_card_bg")
        } else if (denom == KAVA_SWAP_DENOM) {
            rootCardView.backgroundColor = UIColor.init(named: "_card_bg")
        }
    }
    
    func onBindOKTokens(_ denom: String?) {
        let balance = BaseData.instance.getBalance(denom)
        let okToken = WUtils.getOkToken(denom)
        if (balance != nil && okToken != nil) {
            lockedLayer.isHidden = false
//            tokenImg.af_setImage(withURL: URL(string: OKTokenImgUrl + okToken!.original_symbol! + ".png")!)
//            tokenSymbol.text = okToken!.original_symbol!.uppercased()
//            tokenDenom.text = "(" + denom! + ")"
            
            let available = BaseData.instance.availableAmount(denom!)
            let locked = BaseData.instance.lockedAmount(denom!)
            let total = available.adding(locked)
//            let convertedAmount = WUtils.convertTokenToOkt(denom!)
            
            totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, 0, 18)
            availableAmount.attributedText = WDP.dpAmount(available.stringValue, availableAmount.font, 0, 18)
            lockedAmount.attributedText = WDP.dpAmount(locked.stringValue, availableAmount.font, 0, 18)
//            totalValue.attributedText = WUtils.dpUserCurrencyValue(OKEX_MAIN_DENOM, convertedAmount, 0, totalValue.font)
            
        }
    }
}
