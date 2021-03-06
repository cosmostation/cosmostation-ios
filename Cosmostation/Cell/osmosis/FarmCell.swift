//
//  FarmCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class FarmCell: UITableViewCell {
    
    @IBOutlet weak var poolIDLabel: UILabel!
    @IBOutlet weak var poolPairLabel: UILabel!
    @IBOutlet weak var poolArpLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        availableAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
    }
    
    func onBindView(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool, _ gauges: Array<Osmosis_Incentives_Gauge>) {
        let chainConfig = ChainOsmosis.init(.OSMOSIS_MAIN)
        let coin0 = Coin.init(pool.poolAssets[0].token.denom, pool.poolAssets[0].token.amount)
        let coin1 = Coin.init(pool.poolAssets[1].token.denom, pool.poolAssets[1].token.amount)
        
        poolIDLabel.text =  "#" + String(pool.id) + " EARNING"
        poolPairLabel.text = WUtils.getSymbol(chainConfig, coin0.denom) + " / " + WUtils.getSymbol(chainConfig, coin1.denom)
        
        if let lpCoin = BaseData.instance.mMyBalances_gRPC.filter({ $0.denom == "gamm/pool/" + String(pool.id) }).first {
            availableAmountLabel.attributedText = WDP.dpAmount(lpCoin.amount, availableAmountLabel.font, 18, 6)
            WDP.dpSymbol(chainConfig, lpCoin.denom, availableDenomLabel)
        } else {
            availableAmountLabel.attributedText = WDP.dpAmount("0", availableAmountLabel.font, 18, 6)
            WDP.dpSymbol(chainConfig, "gamm/pool/" + String(pool.id), availableDenomLabel)
        }
        
        let coin0Value = WUtils.usdValue(chainConfig, coin0.denom, NSDecimalNumber.init(string: coin0.amount))
        let coin1Value = WUtils.usdValue(chainConfig, coin1.denom, NSDecimalNumber.init(string: coin1.amount))
        let poolValue = coin0Value.adding(coin1Value)
//        print("poolValue ", poolValue)
        
        var thisTotalIncentiveValue = NSDecimalNumber.zero
        gauges.forEach { gauge in
            if (gauge.coins.count > 0 && gauge.distributedCoins.count > 0) {
                if (gauge.distributedCoins.count > 0) {
//                    let cIncentive = gauge.coins[0]
                    let cIncentive = gauge.coins.filter { $0.denom == OSMOSIS_MAIN_DENOM }.first?.amount ?? "0"
                    let dIncentive = gauge.distributedCoins[0].amount
                    
                    let thisIncentive = NSDecimalNumber.init(string: cIncentive).subtracting(NSDecimalNumber.init(string: dIncentive))
                    let thisIncentiveValue = WUtils.usdValue(chainConfig, OSMOSIS_MAIN_DENOM, thisIncentive)
                    
                    thisTotalIncentiveValue = thisTotalIncentiveValue.adding(thisIncentiveValue)
                    
                }
            }
        }
        let apr = thisTotalIncentiveValue.multiplying(by: NSDecimalNumber.init(value: 36500)).dividing(by: poolValue, withBehavior: WUtils.handler12)
        poolArpLabel.attributedText = WUtils.displayPercent(apr, poolArpLabel.font)
    }
    
}
