//
//  KavaSwapListMyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class KavaSwapListMyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var coin1Img: UIImageView!
    @IBOutlet weak var coin2Img: UIImageView!
    @IBOutlet weak var marketNameLabel: UILabel!
    @IBOutlet weak var tvlLabel: UILabel!
    @IBOutlet weak var coin1AmountLabel: UILabel!
    @IBOutlet weak var coin1DenomLabel: UILabel!
    @IBOutlet weak var coin2AmountLabel: UILabel!
    @IBOutlet weak var coin2DenomLabel: UILabel!
    @IBOutlet weak var myValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
        
    func onBindSwpPool(_ baseChain: BaseChain, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?,
                       _ deposit: Kava_Swap_V1beta1_DepositResponse?, _ pool: Kava_Swap_V1beta1_PoolResponse?) {
        if (deposit == nil || pool == nil) { return }
        let coin1 = pool!.coins[0]
        let coin2 = pool!.coins[1]
        
        let my0 = deposit!.sharesValue[0]
        let my1 = deposit!.sharesValue[1]
        
        if let msAsset1 = BaseData.instance.getAsset(baseChain.apiName, coin1.denom),
           let msAsset2 = BaseData.instance.getAsset(baseChain.apiName, coin2.denom){
            coin1Img?.af.setImage(withURL: msAsset1.assetImg())
            coin2Img?.af.setImage(withURL: msAsset2.assetImg())
            
            marketNameLabel.text = msAsset1.symbol! + " : " + msAsset2.symbol!
            marketNameLabel.adjustsFontSizeToFitWidth = true
            
            let coin1Price = BaseData.instance.getPrice(msAsset1.coinGeckoId, true)
            let coin2Price = BaseData.instance.getPrice(msAsset2.coinGeckoId, true)
            let coin1Value = coin1.getAmount().multiplying(by: coin1Price).multiplying(byPowerOf10: -msAsset1.decimals!, withBehavior: handler12Down)
            let coin2Value = coin2.getAmount().multiplying(by: coin2Price).multiplying(byPowerOf10: -msAsset2.decimals!, withBehavior: handler12Down)
            WDP.dpValue(coin1Value.adding(coin2Value), nil, tvlLabel)
            WDP.dpCoin(msAsset1, coin1, nil, coin1DenomLabel, coin1AmountLabel, 3)
            WDP.dpCoin(msAsset2, coin2, nil, coin2DenomLabel, coin2AmountLabel, 3)
            
            
            let my1Value = my0.getAmount().multiplying(by: coin1Price).multiplying(byPowerOf10: -msAsset1.decimals!, withBehavior: handler12Down)
            let my2Value = my1.getAmount().multiplying(by: coin2Price).multiplying(byPowerOf10: -msAsset2.decimals!, withBehavior: handler12Down)
            WDP.dpValue(my1Value.adding(my2Value), nil, myValueLabel)
            
        }
    }
    
}
