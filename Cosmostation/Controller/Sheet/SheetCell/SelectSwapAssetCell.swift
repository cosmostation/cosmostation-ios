//
//  SelectSwapAssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectSwapAssetCell: UITableViewCell {
    
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    
    func onBindAsset(_ chain: CosmosClass, _ asset: JSON, _ balances: [Cosmos_Base_V1beta1_Coin] ) {
        symbolLabel.text = asset["symbol"].stringValue
        
        if let msAsset = BaseData.instance.getAsset(chain.apiName, asset["denom"].stringValue) {
            let coin = balances.filter({ $0.denom == asset["denom"].stringValue }).first
            WDP.dpCoin(msAsset, coin, coinImg, symbolLabel, amountLabel, 6)
            
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: coin?.amount ?? "0")
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
        }
    }
}
