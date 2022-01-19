//
//  HarvestListAllCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/14.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class HardListCell: UITableViewCell {
    
    @IBOutlet weak var harvestImg: UIImageView!
    @IBOutlet weak var harvestTitle: UILabel!
    @IBOutlet weak var supplyAPILabel: UILabel!
    @IBOutlet weak var borrowAPILabel: UILabel!
    @IBOutlet weak var mySuppliedAmount: UILabel!
    @IBOutlet weak var mySuppliedDenom: UILabel!
    @IBOutlet weak var mySuppliedValue: UILabel!
    @IBOutlet weak var myBorrowedAmount: UILabel!
    @IBOutlet weak var myBorrowedDenom: UILabel!
    @IBOutlet weak var myBorrowedValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        mySuppliedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myBorrowedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindView(_ position: Int, _ hardParam: Kava_Hard_V1beta1_Params?, _ myDeposits: Array<Coin>?, _ myBorrows: Array<Coin>?,
                    _ interestRates: Array<Kava_Hard_V1beta1_MoneyMarketInterestRate>?) {
        guard let hardMoneyMarket = hardParam?.moneyMarkets[position] else {
            return
        }
        let decimal = WUtils.tokenDivideDecimal(ChainType.KAVA_MAIN, hardMoneyMarket.denom)
        let url = KAVA_HARD_POOL_IMG_URL + "lp" + hardMoneyMarket.denom + ".png"
        let title = hardMoneyMarket.spotMarketID.replacingOccurrences(of: ":30", with: "")
        harvestImg.af_setImage(withURL: URL(string: url)!)
        harvestTitle.text = title.uppercased()
        
        //Display API
        var supplyApy = NSDecimalNumber.zero
        var borrowApy = NSDecimalNumber.zero
        if let interestRate = interestRates?.filter({ $0.denom == hardMoneyMarket.denom}).first {
            supplyApy = interestRate.getSupplyInterestRate()
            borrowApy = interestRate.getBorrowInterestRate()
        }
        supplyAPILabel.attributedText = WUtils.displayPercent(supplyApy.multiplying(byPowerOf10: 2), supplyAPILabel.font)
        borrowAPILabel.attributedText = WUtils.displayPercent(borrowApy.multiplying(byPowerOf10: 2), borrowAPILabel.font)
        
        //Display supplied amounts
        var myDepositAmount = NSDecimalNumber.zero
        myDeposits?.forEach { coin in
            if (coin.denom == hardMoneyMarket.denom) {
                myDepositAmount = NSDecimalNumber.init(string: coin.amount)
            }
        }
        let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(hardMoneyMarket.denom))
        let myDepositValue = myDepositAmount.multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
        WUtils.showCoinDp(hardMoneyMarket.denom, myDepositAmount.stringValue, mySuppliedDenom, mySuppliedAmount, ChainType.KAVA_MAIN)
        mySuppliedValue.attributedText = WUtils.getDPRawDollor(myDepositValue.stringValue, 2, mySuppliedValue.font)
        
        
        //Display borrowed amounts
        var myBorrowAmount = NSDecimalNumber.zero
        myBorrows?.forEach { coin in
            if (coin.denom == hardMoneyMarket.denom) {
                myBorrowAmount = NSDecimalNumber.init(string: coin.amount)
            }
        }
        let myBorrowValue = myBorrowAmount.multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
        WUtils.showCoinDp(hardMoneyMarket.denom, myBorrowAmount.stringValue, myBorrowedDenom, myBorrowedAmount, ChainType.KAVA_MAIN)
        myBorrowedValue.attributedText = WUtils.getDPRawDollor(myBorrowValue.stringValue, 2, myBorrowedValue.font)
    }
    
}
