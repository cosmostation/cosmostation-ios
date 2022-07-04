//
//  HardDetailAssetsCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class HardDetailAssetsCell: UITableViewCell {

    @IBOutlet weak var marketLayer: UIView!
    @IBOutlet weak var kavaLayer: UIView!
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketDenom: UILabel!
    @IBOutlet weak var marketAmountLabel: UILabel!
    @IBOutlet weak var marketValueLabel: UILabel!
    @IBOutlet weak var kavaAmountLabel: UILabel!
    @IBOutlet weak var kavaValueLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindHardDetailAsset(_ hardMoneyMarketDenom: String, _ hardParam: Kava_Hard_V1beta1_Params) {
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        WDP.dpSymbolImg(chainConfig, hardMoneyMarketDenom, marketImg)
        WDP.dpSymbol(chainConfig, hardMoneyMarketDenom, marketDenom)

        if (hardMoneyMarketDenom == KAVA_MAIN_DENOM) {
            marketLayer.isHidden = true
        }

        let dpDecimal = WUtils.getDenomDecimal(chainConfig, hardMoneyMarketDenom)
        let targetAvailable = BaseData.instance.getAvailableAmount_gRPC(hardMoneyMarketDenom)
        let targetPrice = BaseData.instance.getKavaOraclePrice(hardParam.getHardMoneyMarket(hardMoneyMarketDenom)?.spotMarketID)
        let marketValue = targetAvailable.multiplying(byPowerOf10: -dpDecimal).multiplying(by: targetPrice, withBehavior: WUtils.handler2Down)
        marketAmountLabel.attributedText = WUtils.displayAmount2(targetAvailable.stringValue, marketAmountLabel.font!, dpDecimal, dpDecimal)
        marketValueLabel.attributedText = WUtils.getDPRawDollor(marketValue.stringValue, 2, marketValueLabel.font)


        let kavaAvailable = BaseData.instance.getAvailableAmount_gRPC(KAVA_MAIN_DENOM)
        let kavaPrice = BaseData.instance.getKavaOraclePrice("kava:usd:30")
        let kavaValue = kavaAvailable.multiplying(byPowerOf10: -6).multiplying(by: kavaPrice, withBehavior: WUtils.handler2Down)
        kavaAmountLabel.attributedText = WUtils.displayAmount2(kavaAvailable.stringValue, kavaAmountLabel.font!, 6, 6)
        kavaValueLable.attributedText = WUtils.getDPRawDollor(kavaValue.stringValue, 2, kavaValueLable.font)
    }
    
}
