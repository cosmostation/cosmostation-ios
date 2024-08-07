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
        
//        amountLabel.isHidden = true
//        valueCurrencyLabel.isHidden = true
//        valueLabel.isHidden = true
        amountLabel.isHidden = false
        valueCurrencyLabel.isHidden = false
        valueLabel.isHidden = false
    }
    
    
    func onBindFeeCoin(_ chain: BaseChain, _ feeData: FeeData ) {
        WDP.dpValue(NSDecimalNumber.zero, valueCurrencyLabel, valueLabel)
        if let msAsset = BaseData.instance.getAsset(chain.apiName, feeData.denom!) {
            WDP.dpCoin(msAsset, nil, coinImg, symbolLabel, amountLabel, msAsset.decimals)
            
            if let cosmosFetcher = chain.getCosmosfetcher(),
               let balances = cosmosFetcher.cosmosBalances,
               let coin = balances.filter({ $0.denom == feeData.denom }).first {
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let amount = NSDecimalNumber(string: coin.amount)
                let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, coin, coinImg, symbolLabel, amountLabel, msAsset.decimals)
                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
            }
        }
    }
    
    func onBindBaseFeeCoin(_ chain: BaseChain, _ baseFee: Cosmos_Base_V1beta1_DecCoin ) {
        WDP.dpValue(NSDecimalNumber.zero, valueCurrencyLabel, valueLabel)
        if let msAsset = BaseData.instance.getAsset(chain.apiName, baseFee.denom) {
            WDP.dpCoin(msAsset, nil, coinImg, symbolLabel, amountLabel, msAsset.decimals)
            
            if let cosmosFetcher = chain.getCosmosfetcher(),
               let balances = cosmosFetcher.cosmosBalances,
               let coin = balances.filter({ $0.denom == baseFee.denom }).first {
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let amount = NSDecimalNumber(string: coin.amount)
                let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, coin, coinImg, symbolLabel, amountLabel, msAsset.decimals)
                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
            }
        }
    }
}
