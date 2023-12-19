//
//  KavaEarnListMyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class KavaEarnListMyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var myLiquidityTitle: UILabel!
    @IBOutlet weak var myLiquidityAmountLabel: UILabel!
    @IBOutlet weak var myLiquidityDenomLabel: UILabel!
    @IBOutlet weak var myAvailableTitle: UILabel!
    @IBOutlet weak var myAvailableAmountLabel: UILabel!
    @IBOutlet weak var myAvailableDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindEarnsView(_ chain: CosmosClass, _ deposits: [Cosmos_Base_V1beta1_Coin]) {
        var sum = NSDecimalNumber.zero
        deposits.forEach { coin in
            sum = sum.adding(NSDecimalNumber.init(string: coin.amount))
        }
        
        if let kavaAsset = BaseData.instance.getAsset(chain.apiName, "ukava") {
            WDP.dpCoin(kavaAsset, sum, nil, myLiquidityDenomLabel, myLiquidityAmountLabel, kavaAsset.decimals)
            
            let availableAmount = chain.balanceAmount(chain.stakeDenom)
            WDP.dpCoin(kavaAsset, availableAmount, nil, myAvailableDenomLabel, myAvailableAmountLabel, kavaAsset.decimals)
        }
    }
    
}
