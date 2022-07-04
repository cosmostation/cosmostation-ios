//
//  CommonPoolCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/09/06.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class CommonPoolCell: UITableViewCell {
    
    @IBOutlet weak var poolPairLabel: UILabel!
    @IBOutlet weak var totalLiquidityValueLabel: UILabel!
    @IBOutlet weak var liquidity1AmountLabel: UILabel!
    @IBOutlet weak var liquidity1DenomLabel: UILabel!
    @IBOutlet weak var liquidity2AmountLabel: UILabel!
    @IBOutlet weak var liquidity2DenomLabel: UILabel!
    
    @IBOutlet weak var availableCoin0AmountLabel: UILabel!
    @IBOutlet weak var availableCoin0DenomLabel: UILabel!
    @IBOutlet weak var availableCoin1AmountLabel: UILabel!
    @IBOutlet weak var availableCoin1DenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        liquidity1AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        liquidity2AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        availableCoin0AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        availableCoin1AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindOsmoPoolView(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool) {
        //dp pool info
        let chainConfig = ChainOsmosis.init(.OSMOSIS_MAIN)
        let coin0 = Coin.init(pool.poolAssets[0].token.denom, pool.poolAssets[0].token.amount)
        let coin1 = Coin.init(pool.poolAssets[1].token.denom, pool.poolAssets[1].token.amount)
        let coin0Symbol =  WUtils.getSymbol(chainConfig, coin0.denom)
        let coin1Symbol = WUtils.getSymbol(chainConfig, coin1.denom)
        let coin0Decimal = WUtils.getDenomDecimal(chainConfig, coin0.denom)
        let coin1Decimal = WUtils.getDenomDecimal(chainConfig, coin1.denom)
        
        poolPairLabel.text = "#" + String(pool.id) + " " + coin0Symbol + " : " + coin1Symbol
        
        let coin0Value = WUtils.usdValue(chainConfig, coin0.denom, NSDecimalNumber.init(string: coin0.amount))
        let coin1Value = WUtils.usdValue(chainConfig, coin1.denom, NSDecimalNumber.init(string: coin1.amount))
        let poolValue = coin0Value.adding(coin1Value)
        let nf = WUtils.getNumberFormatter(2)
        let formatted = "$ " + nf.string(from: poolValue)!
        totalLiquidityValueLabel.attributedText = WUtils.getDpAttributedString(formatted, 2, totalLiquidityValueLabel.font)
        
        WDP.dpSymbol(chainConfig, coin0.denom, liquidity1DenomLabel)
        liquidity1DenomLabel.adjustsFontSizeToFitWidth = true
        WDP.dpSymbol(chainConfig, coin0.denom, liquidity2DenomLabel)
        liquidity2DenomLabel.adjustsFontSizeToFitWidth = true
        liquidity1AmountLabel.attributedText = WUtils.displayAmount2(coin0.amount, liquidity1AmountLabel.font, coin0Decimal, 6)
        liquidity2AmountLabel.attributedText = WUtils.displayAmount2(coin1.amount, liquidity2AmountLabel.font, coin1Decimal, 6)
        
        
        //dp available
        let availableCoin0 = BaseData.instance.getAvailable_gRPC(coin0.denom)
        let availableCoin1 = BaseData.instance.getAvailable_gRPC(coin1.denom)
        
        WDP.dpSymbol(chainConfig, coin0.denom, availableCoin0DenomLabel)
        availableCoin0DenomLabel.adjustsFontSizeToFitWidth = true
        WDP.dpSymbol(chainConfig, coin1.denom, availableCoin1DenomLabel)
        availableCoin1DenomLabel.adjustsFontSizeToFitWidth = true
        availableCoin0AmountLabel.attributedText = WUtils.displayAmount2(availableCoin0, availableCoin0AmountLabel.font, coin0Decimal, 6)
        availableCoin1AmountLabel.attributedText = WUtils.displayAmount2(availableCoin1, availableCoin1AmountLabel.font, coin1Decimal, 6)
    }
    
    func onBindKavaPoolView(_ pool: Kava_Swap_V1beta1_PoolResponse) {
        //dp pool info
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        let nf = WUtils.getNumberFormatter(2)
        let coin0 = pool.coins[0]
        let coin1 = pool.coins[1]
        let coin0Decimal = WUtils.getDenomDecimal(chainConfig, coin0.denom)
        let coin1Decimal = WUtils.getDenomDecimal(chainConfig, coin1.denom)
        let coin0price = WUtils.getKavaOraclePriceWithDenom(coin0.denom)
        let coin1price = WUtils.getKavaOraclePriceWithDenom(coin1.denom)
        let coin0Value = NSDecimalNumber.init(string: coin0.amount).multiplying(by: coin0price).multiplying(byPowerOf10: -coin0Decimal, withBehavior: WUtils.handler2)
        let coin1Value = NSDecimalNumber.init(string: coin1.amount).multiplying(by: coin1price).multiplying(byPowerOf10: -coin1Decimal, withBehavior: WUtils.handler2)

        poolPairLabel.text = WUtils.getSymbol(chainConfig, coin0.denom).uppercased() + " : " + WUtils.getSymbol(chainConfig, coin1.denom).uppercased()
        
        let poolValue = coin0Value.adding(coin1Value)
        let poolValueFormatted = "$ " + nf.string(from: poolValue)!
        totalLiquidityValueLabel.attributedText = WUtils.getDpAttributedString(poolValueFormatted, 2, totalLiquidityValueLabel.font)

        WDP.dpSymbol(chainConfig, coin0.denom, liquidity1DenomLabel)
        WDP.dpSymbol(chainConfig, coin1.denom, liquidity2DenomLabel)
        liquidity1AmountLabel.attributedText = WUtils.displayAmount2(coin0.amount, liquidity1AmountLabel.font, coin0Decimal, 6)
        liquidity2AmountLabel.attributedText = WUtils.displayAmount2(coin1.amount, liquidity2AmountLabel.font, coin1Decimal, 6)


        //dp available
        let availableCoin0 = BaseData.instance.getAvailableAmount_gRPC(coin0.denom)
        let availableCoin1 = BaseData.instance.getAvailableAmount_gRPC(coin1.denom)

        WDP.dpSymbol(chainConfig, coin0.denom, availableCoin0DenomLabel)
        WDP.dpSymbol(chainConfig, coin1.denom, availableCoin1DenomLabel)
        availableCoin0AmountLabel.attributedText = WUtils.displayAmount2(availableCoin0.stringValue, availableCoin0AmountLabel.font, coin0Decimal, 6)
        availableCoin1AmountLabel.attributedText = WUtils.displayAmount2(availableCoin1.stringValue, availableCoin1AmountLabel.font, coin1Decimal, 6)
    }
}
