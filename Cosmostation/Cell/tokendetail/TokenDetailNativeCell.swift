//
//  TokenDetailNativeCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TokenDetailNativeCell: UITableViewCell {
    
    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var lockedAmount: UILabel!
    @IBOutlet weak var fronzenAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    
    @IBOutlet weak var lockedLayer: UIView!
    @IBOutlet weak var frozenLayer: UIView!
    @IBOutlet weak var vestingLayer: UIView!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var lockedLabel: UILabel!
    @IBOutlet weak var frozenLabel: UILabel!
    @IBOutlet weak var vestingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        lockedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        fronzenAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        totalLabel.text = NSLocalizedString("str_total", comment: "")
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        lockedLabel.text = NSLocalizedString("str_locked", comment: "")
        frozenLabel.text = NSLocalizedString("str_frozen", comment: "")
        vestingLabel.text = NSLocalizedString("str_vesting", comment: "")
    }
    
    override func prepareForReuse() {
        lockedLayer.isHidden = true
        frozenLayer.isHidden = true
        vestingLayer.isHidden = true
    }
    
    func onBindNativeToken(_ chainConfig: ChainConfig?, _ denom: String?) {
        if (chainConfig?.isGrpc == true) {
            onBindNativeToken_gRPC(chainConfig, denom)
            
        } else if (chainConfig?.chainType == .BINANCE_MAIN) {
            onBindBNBTokens(denom)

        } else if (chainConfig?.chainType == .OKEX_MAIN) {
            onBindOKTokens(denom)

        }
    }
    
    func onBindNativeToken_gRPC(_ chainConfig: ChainConfig?, _ denom: String?) {
        if (chainConfig == nil || denom == nil) { return }
        if let msAsset = BaseData.instance.getMSAsset(chainConfig!, denom!) {
            let decimal = msAsset.decimal
            if (chainConfig?.chainType == ChainType.KAVA_MAIN) {
                onBindKavaTokens(denom)
            } else {
                let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
                totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, decimal, decimal)
                availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, decimal, decimal)
            }
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
    
    func onBindBNBTokens(_ denom: String?) {
        let balance = BaseData.instance.getBalance(denom)
        let bnbToken = BaseData.instance.bnbToken(denom)
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
//            totalValue.attributedText = WUtils.dpValueUserCurrency(OKEX_MAIN_DENOM, convertedAmount, 0, totalValue.font)
            
        }
    }
}
