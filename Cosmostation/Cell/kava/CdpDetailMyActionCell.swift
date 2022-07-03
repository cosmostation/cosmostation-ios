//
//  CdpDetailMyActionCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/27.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class CdpDetailMyActionCell: UITableViewCell {
    
    @IBOutlet weak var collateralImg: UIImageView!
    @IBOutlet weak var collateralDenom: UILabel!
    @IBOutlet weak var collateralSelfAmount: UILabel!
    @IBOutlet weak var collateralSelfValue: UILabel!
    @IBOutlet weak var collateralTotalAmount: UILabel!
    @IBOutlet weak var collateralTotalValue: UILabel!
    @IBOutlet weak var collateralWithdrawableTitle: UILabel!
    @IBOutlet weak var collateralWithdrawableAmount: UILabel!
    @IBOutlet weak var collateralWithdrawableValue: UILabel!
    @IBOutlet weak var depositBtn: UIButton!
    @IBOutlet weak var withdrawBtn: UIButton!

    @IBOutlet weak var principalImg: UIImageView!
    @IBOutlet weak var principalDenom: UILabel!
    @IBOutlet weak var principalAmount: UILabel!
    @IBOutlet weak var principalValue: UILabel!
    @IBOutlet weak var interestAmount: UILabel!
    @IBOutlet weak var interestValue: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var remainingValue: UILabel!
    @IBOutlet weak var darwdebtBtn: UIButton!
    @IBOutlet weak var repayBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        collateralSelfAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        collateralTotalAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        collateralWithdrawableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        collateralSelfValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        collateralTotalValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        collateralWithdrawableValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        
        principalAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        interestAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        remainingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        principalValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        interestValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        remainingValue.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Font_11_caption2)
        
    }
    
    var helpCollateralSelf: (() -> Void)? = nil
    var helpCollateralTotal: (() -> Void)? = nil
    var helpCollateralWithdrawable: (() -> Void)? = nil
    var helpPrincipal: (() -> Void)? = nil
    var helpInterest: (() -> Void)? = nil
    var helpRemaining: (() -> Void)? = nil
    
    var actionDeposit: (() -> Void)? = nil
    var actionWithdraw: (() -> Void)? = nil
    var actionDrawDebt: (() -> Void)? = nil
    var actionRepay: (() -> Void)? = nil
    
    @IBAction func onClickCollateralSelf(_ sender: UIButton) {
        helpCollateralSelf?()
    }
    
    @IBAction func onClickCollateralTotal(_ sender: UIButton) {
        helpCollateralTotal?()
    }
    
    @IBAction func onClickCollateralWithdrawable(_ sender: UIButton) {
        helpCollateralWithdrawable?()
    }
    
    @IBAction func onClickPrincipal(_ sender: UIButton) {
        helpPrincipal?()
    }
    
    @IBAction func onClickInterest(_ sender: UIButton) {
        helpInterest?()
    }
    
    @IBAction func onClickRemaining(_ sender: UIButton) {
        helpRemaining?()
    }
    
    
    @IBAction func onClickDeposit(_ sender: UIButton) {
        actionDeposit?()
    }
    
    @IBAction func onClickWithdraw(_ sender: UIButton) {
        actionWithdraw?()
    }
    
    @IBAction func onClickDrawDebt(_ sender: UIButton) {
        actionDrawDebt?()
    }
    
    @IBAction func onClickRepay(_ sender: UIButton) {
        actionRepay?()
    }
    
    func onBindCdpDetailAction(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?, _ myCdp: Kava_Cdp_V1beta1_CDPResponse?, _ selfDepositAmount: NSDecimalNumber, _ debtAmount: NSDecimalNumber) {
        if (collateralParam == nil || myCdp == nil) { return }
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        let cDenom = collateralParam!.getcDenom()!
        let pDenom = collateralParam!.getpDenom()!
        let cDpDecimal = WUtils.getKavaCoinDecimal(cDenom)
        let pDpDecimal = WUtils.getKavaCoinDecimal(pDenom)
        let oraclePrice = BaseData.instance.getKavaOraclePrice(collateralParam!.liquidationMarketID)
        
       WDP.dpSymbol(chainConfig, cDenom, collateralDenom)
        let selfDepositValue = selfDepositAmount.multiplying(byPowerOf10: -cDpDecimal).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        collateralSelfAmount.attributedText = WUtils.displayAmount2(selfDepositAmount.stringValue, collateralSelfAmount.font!, cDpDecimal, cDpDecimal)
        collateralSelfValue.attributedText = WUtils.getDPRawDollor(selfDepositValue.stringValue, 2, collateralSelfValue.font)

        let totalDepositAmount = myCdp!.getRawCollateralAmount()
        let totalDepositValue = totalDepositAmount.multiplying(byPowerOf10: -cDpDecimal).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        collateralTotalAmount.attributedText = WUtils.displayAmount2(totalDepositAmount.stringValue, collateralTotalAmount.font!, cDpDecimal, cDpDecimal)
        collateralTotalValue.attributedText = WUtils.getDPRawDollor(totalDepositValue.stringValue, 2, collateralTotalValue.font)

        collateralWithdrawableTitle.text = String(format: NSLocalizedString("withdrawable_format", comment: ""), WUtils.getSymbol(chainConfig, cDenom))
        let maxWithdrawableAmount = myCdp!.getWithdrawableAmount(cDenom, pDenom, collateralParam!, oraclePrice, selfDepositAmount)
        let maxWithdrawableValue = maxWithdrawableAmount.multiplying(byPowerOf10: -cDpDecimal).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        collateralWithdrawableAmount.attributedText = WUtils.displayAmount2(maxWithdrawableAmount.stringValue, collateralWithdrawableAmount.font!, cDpDecimal, cDpDecimal)
        collateralWithdrawableValue.attributedText = WUtils.getDPRawDollor(maxWithdrawableValue.stringValue, 2, collateralWithdrawableValue.font)

        depositBtn.setTitle(String(format: NSLocalizedString("str_deposit", comment: ""), WUtils.getSymbol(chainConfig, cDenom)), for: .normal)
        withdrawBtn.setTitle(String(format: NSLocalizedString("str_withdraw", comment: ""), WUtils.getSymbol(chainConfig, cDenom)), for: .normal)

        WDP.dpSymbol(chainConfig, pDenom, principalDenom)
        let rawPricipalAmount = myCdp!.getRawPrincipalAmount()
        principalAmount.attributedText = WUtils.displayAmount2(rawPricipalAmount.stringValue, principalAmount.font!, pDpDecimal, pDpDecimal)
        principalValue.attributedText = WUtils.getDPRawDollor(rawPricipalAmount.multiplying(byPowerOf10: -pDpDecimal).stringValue, 2, principalValue.font)

        let totalFeeAmount = myCdp!.getEstimatedTotalFee(collateralParam!)
        interestAmount.attributedText = WUtils.displayAmount2(totalFeeAmount.stringValue, interestAmount.font!, pDpDecimal, pDpDecimal)
        interestValue.attributedText = WUtils.getDPRawDollor(totalFeeAmount.multiplying(byPowerOf10: -pDpDecimal).stringValue, 2, principalValue.font)

        let moreDebtAmount = myCdp!.getMoreLoanableAmount(collateralParam!)
        remainingAmount.attributedText = WUtils.displayAmount2(moreDebtAmount.stringValue, remainingAmount.font!, pDpDecimal, pDpDecimal)
        remainingValue.attributedText = WUtils.getDPRawDollor(moreDebtAmount.multiplying(byPowerOf10: -pDpDecimal).stringValue, 2, remainingValue.font)

        WDP.dpSymbolImg(chainConfig, cDenom, collateralImg)
        WDP.dpSymbolImg(chainConfig, pDenom, principalImg)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        depositBtn.borderColor = UIColor.init(named: "_font05")
        withdrawBtn.borderColor = UIColor.init(named: "_font05")
        darwdebtBtn.borderColor = UIColor.init(named: "_font05")
        repayBtn.borderColor = UIColor.init(named: "_font05")
    }
}
