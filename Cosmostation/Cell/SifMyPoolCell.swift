//
//  SifMyPoolCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/10/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class SifMyPoolCell: UITableViewCell {
    
    @IBOutlet weak var poolCardView: CardView!
    @IBOutlet weak var poolPairTokenImg: UIImageView!
    @IBOutlet weak var poolPairLabel: UILabel!
    
    @IBOutlet weak var totalLiquidityValueLabel: UILabel!
    @IBOutlet weak var liquidity1AmountLabel: UILabel!
    @IBOutlet weak var liquidity1DenomLabel: UILabel!
    @IBOutlet weak var liquidity2AmountLabel: UILabel!
    @IBOutlet weak var liquidity2DenomLabel: UILabel!
    
    @IBOutlet weak var myShareValueLabel: UILabel!
    @IBOutlet weak var myDepositCoin0AmountLabel: UILabel!
    @IBOutlet weak var myDepositCoin0DenomLabel: UILabel!
    @IBOutlet weak var myDepositCoin1AmountLabel: UILabel!
    @IBOutlet weak var myDepositCoin1DenomLabel: UILabel!
    
    @IBOutlet weak var availableCoin0AmountLabel: UILabel!
    @IBOutlet weak var availableCoin0DenomLabel: UILabel!
    @IBOutlet weak var availableCoin1AmountLabel: UILabel!
    @IBOutlet weak var availableCoin1DenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        liquidity1AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        liquidity2AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myDepositCoin0AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myDepositCoin1AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        availableCoin0AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        availableCoin1AmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindSifPoolView(_ pool: Sifnode_Clp_V1_Pool, _ myLp: Sifnode_Clp_V1_LiquidityProviderRes?) {
//        poolCardView.backgroundColor = UIColor.init(named: "sif_bg")
//        poolPairLabel.textColor = UIColor.init(named: "sif")
//        
//        let chainConfig = ChainSif.init(.SIF_MAIN)
//        let nf = WUtils.getNumberFormatter(2)
//        let rowanDecimal = WUtils.getDenomDecimal(chainConfig, SIF_MAIN_DENOM)
//        let rowanAmount = NSDecimalNumber.init(string: pool.nativeAssetBalance)
//        let externalDecimal = WUtils.getDenomDecimal(chainConfig, pool.externalAsset.symbol)
//        let externalAmount = NSDecimalNumber.init(string: pool.externalAssetBalance)
//        let exteranlDenom = pool.externalAsset.symbol
//        let poolValue = WUtils.getSifPoolValue(pool)
//        let poolValueFormatted = "$ " + nf.string(from: poolValue)!
//        WDP.dpSymbolImg(chainConfig, exteranlDenom, poolPairTokenImg)
//        
//        poolPairLabel.text = "ROWAN : " + WUtils.getSymbol(chainConfig, exteranlDenom)
//        totalLiquidityValueLabel.attributedText = WUtils.getDpAttributedString(poolValueFormatted, 2, totalLiquidityValueLabel.font)
//        WDP.dpSymbol(chainConfig, SIF_MAIN_DENOM, liquidity1DenomLabel)
//        WDP.dpSymbol(chainConfig, exteranlDenom, liquidity2DenomLabel)
//        liquidity1AmountLabel.attributedText = WDP.dpAmount(rowanAmount.stringValue, liquidity1AmountLabel.font, rowanDecimal, 6)
//        liquidity2AmountLabel.attributedText = WDP.dpAmount(externalAmount.stringValue, liquidity2AmountLabel.font, externalDecimal, 6)
//        
//        //dp my lp info
//        if (myLp != nil) {
//            let myShareValue = WUtils.getSifMyShareValue(pool, myLp!)
//            let myShareValueFormatted = "$ " + nf.string(from: myShareValue)!
//            myShareValueLabel.attributedText = WUtils.getDpAttributedString(myShareValueFormatted, 2, myShareValueLabel.font)
//            WDP.dpSymbol(chainConfig, SIF_MAIN_DENOM, myDepositCoin0DenomLabel)
//            WDP.dpSymbol(chainConfig, exteranlDenom, myDepositCoin1DenomLabel)
//            myDepositCoin0AmountLabel.attributedText = WDP.dpAmount(myLp!.nativeAssetBalance, myDepositCoin0AmountLabel.font, rowanDecimal, 6)
//            myDepositCoin1AmountLabel.attributedText = WDP.dpAmount(myLp?.externalAssetBalance, myDepositCoin1AmountLabel.font, externalDecimal, 6)
//        }
//        
//        //dp available
//        let availableRowan = BaseData.instance.getAvailable_gRPC(SIF_MAIN_DENOM)
//        let availableExternal = BaseData.instance.getAvailable_gRPC(exteranlDenom)
//        WDP.dpSymbol(chainConfig, SIF_MAIN_DENOM, availableCoin0DenomLabel)
//        WDP.dpSymbol(chainConfig, exteranlDenom, availableCoin1DenomLabel)
//        availableCoin0AmountLabel.attributedText = WDP.dpAmount(availableRowan, availableCoin0AmountLabel.font, rowanDecimal, 6)
//        availableCoin1AmountLabel.attributedText = WDP.dpAmount(availableExternal, availableCoin1AmountLabel.font, externalDecimal, 6)
    }
}
