//
//  CdpDetailMyTopCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/27.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class CdpDetailMyTopCell: UITableViewCell {
    
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketType: UILabel!
    @IBOutlet weak var marketTitle: UILabel!
    @IBOutlet weak var riskRateImg: UIImageView!
    @IBOutlet weak var riskScore: UILabel!
//    @IBOutlet weak var debtValueTitle: UILabel!
//    @IBOutlet weak var debtValue: UILabel!
//    @IBOutlet weak var collateralValueTitle: UILabel!
//    @IBOutlet weak var collateralValue: UILabel!
    
    @IBOutlet weak var minCollateralRate: UILabel!
    @IBOutlet weak var stabilityFee: UILabel!
    @IBOutlet weak var liquidationPenalty: UILabel!
    @IBOutlet weak var currentPriceTitle: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var liquidationPriceTitle: UILabel!
    @IBOutlet weak var liquidationPrice: UILabel!
    @IBOutlet weak var systemMax: UILabel!
    @IBOutlet weak var remainCap: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
//        debtValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
//        collateralValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        minCollateralRate.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        stabilityFee.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        liquidationPenalty.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        currentPrice.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        liquidationPrice.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        systemMax.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        remainCap.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    var helpCollateralRate: (() -> Void)? = nil
    var helpStabilityFee: (() -> Void)? = nil
    var helpLiquidationPenalty: (() -> Void)? = nil
    var helpRiskScore: (() -> Void)? = nil
    
    @IBAction func onClickCollateralRate(_ sender: UIButton) {
        helpCollateralRate?()
    }
    
    @IBAction func onClickStabilityFee(_ sender: UIButton) {
        helpStabilityFee?()
    }
    
    @IBAction func onClickLiquidationPenalty(_ sender: UIButton) {
        helpStabilityFee?()
    }
    @IBAction func onClickRiskScore(_ sender: UIButton) {
        helpRiskScore?()
    }
    
    func onBindCdpDetailMy(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?, _ myCdp: Kava_Cdp_V1beta1_CDPResponse?, _ debtAmount: NSDecimalNumber) {
        if (collateralParam == nil || myCdp == nil) { return }
        let cDenom = collateralParam!.getcDenom()!
        let pDenom = collateralParam!.getpDenom()!
        
        let oraclePrice = BaseData.instance.getKavaOraclePrice(collateralParam!.liquidationMarketID)
        let liquiPrice = myCdp!.getLiquidationPrice(cDenom, pDenom, collateralParam!)
        let riskRate = NSDecimalNumber.init(string: "100").subtracting(oraclePrice.subtracting(liquiPrice).multiplying(byPowerOf10: 2).dividing(by: oraclePrice, withBehavior: WUtils.handler2Down))

        print("oraclePrice ", oraclePrice)
        print("liquiPrice ", liquiPrice)
        print("riskRate ", riskRate)

        marketTitle.text = collateralParam!.getDpMarketId()
        marketType.text = collateralParam!.type.uppercased()
        WUtils.showRiskRate(riskRate, riskScore, _rateIamg: riskRateImg)
        minCollateralRate.attributedText = WUtils.displayPercent(collateralParam!.getDpLiquidationRatio(), minCollateralRate.font)
        stabilityFee.attributedText = WUtils.displayPercent(collateralParam!.getDpStabilityFee(), stabilityFee.font)
        liquidationPenalty.attributedText = WUtils.displayPercent(collateralParam!.getDpLiquidationPenalty(), liquidationPenalty.font)

        currentPriceTitle.text = String(format: NSLocalizedString("current_price_format", comment: ""), WUtils.getKavaSymbol(cDenom))
        currentPrice.attributedText = WUtils.getDPRawDollor(oraclePrice.stringValue, 4, currentPrice.font)

        liquidationPriceTitle.text = String(format: NSLocalizedString("liquidation_price_format", comment: ""), WUtils.getKavaSymbol(cDenom))
        liquidationPrice.attributedText = WUtils.getDPRawDollor(liquiPrice.stringValue, 4, liquidationPrice.font)
        liquidationPrice.textColor = WUtils.getRiskColor(riskRate)

        let kavaCdpParams_gRPC = BaseData.instance.mKavaCdpParams_gRPC
        systemMax.attributedText = WUtils.displayAmount2(kavaCdpParams_gRPC!.getGlobalDebtAmount().stringValue, systemMax.font, 6, 6)
        remainCap.attributedText = WUtils.displayAmount2(kavaCdpParams_gRPC!.getGlobalDebtAmount().subtracting(debtAmount).stringValue, remainCap.font, 6, 6)

        let url = KAVA_CDP_IMG_URL + collateralParam!.getMarketImgPath()! + ".png"
        marketImg.af_setImage(withURL: URL(string: url)!)
    }
}
