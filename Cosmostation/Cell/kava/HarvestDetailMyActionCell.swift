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
        depositImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL + hardMoneyMarketDenom + ".png")!)
        if (hardMoneyMarketDenom == KAVA_MAIN_DENOM) {
            WUtils.setDenomTitle(ChainType.KAVA_MAIN, depositSymbol)
        } else {
            depositSymbol.textColor = .white
            depositSymbol.text = WUtils.getKavaTokenName(hardMoneyMarketDenom)
        }
        
        let decimal = WUtils.getKavaCoinDecimal(hardMoneyMarketDenom)
        let oraclePrice = BaseData.instance.getKavaOraclePrice(hardParam?.getSpotMarketId(hardMoneyMarketDenom))
        let myDeposit = myDeposits?.filter { $0.denom == hardMoneyMarketDenom }.first
        let myBorrow = myBorrows?.filter { $0.denom == hardMoneyMarketDenom }.first

        let mySuppliedAmount = NSDecimalNumber.init(string: myDeposit?.amount)
        let mySuppliedValue = mySuppliedAmount.multiplying(byPowerOf10: -decimal, withBehavior: WUtils.handler12Down).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        depositAmount.attributedText = WUtils.displayAmount2(mySuppliedAmount.stringValue, depositAmount.font, decimal, decimal)
        depositValue.attributedText = WUtils.getDPRawDollor(mySuppliedValue.stringValue, 2, depositValue.font)

        let myBorrowedAmount = NSDecimalNumber.init(string: myBorrow?.amount)
        let myBorrowedValue = myBorrowedAmount.multiplying(byPowerOf10: -decimal, withBehavior: WUtils.handler12Down).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)
        borrowedAmount.attributedText = WUtils.displayAmount2(myBorrowedAmount.stringValue, borrowedAmount.font, decimal, decimal)
        borrowedValue.attributedText = WUtils.getDPRawDollor(myBorrowedValue.stringValue, 2, borrowedValue.font)
        
        
        
//        var totalLTVValue = NSDecimalNumber.zero
//        var totalBorrowedValue = NSDecimalNumber.zero
//        var totalBorrowAbleAmount = NSDecimalNumber.zero
//
//        var SystemBorrowableAmount = NSDecimalNumber.zero
//        var moduleAmount = NSDecimalNumber.zero
//        var reserveAmount = NSDecimalNumber.zero
//
//        myDeposits?.forEach({ coin in
//            let innnerDecimal   = WUtils.getKavaCoinDecimal(coin.denom)
//            let LTV             = hardParam!.getLTV(coin.denom)
//            let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
//            let depositValue    = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -innnerDecimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
//            let ltvValue        = depositValue.multiplying(by: LTV)
//            totalLTVValue = totalLTVValue.adding(ltvValue)
//        })
//
//        myBorrows?.forEach({ coin in
//            let innnerDecimal   = WUtils.getKavaCoinDecimal(coin.denom)
//            let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
//            let borrowValue     = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -innnerDecimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
//            totalBorrowedValue = totalBorrowedValue.adding(borrowValue)
//        })
//        let tempBorrowAbleValue  = totalLTVValue.subtracting(totalBorrowedValue)
//        let totalBorrowAbleValue = tempBorrowAbleValue.compare(NSDecimalNumber.zero).rawValue > 0 ? tempBorrowAbleValue : NSDecimalNumber.zero
//        totalBorrowAbleAmount = totalBorrowAbleValue.multiplying(byPowerOf10: decimal, withBehavior: WUtils.handler12Down).dividing(by: oraclePrice, withBehavior: WUtils.getDivideHandler(decimal))
//
//        if let moduleCoin = moduleCoins?.filter({ $0.denom == hardMoneyMarketDenom }).first {
//            moduleAmount = NSDecimalNumber.init(string: moduleCoin.amount)
//        }
//        if let reserveCoin = reservedCoins?.filter({ $0.denom == hardMoneyMarketDenom }).first {
//            reserveAmount = NSDecimalNumber.init(string: reserveCoin.amount)
//        }
//        let moduleBorrowable = moduleAmount.subtracting(reserveAmount)
//        if (hardParam?.getHardMoneyMarket(hardMoneyMarketDenom)?.borrowLimit.hasMaxLimit_p == true) {
//            let maximum_limit = NSDecimalNumber.init(string: hardParam?.getHardMoneyMarket(hardMoneyMarketDenom)?.borrowLimit.maximumLimit).multiplying(byPowerOf10: -18)
//            SystemBorrowableAmount = maximum_limit.compare(moduleBorrowable).rawValue > 0 ? moduleBorrowable : maximum_limit
//        } else {
//            SystemBorrowableAmount = moduleBorrowable
//        }
//        let finalBorrowableAmount = totalBorrowAbleAmount.compare(SystemBorrowableAmount).rawValue > 0 ? SystemBorrowableAmount : totalBorrowAbleAmount
        let finalBorrowableAmount = WUtils.getHardBorrowableAmountByDenom(hardMoneyMarketDenom, myDeposits, myBorrows, moduleCoins, reservedCoins)
        let finalBorrowableValue = finalBorrowableAmount.multiplying(byPowerOf10: -decimal).multiplying(by: oraclePrice, withBehavior: WUtils.handler2Down)

        borroweableAmount.attributedText = WUtils.displayAmount2(finalBorrowableAmount.stringValue, borroweableAmount.font, decimal, decimal)
        borroweableValue.attributedText = WUtils.getDPRawDollor(finalBorrowableValue.stringValue, 2, borroweableValue.font)
    }
    
}
