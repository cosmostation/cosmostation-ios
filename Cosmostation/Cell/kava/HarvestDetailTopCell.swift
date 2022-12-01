//
//  HarvestDetailTopCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/14.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class HarvestDetailTopCell: UITableViewCell {
    
    @IBOutlet weak var harvestImg: UIImageView!
    @IBOutlet weak var harvestTitle: UILabel!
    @IBOutlet weak var supplyAPILabel: UILabel!
    @IBOutlet weak var borrowAPILabel: UILabel!
    @IBOutlet weak var systemSuppliedAmount: UILabel!
    @IBOutlet weak var systemSuppliedDenom: UILabel!
    @IBOutlet weak var systemSuppliedValue: UILabel!
    @IBOutlet weak var systemBorrowedAmount: UILabel!
    @IBOutlet weak var systemBorrowedDenom: UILabel!
    @IBOutlet weak var systemBorrowedValue: UILabel!
    @IBOutlet weak var systemRemainBorrowableAmount: UILabel!
    @IBOutlet weak var systemRemainBorrowableDenom: UILabel!
    @IBOutlet weak var systemRemainBorrowableValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindHardDetailTop(_ hardMoneyMarketDenom: String, _ hardParam: Kava_Hard_V1beta1_Params?, _ interestRates: Array<Kava_Hard_V1beta1_MoneyMarketInterestRate>?,
                             _ totalDeposit: Array<Coin>?, _ totalBorrow: Array<Coin>?, _ moduleCoins: Array<Coin>?, _ reservedCoins: Array<Coin>?) {
        if (hardParam == nil) { return }
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        var hardImgDenom = ""
        if (hardMoneyMarketDenom.starts(with: "ibc/")) {
            hardImgDenom = BaseData.instance.getBaseDenom(chainConfig, hardMoneyMarketDenom)
        } else {
            hardImgDenom = hardMoneyMarketDenom
        }
        harvestImg.af_setImage(withURL: URL(string: KAVA_HARD_POOL_IMG_URL + "lp" + hardImgDenom + ".png")!)
        harvestTitle.text = hardParam!.getHardMoneyMarket(hardMoneyMarketDenom)?.spotMarketID.replacingOccurrences(of: ":30", with: "").replacingOccurrences(of: ":720", with: "").uppercased()

        var supplyApy = NSDecimalNumber.zero
        var borrowApy = NSDecimalNumber.zero
        if let interestRate = interestRates?.filter({ $0.denom == hardMoneyMarketDenom}).first {
            supplyApy = interestRate.getSupplyInterestRate()
            borrowApy = interestRate.getBorrowInterestRate()
        }
        supplyAPILabel.attributedText = WUtils.displayPercent(supplyApy.multiplying(byPowerOf10: 2), supplyAPILabel.font)
        borrowAPILabel.attributedText = WUtils.displayPercent(borrowApy.multiplying(byPowerOf10: 2), borrowAPILabel.font)

        WDP.dpCoin(chainConfig, hardMoneyMarketDenom, "0", systemSuppliedDenom, systemSuppliedAmount)
        WDP.dpCoin(chainConfig, hardMoneyMarketDenom, "0", systemBorrowedDenom, systemBorrowedAmount)
        WDP.dpCoin(chainConfig, hardMoneyMarketDenom, "0", systemRemainBorrowableDenom, systemRemainBorrowableAmount)
        systemSuppliedValue.attributedText = WUtils.getDPRawDollor("0", 2, systemSuppliedValue.font)
        systemBorrowedValue.attributedText = WUtils.getDPRawDollor("0", 2, systemBorrowedValue.font)
        systemRemainBorrowableValue.attributedText = WUtils.getDPRawDollor("0", 2, systemRemainBorrowableValue.font)

        let dpDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == hardMoneyMarketDenom }).first?.decimals ?? 6 
        let targetPrice = BaseData.instance.getKavaOraclePrice(hardParam!.getHardMoneyMarket(hardMoneyMarketDenom)?.spotMarketID)

        // display system total supplied
        if let totalDepositCoin = totalDeposit?.filter({ $0.denom == hardMoneyMarketDenom }).first {
            WDP.dpCoin(chainConfig, hardMoneyMarketDenom, totalDepositCoin.amount, systemSuppliedDenom, systemSuppliedAmount)
            let supplyValue = NSDecimalNumber.init(string: totalDepositCoin.amount).multiplying(byPowerOf10: -dpDecimal).multiplying(by: targetPrice, withBehavior: WUtils.handler2Down)
            systemSuppliedValue.attributedText = WUtils.getDPRawDollor(supplyValue.stringValue, 2, systemSuppliedValue.font)
        }

        // display system total borrowed
        if let totalBorrowedCoin = totalBorrow?.filter({ $0.denom == hardMoneyMarketDenom }).first {
            WDP.dpCoin(chainConfig, hardMoneyMarketDenom, totalBorrowedCoin.amount, systemBorrowedDenom, systemBorrowedAmount)
            let BorrowedValue = NSDecimalNumber.init(string: totalBorrowedCoin.amount).multiplying(byPowerOf10: -dpDecimal).multiplying(by: targetPrice, withBehavior: WUtils.handler2Down)
            systemBorrowedValue.attributedText = WUtils.getDPRawDollor(BorrowedValue.stringValue, 2, systemBorrowedValue.font)
        }

        // display system remain borrowable
        var SystemBorrowableAmount = NSDecimalNumber.zero
        var SystemBorrowableValue = NSDecimalNumber.zero
        var moduleAmount = NSDecimalNumber.zero
        var reserveAmount = NSDecimalNumber.zero
        if let moduleCoin = moduleCoins?.filter({ $0.denom == hardMoneyMarketDenom }).first {
            moduleAmount = NSDecimalNumber.init(string: moduleCoin.amount)
        }
        if let reserveCoin = reservedCoins?.filter({ $0.denom == hardMoneyMarketDenom }).first {
            reserveAmount = NSDecimalNumber.init(string: reserveCoin.amount)
        }

        let moduleBorrowable = moduleAmount.subtracting(reserveAmount)
        if (hardParam?.getHardMoneyMarket(hardMoneyMarketDenom)?.borrowLimit.hasMaxLimit_p == true) {
            let maximum_limit = NSDecimalNumber.init(string: hardParam?.getHardMoneyMarket(hardMoneyMarketDenom)?.borrowLimit.maximumLimit).multiplying(byPowerOf10: -18)
            SystemBorrowableAmount = maximum_limit.compare(moduleBorrowable).rawValue > 0 ? moduleBorrowable : maximum_limit
        } else {
            SystemBorrowableAmount = moduleBorrowable
        }
        WDP.dpCoin(chainConfig, hardMoneyMarketDenom, SystemBorrowableAmount.stringValue, systemRemainBorrowableDenom, systemRemainBorrowableAmount)
        SystemBorrowableValue = SystemBorrowableAmount.multiplying(byPowerOf10: -dpDecimal).multiplying(by: targetPrice, withBehavior: WUtils.handler2Down)
        systemRemainBorrowableValue.attributedText = WUtils.getDPRawDollor(SystemBorrowableValue.stringValue, 2, systemRemainBorrowableValue.font)
    }
    
}
