//
//  RewardDetailCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Kingfisher

class RewardDetailCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
    }
    
    override func prepareForReuse() {
        coinImg.kf.cancelDownloadTask()
        coinImg.image = UIImage(named: "tokenDefault")
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
    }
    
    func onBindRewardDetail(_ baseChain: BaseChain, _ reward: Cosmos_Base_V1beta1_Coin) {
        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, reward.denom) {
            WDP.dpCoin(msAsset, reward, coinImg, symbolLabel, amountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: reward.amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
            
        } else {
            symbolLabel.text = "Unknown"
        }
    }
    
}
