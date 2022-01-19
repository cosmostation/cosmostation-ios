//
//  HardListMyStatusCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/04.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class HardListMyStatusCell: UITableViewCell {
    @IBOutlet weak var totalDepositedValue: UILabel!
    @IBOutlet weak var maxBorrowableValue: UILabel!
    @IBOutlet weak var totalBorrowedValue: UILabel!
    @IBOutlet weak var remainingBorrowableValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        totalDepositedValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        maxBorrowableValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        totalBorrowedValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        remainingBorrowableValue.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindMyHard(_ hardParam: Kava_Hard_V1beta1_Params?, _ myDeposits: Array<Coin>?, _ myBorrows: Array<Coin>?) {
        if (hardParam == nil) { return }
        var totalDepositValue = NSDecimalNumber.zero
        var totalLTVValue = NSDecimalNumber.zero
        myDeposits?.forEach({ coin in
            let decimal         = WUtils.tokenDivideDecimal(ChainType.KAVA_MAIN, coin.denom)
            let LTV             = hardParam!.getLTV(coin.denom)
            let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
            let depositValue    = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
            let ltvValue        = depositValue.multiplying(by: LTV)
            totalDepositValue = totalDepositValue.adding(depositValue)
            totalLTVValue = totalLTVValue.adding(ltvValue)
        })
        totalDepositedValue.attributedText = WUtils.getDPRawDollor(totalDepositValue.stringValue, 2, totalDepositedValue.font)
        maxBorrowableValue.attributedText = WUtils.getDPRawDollor(totalLTVValue.stringValue, 2, maxBorrowableValue.font)
        
        var totalBorroweValue = NSDecimalNumber.zero
        myBorrows?.forEach { coin in
            let decimal         = WUtils.tokenDivideDecimal(ChainType.KAVA_MAIN, coin.denom)
            let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
            let borrowValue     = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
            totalBorroweValue = totalBorroweValue.adding(borrowValue)
        }
        let remainBorrowable = (totalLTVValue.subtracting(totalBorroweValue).compare(NSDecimalNumber.zero).rawValue > 0) ? totalLTVValue.subtracting(totalBorroweValue) : NSDecimalNumber.zero
        totalBorrowedValue.attributedText = WUtils.getDPRawDollor(totalBorroweValue.stringValue, 2, totalBorrowedValue.font)
        remainingBorrowableValue.attributedText = WUtils.getDPRawDollor(remainBorrowable.stringValue, 2, remainingBorrowableValue.font)
    }
    
}
