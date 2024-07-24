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
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        priceLabel.text = ""
        priceChangeLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        coinImg.af.cancelImageRequest()
        coinImg.image = UIImage(named: "tokenDefault")
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        priceChangeLabel.text = ""
        priceLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
        priceLabel.isHidden = false
        priceChangeLabel.isHidden = false
    }
    
    func bindCosmosClassAsset(_ baseChain: BaseChain, _ coin: Cosmos_Base_V1beta1_Coin) {
        if let cosmosFetcher = baseChain.getCosmosfetcher(),
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, coin.denom) {
            let value = cosmosFetcher.denomValue(coin.denom)
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
    
    func bindCosmosClassToken(_ baseChain: BaseChain, _ token: MintscanToken) {
        if let cosmosFetcher = baseChain.getCosmosfetcher() {
            let value = cosmosFetcher.tokenValue(token.address!)
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
    }
    
    func bindOktAsset(_ oktChain: ChainOktEVM, _ coin: JSON) {
        if let oktFetcher = oktChain.oktFetcher,
           let token = oktFetcher.oktTokens.filter({ $0["symbol"].string == coin["denom"].string }).first {
            let original_symbol = token["original_symbol"].stringValue
            
            symbolLabel.text = original_symbol.uppercased()
            priceCurrencyLabel.text = token["description"].string
            coinImg.af.setImage(withURL: ChainOktEVM.assetImg(original_symbol))
            
            let availableAmount = oktFetcher.oktBalanceAmount(coin["denom"].stringValue)
            amountLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, amountLabel!.font, 18)
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
            } else {
                amountLabel.isHidden = false
            }
            priceLabel.isHidden = true
            priceChangeLabel.isHidden = true
            priceChangePercentLabel.isHidden = true
        }
    }
    
    
    func bindEvmClassCoin(_ baseChain: BaseChain) {
        symbolLabel.text = baseChain.coinSymbol
        coinImg.image =  UIImage.init(named: baseChain.coinLogo)
        
        if let evmFetcher = baseChain.getEvmfetcher() {
            let dpAmount = evmFetcher.evmBalances.multiplying(byPowerOf10: -18, withBehavior: handler18Down)
            let value = evmFetcher.allCoinValue()
            WDP.dpPrice(baseChain.coinGeckoId, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(baseChain.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
            amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 6)
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
    
    func bindEvmClassToken(_ baseChain: BaseChain, _ token: MintscanToken) {
        if let evmFetcher = baseChain.getEvmfetcher() {
            let value = evmFetcher.tokenValue(token.address!)
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
    }
    
}
