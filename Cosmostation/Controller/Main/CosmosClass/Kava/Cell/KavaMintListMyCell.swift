//
//  KavaMintListMyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

class KavaMintListMyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketTypeLabel: UILabel!
    @IBOutlet weak var marketPairLabel: UILabel!
    @IBOutlet weak var riskRateTitleLabel: UILabel!
    @IBOutlet weak var riskRateLabel: UILabel!
    @IBOutlet weak var collateralTitle: UILabel!
    @IBOutlet weak var collateralValueLabel: UILabel!
    @IBOutlet weak var ltvTitle: UILabel!
    @IBOutlet weak var ltvValueLabel: UILabel!
    @IBOutlet weak var borrowedTitle: UILabel!
    @IBOutlet weak var borrowedValueLabel: UILabel!
    @IBOutlet weak var currentPriceTitle: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var liquidatePriceTitle: UILabel!
    @IBOutlet weak var liquidatePriceCurrencyLabel: UILabel!
    @IBOutlet weak var liquidatePriceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        marketImg.af.cancelImageRequest()
        marketImg.image = nil
    }
    
    
    func onBindCdp(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?,
                   _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?,
                   _ myCdp : Kava_Cdp_V1beta1_CDPResponse?) {
        if (collateralParam == nil || priceFeed == nil || myCdp == nil) { return }
        let url = KAVA_CDP_IMG_URL + collateralParam!.type + ".png"
        marketImg.af.setImage(withURL: URL(string: url)!)
        marketTypeLabel.text = collateralParam?.type.uppercased()
        marketPairLabel.text = collateralParam?.spotMarketID.uppercased()
        
        collateralTitle.text = NSLocalizedString("collateral_value_format", comment: "")
        borrowedTitle.text = NSLocalizedString("debt_value_format", comment: "")
        ltvTitle.text = NSLocalizedString("ltv_value_format", comment: "")
        currentPriceTitle.text = String(format: NSLocalizedString("current_price_format", comment: ""), collateralParam!.denom.uppercased())
        liquidatePriceTitle.text = String(format: NSLocalizedString("liquidation_price_format", comment: ""), collateralParam!.denom.uppercased())
        
        let collateralValue = myCdp!.getCollateralUsdxValue()
        let ltv = myCdp!.getUsdxLTV(collateralParam!)
        let borrowedValue = myCdp!.getDebtUsdxValue()
        WDP.dpValue(collateralValue, nil, collateralValueLabel)
        WDP.dpValue(ltv, nil, ltvValueLabel)
        WDP.dpValue(borrowedValue, nil, borrowedValueLabel)
        
        let currentPrice = priceFeed!.getKavaOraclePrice(collateralParam?.liquidationMarketID)
        let liquidationPrice = myCdp!.getLiquidationPrice(collateralParam!)
        WDP.dpValue(currentPrice, nil, currentPriceLabel)
        WDP.dpValue(liquidationPrice, nil, liquidatePriceLabel)
        
        let riskRate = borrowedValue.dividing(by: ltv).multiplying(byPowerOf10: 2, withBehavior: handler2)
        riskRateLabel.attributedText = WDP.dpAmount(riskRate.stringValue, riskRateLabel.font, 2)
        if (riskRate.floatValue <= 60) {
            riskRateLabel.textColor = UIColor.colorGreen
            liquidatePriceCurrencyLabel.textColor = UIColor.colorGreen
            liquidatePriceLabel.textColor = UIColor.colorGreen
        } else {
            riskRateLabel.textColor = UIColor.colorRed
            liquidatePriceCurrencyLabel.textColor = UIColor.colorRed
            liquidatePriceLabel.textColor = UIColor.colorRed
        }
    }
}
