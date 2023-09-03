//
//  AssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

class AssetCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangePercentLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        coinImg.af.cancelImageRequest()
    }
    
    func bindCosmosClassAsset(_ baseChain: CosmosClass, _ coin: Cosmos_Base_V1beta1_Coin) {
        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, coin.denom) {
            let value = baseChain.denomValue(coin.denom)
            WDP.dpCoin(msAsset, coin, coinImg, symbolLabel, amountLabel, 6)
            WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
        }
    }
    
    func bindCw20Token(_ baseChain: CosmosClass, _ token: MintscanToken) {
        let value = baseChain.cw20Value(token.address!)
        WDP.dpToken(token, coinImg, symbolLabel, amountLabel, 6)
        WDP.dpPrice(token.coinGeckoId, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(token.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
        WDP.dpValue(value, valueCurrencyLabel, valueLabel)
    }
    
}
