//
//  CdpLisyMyCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/26.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class CdpLisyMyCell: UITableViewCell {

    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketType: UILabel!
    @IBOutlet weak var marketTitle: UILabel!
    @IBOutlet weak var riskRateImg: UIImageView!
    @IBOutlet weak var riskScore: UILabel!
    @IBOutlet weak var debtValueTitle: UILabel!
    @IBOutlet weak var debtValue: UILabel!
    @IBOutlet weak var collateralValueTitle: UILabel!
    @IBOutlet weak var collateralValue: UILabel!
    @IBOutlet weak var currentPriceTitle: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var liquidationPriceTitle: UILabel!
    @IBOutlet weak var liquidationPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        debtValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        collateralValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        currentPrice.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        liquidationPrice.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindMyCdp(_ myCdp: Kava_Cdp_V1beta1_CDPResponse, _ collateralParam: Kava_Cdp_V1beta1_CollateralParam?) {
        if (collateralParam == nil) { return }
        
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        let mCDenom = myCdp.collateral.denom
        let mPDenom = myCdp.principal.denom
        let marketIdPrice = BaseData.instance.getKavaOraclePrice(collateralParam?.liquidationMarketID)
        
        marketType.text = collateralParam?.type.uppercased()
        marketTitle.text = collateralParam!.getDpMarketId()
        
        let liquidationPrices = myCdp.getLiquidationPrice(mCDenom, mPDenom, collateralParam!)
        if (marketIdPrice != NSDecimalNumber.zero) {
            let riskRate = NSDecimalNumber.init(string: "100").subtracting(marketIdPrice.subtracting(liquidationPrices).multiplying(byPowerOf10: 2).dividing(by: marketIdPrice, withBehavior: WUtils.handler2Down))
            WUtils.showRiskRate(riskRate, riskScore, _rateIamg: riskRateImg)
            
            liquidationPriceTitle.text = String(format: NSLocalizedString("liquidation_price_format", comment: ""), WUtils.getSymbol(chainConfig, mCDenom))
            liquidationPrice.attributedText = WUtils.getDPRawDollor(liquidationPrices.stringValue, 4, liquidationPrice.font)
            liquidationPrice.textColor = WUtils.getRiskColor(riskRate)
        }
        
        debtValueTitle.text = String(format: NSLocalizedString("debt_value_format", comment: ""), WUtils.getSymbol(chainConfig, mPDenom))
        debtValue.attributedText = WUtils.getDPRawDollor(myCdp.getDpEstimatedTotalDebtValue(mPDenom, collateralParam!).stringValue, 2, debtValue.font)
        
        collateralValueTitle.text = String(format: NSLocalizedString("collateral_value_format", comment: ""), WUtils.getSymbol(chainConfig, mCDenom))
        collateralValue.attributedText = WUtils.getDPRawDollor(myCdp.getDpCollateralValue(mPDenom).stringValue, 2, collateralValue.font)
        
        currentPriceTitle.text = String(format: NSLocalizedString("current_price_format", comment: ""), WUtils.getSymbol(chainConfig, mCDenom))
        currentPrice.attributedText = WUtils.getDPRawDollor(marketIdPrice.stringValue, 4, currentPrice.font)
        
        let url = KAVA_CDP_IMG_URL + collateralParam!.getMarketImgPath()! + ".png"
        marketImg.af_setImage(withURL: URL(string: url)!)
    }
    
}
