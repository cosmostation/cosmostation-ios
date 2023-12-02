//
//  AssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

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
    @IBOutlet weak var hidenValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        coinImg.af.cancelImageRequest()
        coinImg.image = UIImage(named: "tokenDefault")
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    func bindCosmosClassAsset(_ baseChain: CosmosClass, _ coin: Cosmos_Base_V1beta1_Coin) {
        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, coin.denom) {
            let value = baseChain.denomValue(coin.denom)
            WDP.dpCoin(msAsset, coin, coinImg, symbolLabel, amountLabel, 6)
            WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
            } else {
                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
        }
    }
    
    func bindToken(_ baseChain: CosmosClass, _ token: MintscanToken) {
        let value = baseChain.tokenValue(token.address!)
        WDP.dpToken(token, coinImg, symbolLabel, amountLabel, 6)
        WDP.dpPrice(token.coinGeckoId, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(token.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
        if (BaseData.instance.getHideValue()) {
            hidenValueLabel.isHidden = false
        } else {
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
            amountLabel.isHidden = false
            valueCurrencyLabel.isHidden = false
            valueLabel.isHidden = false
        }
    }
    
    
    func bindBeaconAsset(_ baseChain: CosmosClass, _ coin: JSON) {
        if let bnbChain = baseChain as? ChainBinanceBeacon,
            let token = bnbChain.lcdBeaconTokens.filter({ $0["symbol"].string == coin["symbol"].string }).first {
                let original_symbol = token["original_symbol"].stringValue
                
                symbolLabel.text = original_symbol
                priceCurrencyLabel.text = token["name"].string
                coinImg.af.setImage(withURL: ChainBinanceBeacon.assetImg(original_symbol))
                
                let availableAmount = bnbChain.lcdBalanceAmount(coin["symbol"].stringValue)
                amountLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, amountLabel!.font, 8)
                amountLabel.isHidden = false
                priceLabel.isHidden = true
                priceChangeLabel.isHidden = true
                priceChangePercentLabel.isHidden = true
        }
    }
    
    func bindOktAsset(_ baseChain: CosmosClass, _ coin: JSON) {
        if let oktChain = baseChain as? ChainOkt60Keccak,
           let token = oktChain.lcdOktTokens.filter({ $0["symbol"].string == coin["denom"].string }).first {
                let original_symbol = token["original_symbol"].stringValue
                
                symbolLabel.text = original_symbol.uppercased()
                priceCurrencyLabel.text = token["description"].string
                coinImg.af.setImage(withURL: ChainOkt60Keccak.assetImg(original_symbol))
                
                let availableAmount = oktChain.lcdBalanceAmount(coin["denom"].stringValue)
                amountLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, amountLabel!.font, 18)
                amountLabel.isHidden = false
                priceLabel.isHidden = true
                priceChangeLabel.isHidden = true
                priceChangePercentLabel.isHidden = true
        }
    }
    
}
