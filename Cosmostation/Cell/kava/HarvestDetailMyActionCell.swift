//
//  HarvestDetailMyActionCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/14.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class HarvestDetailMyActionCell: UITableViewCell {
    
    @IBOutlet weak var depositImg: UIImageView!
    @IBOutlet weak var depositSymbol: UILabel!
    @IBOutlet weak var depositAmount: UILabel!
    @IBOutlet weak var depositValue: UILabel!
    @IBOutlet weak var borrowedAmount: UILabel!
    @IBOutlet weak var borrowedValue: UILabel!
    @IBOutlet weak var borroweableAmount: UILabel!
    @IBOutlet weak var borroweableValue: UILabel!
    @IBOutlet weak var depositBtn: UIButton!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var borrowBtn: UIButton!
    @IBOutlet weak var repayBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        depositAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        borrowedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        borroweableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    var actionDepoist: (() -> Void)? = nil
    var actionWithdraw: (() -> Void)? = nil
    var actionBorrow: (() -> Void)? = nil
    var actionRepay: (() -> Void)? = nil
    
    @IBAction func onClickDeposit(_ sender: UIButton) {
        actionDepoist?()
    }
    
    @IBAction func onClickWithdraw(_ sender: UIButton) {
        actionWithdraw?()
    }
    
    @IBAction func onClickBorrow(_ sender: UIButton) {
        actionBorrow?()
    }
    
    @IBAction func onClickRepay(_ sender: UIButton) {
        actionRepay?()
    }
    
    func onBindHardDetailAction(_ hardMoneyMarketDenom: String, _ hardParam: Kava_Hard_V1beta1_Params?,
                                _ myDeposits: Array<Coin>?, _ myBorrows: Array<Coin>?, _ moduleCoins: Array<Coin>?, _ reservedCoins: Array<Coin>?) {
        if (hardParam == nil) { return }
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        
        WDP.dpSymbolImg(chainConfig, hardMoneyMarketDenom, depositImg)
        WDP.dpSymbol(chainConfig, hardMoneyMarketDenom, depositSymbol)
        
        let decimal = WUtils.getDenomDecimal(chainConfig, hardMoneyMarketDenom)
        let oraclePrice = BaseData.instance.getKavaOraclePrice(hardParam?.getSpotMarketId(hardMoneyMarketDenom))
        let myDeposit = myDeposits?.filter { $0.denom == hardMoneyMarketDenom }.first
        let myBorrow = myBorrows?.filter { $0.denom == hardMoneyMarketDenom }.first

        let mySuppliedAmount = NSDecimalNumber.init(string: myDeposit?.amount)
        let mySuppliedValue = mySuppliedAmount.multiplying(byPowerOf10: -decimal, withBehavior: WUtils.handler12Down).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        depositAmount.attributedText = WDP.dpAmount(mySuppliedAmount.stringValue, depositAmount.font, decimal, decimal)
        depositValue.attributedText = WUtils.getDPRawDollor(mySuppliedValue.stringValue, 2, depositValue.font)

        let myBorrowedAmount = NSDecimalNumber.init(string: myBorrow?.amount)
        let myBorrowedValue = myBorrowedAmount.multiplying(byPowerOf10: -decimal, withBehavior: WUtils.handler12Down).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        borrowedAmount.attributedText = WDP.dpAmount(myBorrowedAmount.stringValue, borrowedAmount.font, decimal, decimal)
        borrowedValue.attributedText = WUtils.getDPRawDollor(myBorrowedValue.stringValue, 2, borrowedValue.font)
        
    
        let finalBorrowableAmount = WUtils.getHardBorrowableAmountByDenom(hardMoneyMarketDenom, myDeposits, myBorrows, moduleCoins, reservedCoins)
        let finalBorrowableValue = finalBorrowableAmount.multiplying(byPowerOf10: -decimal).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        borroweableAmount.attributedText = WDP.dpAmount(finalBorrowableAmount.stringValue, borroweableAmount.font, decimal, decimal)
        borroweableValue.attributedText = WUtils.getDPRawDollor(finalBorrowableValue.stringValue, 2, borroweableValue.font)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        depositBtn.borderColor = UIColor.font05
        withdrawBtn.borderColor = UIColor.font05
        borrowBtn.borderColor = UIColor.font05
        repayBtn.borderColor = UIColor.font05
    }
    
}
