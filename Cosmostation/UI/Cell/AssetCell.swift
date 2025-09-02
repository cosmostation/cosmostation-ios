//
//  AssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class AssetCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var coinImg: CircleImageView!
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
        WDP.dpPrice(nil, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(nil, priceChangeLabel, priceChangePercentLabel)
    }
    
    override func prepareForReuse() {
        coinImg.sd_cancelCurrentImageLoad()
        coinImg.image = UIImage(named: "tokenDefault")
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        symbolLabel.textColor = .color01
        priceChangeLabel.text = ""
        priceLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
        priceLabel.isHidden = false
        priceChangeLabel.isHidden = false
        WDP.dpPrice(nil, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(nil, priceChangeLabel, priceChangePercentLabel)
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
           let msAsset = BaseData.instance.getAsset(oktChain.apiName, coin["denom"].stringValue) {
            symbolLabel.text = msAsset.symbol?.uppercased()
            priceCurrencyLabel.text = msAsset.description
            coinImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            
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
        if let evmFetcher = baseChain.getEvmfetcher(),
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, baseChain.gasAssetSymbol()) {
            symbolLabel.text = msAsset.symbol?.uppercased()
            coinImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            
            let dpAmount = evmFetcher.evmBalances.multiplying(byPowerOf10: -18, withBehavior: handler18Down)
            let value = evmFetcher.allCoinValue()
            WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
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
    
    
    func bindSuiAsset(_ baseChain: BaseChain, _ balance: (String, NSDecimalNumber)) {
        if let suiFetcher = (baseChain as? ChainSui)?.getSuiFetcher() {
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, balance.0) {
                WDP.dpCoin(msAsset, balance.1, coinImg, symbolLabel, amountLabel, 6)
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
                
            } else if let metaData = suiFetcher.suiCoinMeta[balance.0] {
                coinImg.sd_setImage(with: metaData.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
                symbolLabel.text = metaData["symbol"].stringValue
                let dpAmount = balance.1.multiplying(byPowerOf10: -metaData["decimals"].int16Value, withBehavior: handler18Down)
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 6)
                
            } else {
                symbolLabel.text = balance.0.suiCoinSymbol()
                let dpAmount = balance.1.multiplying(byPowerOf10: -9, withBehavior: handler18Down)
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 6)
                
            }
            
            let value = suiFetcher.balanceValue(balance.0)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
        }
        
        if (BaseData.instance.getHideValue()) {
            hidenValueLabel.isHidden = false
            
        } else {
            amountLabel.isHidden = false
            valueCurrencyLabel.isHidden = false
            valueLabel.isHidden = false
        }
    }
    
    func bindIotaAsset(_ baseChain: BaseChain, _ balance: (String, NSDecimalNumber)) {
        if let fetcher = (baseChain as? ChainIota)?.getIotaFetcher() {
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, balance.0) {
                WDP.dpCoin(msAsset, balance.1, coinImg, symbolLabel, amountLabel, 6)
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
                
            } else if let metaData = fetcher.iotaCoinMeta[balance.0] {
                coinImg.sd_setImage(with: metaData.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
                symbolLabel.text = metaData["symbol"].stringValue
                let dpAmount = balance.1.multiplying(byPowerOf10: -metaData["decimals"].int16Value, withBehavior: handler18Down)
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 6)
                
            } else {
                symbolLabel.text = balance.0.iotaCoinSymbol()
                let dpAmount = balance.1.multiplying(byPowerOf10: -9, withBehavior: handler18Down)
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 6)
                
            }
            
            let value = fetcher.balanceValue(balance.0)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
        }
        
        if (BaseData.instance.getHideValue()) {
            hidenValueLabel.isHidden = false
            
        } else {
            amountLabel.isHidden = false
            valueCurrencyLabel.isHidden = false
            valueLabel.isHidden = false
        }
    }

    
    func bindGnoClassAsset(_ baseChain: BaseChain, _ coin: Cosmos_Base_V1beta1_Coin) {
        if let gnoFether = (baseChain as? ChainGno)?.getGnoFetcher(),
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, coin.denom) {
            let value = gnoFether.denomValue(coin.denom)
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
    
    func bindGnoClassToken(_ baseChain: BaseChain, _ token: MintscanToken) {
        if let gnoFetcher = (baseChain as? ChainGno)?.getGnoFetcher() {
            let value = gnoFetcher.tokenValue(token.address!)
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
    
    func bindSolanaClassAsset(_ baseChain: BaseChain) {
        if let solanaFetcher = (baseChain as? ChainSolana)?.getSolanaFetcher(),
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, baseChain.coinSymbol) {
            WDP.dpCoin(msAsset, solanaFetcher.balanceAmount(), coinImg, symbolLabel, amountLabel, 6)
            WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
            } else {
                WDP.dpValue(solanaFetcher.balanceValue(), valueCurrencyLabel, valueLabel)
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
        }
    }
    
    func bindSplToken(_ baseChain: BaseChain, _ tokenInfo: JSON) {
        if let solanaFetcher = (baseChain as? ChainSolana)?.getSolanaFetcher(),
           let splToken = solanaFetcher.mintscanSplTokens.filter({ $0.address == tokenInfo["mint"].stringValue }).first {
            let value = solanaFetcher.splTokenValue(splToken.address ?? "")
            WDP.dpToken(splToken, coinImg, symbolLabel, amountLabel, 6)
            WDP.dpPrice(splToken.coinGeckoId, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(splToken.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
            } else {
                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
            
        } else {
            let amount = tokenInfo["tokenAmount"]["uiAmountString"].stringValue
            let decimals = tokenInfo["tokenAmount"]["decimals"].int16Value
            coinImg.image = UIImage(named: "tokenDefault")
            symbolLabel.text = "UNKNOWN"
            WDP.dpPrice("", priceCurrencyLabel, priceLabel)
            amountLabel?.attributedText = WDP.dpAmount(amount, amountLabel!.font, decimals)
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
            } else {
                WDP.dpValue(NSDecimalNumber.zero, valueCurrencyLabel, valueLabel)
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
        }
    }
}
