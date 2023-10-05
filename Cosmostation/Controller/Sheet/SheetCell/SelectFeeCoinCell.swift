//
//  SelectFeeCoinCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectFeeCoinCell: UITableViewCell {
    
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
    }
    
    
    func onBindFeeCoin(_ chain: CosmosClass, _ feeData: FeeData ) {
//        if let coin = chain.cosmosBalances.filter({ $0.denom == feeData.denom }).first,
//           let msAsset = BaseData.instance.getAsset(chain.apiName, feeData.denom!) {
//            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
//            let amount = NSDecimalNumber(string: coin.amount)
//            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
//            
//            WDP.dpCoin(msAsset, coin, coinImg, symbolLabel, amountLabel, msAsset.decimals)
//            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
//        }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, feeData.denom!) {
            symbolLabel?.text = msAsset.symbol
            coinImg?.af.setImage(withURL: msAsset.assetImg())
        }
        
    }
}
