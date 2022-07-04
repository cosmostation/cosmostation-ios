//
//  CdpDetailAssetsCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/27.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class CdpDetailAssetsCell: UITableViewCell {

    @IBOutlet weak var collateralImg: UIImageView!
    @IBOutlet weak var collateralDenom: UILabel!
    @IBOutlet weak var collateralAmount: UILabel!
    @IBOutlet weak var collateralValue: UILabel!
    @IBOutlet weak var principalImg: UIImageView!
    @IBOutlet weak var principalDenom: UILabel!
    @IBOutlet weak var principalAmount: UILabel!
    @IBOutlet weak var principalValue: UILabel!
    @IBOutlet weak var kavaAmount: UILabel!
    @IBOutlet weak var kavaValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        collateralAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        principalAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        kavaAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        collateralValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        principalValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        kavaValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
    }
    
    func onBindCdpDetailAsset(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?) {
        if (collateralParam == nil) { return }
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        let cDenom = collateralParam!.getcDenom()!
        let pDenom = collateralParam!.getpDenom()!
        let cDpDecimal = WUtils.getDenomDecimal(chainConfig, cDenom)
        let pDpDecimal = WUtils.getDenomDecimal(chainConfig, pDenom)
        let kDpDecimal = WUtils.getDenomDecimal(chainConfig, KAVA_MAIN_DENOM)
        let cAvailable = BaseData.instance.getAvailableAmount_gRPC(cDenom)
        let pAvailable = BaseData.instance.getAvailableAmount_gRPC(pDenom)
        let kAvailable = BaseData.instance.getAvailableAmount_gRPC(KAVA_MAIN_DENOM)
        let oraclePrice = BaseData.instance.getKavaOraclePrice(collateralParam!.liquidationMarketID)
        
        WDP.dpSymbol(chainConfig, cDenom, collateralDenom)
        collateralAmount.attributedText = WUtils.displayAmount2(cAvailable.stringValue, collateralAmount.font!, cDpDecimal, cDpDecimal)
        let collateralValues = cAvailable.multiplying(byPowerOf10: -cDpDecimal).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        collateralValue.attributedText = WUtils.getDPRawDollor(collateralValues.stringValue, 2, collateralValue.font)

        WDP.dpSymbol(chainConfig, pDenom, principalDenom)
        principalAmount.attributedText = WUtils.displayAmount2(pAvailable.stringValue, principalAmount.font!, pDpDecimal, pDpDecimal)
        let principalValues = pAvailable.multiplying(byPowerOf10: -pDpDecimal)
        principalValue.attributedText = WUtils.getDPRawDollor(principalValues.stringValue, 2, principalValue.font)

        kavaAmount.attributedText = WUtils.displayAmount2(kAvailable.stringValue, kavaAmount.font!, kDpDecimal, kDpDecimal)
        let kavaValues = kAvailable.multiplying(byPowerOf10: -kDpDecimal).multiplying(by: WUtils.perUsdValue(KAVA_MAIN_DENOM)!, withBehavior: WUtils.handler2Down)
        kavaValue.attributedText = WUtils.getDPRawDollor(kavaValues.stringValue, 2, kavaValue.font)
        
        WDP.dpSymbolImg(chainConfig, cDenom, collateralImg)
        WDP.dpSymbolImg(chainConfig, pDenom, principalImg)
    }
    
}
