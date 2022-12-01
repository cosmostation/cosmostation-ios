//
//  AssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/26.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AssetCell: UITableViewCell {
    
    @IBOutlet weak var assetImg: UIImageView!
    @IBOutlet weak var assetSymbol: UILabel!
    @IBOutlet weak var assetDescription: UILabel!
    @IBOutlet weak var assetAmount: UILabel!
    @IBOutlet weak var assetPrice: UILabel!
    @IBOutlet weak var assetPriceChange: UILabel!
    @IBOutlet weak var assetValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        assetAmount.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: Font_15_subTitle)
        assetValue.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_13_footnote)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.assetImg.af_cancelImageRequest()
        self.assetImg.image = UIImage(named: "tokenDefault")
        self.assetSymbol.textColor = UIColor.font05
        self.assetPrice.textColor = UIColor.font05
        self.assetPriceChange.textColor = UIColor.font05
        self.assetDescription.lineBreakMode = .byTruncatingTail
    }
    
    func onBindNativeAsset(_ chainConfig: ChainConfig?, _ asset: MintscanAsset?, _ coin: Coin) {
        if (chainConfig == nil || asset == nil) { return }
        let decimal = asset!.decimals
        let geckoId = asset!.coinGeckoId
        if let assetImgeUrl = asset!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = asset!.symbol
        assetDescription.text = asset!.description
        if (coin.denom == chainConfig?.stakeDenom) {
            let allAmount = WUtils.getAllMainAsset(coin.denom)
            assetAmount.attributedText = WDP.dpAmount(allAmount.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpAssetValue(geckoId, allAmount, decimal, assetValue.font)
            
        } else if (chainConfig?.chainType == .KAVA_MAIN) {
            let allAmount = WUtils.getKavaTokenAll(coin.denom)
            assetAmount.attributedText = WDP.dpAmount(allAmount.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpAssetValue(geckoId, allAmount, decimal, assetValue.font)
            
        } else {
            let available = NSDecimalNumber.init(string: coin.amount)
            assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpAssetValue(geckoId, available, decimal, assetValue.font)
        }
        onBindPriceView(geckoId)
    }
    
    func onBindIbcAsset(_ chainConfig: ChainConfig?, _ asset: MintscanAsset?, _ coin: Coin) {
        if (chainConfig == nil || asset == nil) { return }
        let decimal = asset!.decimals
        let geckoId = asset!.coinGeckoId
        let available = BaseData.instance.getAvailableAmount_gRPC(coin.denom)
        if let assetImgeUrl = asset!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = asset!.symbol
        assetDescription.text = WDP.dpPath(asset!.path)
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpAssetValue(geckoId, available, decimal, assetValue.font)
        onBindPriceView(geckoId)
    }
    
    func onBindBridgeAsset(_ chainConfig: ChainConfig?, _ asset: MintscanAsset?, _ coin: Coin) {
        if (chainConfig == nil || asset == nil) { return }
        let decimal = asset!.decimals
        let geckoId = asset!.coinGeckoId
        let available = BaseData.instance.getAvailableAmount_gRPC(coin.denom)
        if let assetImgeUrl = asset!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = asset!.symbol
        assetDescription.text = WDP.dpPath(asset!.path)
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpAssetValue(geckoId, available, decimal, assetValue.font)
        onBindPriceView(geckoId)
    }
    
    //for bind cw20 & erc20
    func onBindContractToken(_ chainConfig: ChainConfig?, _ token: MintscanToken?) {
        if (chainConfig == nil || token == nil) { return }
        let decimal = token!.decimals
        let geckoId = token!.coinGeckoId
        let available = NSDecimalNumber.init(string: token!.amount)
        if let assetImgeUrl = token!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = token!.symbol
        assetDescription.text = token!.description
        assetDescription.lineBreakMode = .byTruncatingMiddle
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpAssetValue(geckoId, available, decimal, assetValue.font)
        onBindPriceView(geckoId)
    }
    
    //for Legacy lcd (binance, okc)
    func onBindStakingCoin(_ chainConfig: ChainConfig?, _ balance: Balance?) {
        if (chainConfig == nil || balance == nil) { return }
        if (chainConfig?.chainType == .BINANCE_MAIN && balance?.balance_denom == BNB_MAIN_DENOM) {
            if let bnbToken = BaseData.instance.bnbToken(BNB_MAIN_DENOM) {
                let amount = BaseData.instance.allBnbTokenAmount(BNB_MAIN_DENOM)
                assetImg.image = UIImage(named: "tokenBinance")
                assetSymbol.text = bnbToken.original_symbol.uppercased()
                assetDescription.text = bnbToken.name
                assetAmount.attributedText = WDP.dpAmount(amount.stringValue, assetAmount.font!, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue("bnb", amount, 0, assetValue.font)
            }
            
        } else if (chainConfig?.chainType == .OKEX_MAIN && balance?.balance_denom == OKEX_MAIN_DENOM) {
            if let okToken = WUtils.getOkToken(OKEX_MAIN_DENOM) {
                let amount = WUtils.getAllExToken(OKEX_MAIN_DENOM)
                assetImg.image = UIImage(named: "tokenOkc")
                assetSymbol.text = okToken.symbol!.uppercased()
                assetDescription.text = okToken.description
                assetAmount.attributedText = WDP.dpAmount(amount.stringValue, assetAmount.font!, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue("okt", amount, 0, assetValue.font)
            }
        }
        onBindPriceView(balance!.balance_denom)
    }
    
    func onBindEtcCoin(_ chainConfig: ChainConfig?, _ balance: Balance?) {
        if (chainConfig == nil || balance == nil) { return }
        if (chainConfig?.chainType == .BINANCE_MAIN) {
            if let bnbToken = BaseData.instance.bnbToken(balance!.balance_denom) {
                assetImg.af_setImage(withURL: URL(string: BinanceTokenImgUrl + bnbToken.original_symbol + ".png")!)
                assetSymbol.text = bnbToken.original_symbol.uppercased()
                assetDescription.text = bnbToken.name
                
                let tokenAmount = BaseData.instance.allBnbTokenAmount(balance!.balance_denom)
                let convertAmount = WUtils.bnbConvertAmount(balance!.balance_denom)
                assetAmount.attributedText = WDP.dpAmount(tokenAmount.stringValue, assetAmount.font, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue("bnb", convertAmount, 0, assetValue.font)
                assetPrice.attributedText = WUtils.dpBnbTokenPrice(balance!.balance_denom, assetPrice.font)
                assetPriceChange.text = ""
            }
            
        } else if (chainConfig?.chainType == .OKEX_MAIN) {
            if let okToken = WUtils.getOkToken(balance!.balance_denom) {
                assetImg.af_setImage(withURL: URL(string: OKTokenImgUrl + okToken.original_symbol! + ".png")!)
                assetSymbol.text = okToken.original_symbol?.uppercased()
                assetDescription.text = okToken.description
                
                let tokenAmount = WUtils.getAllExToken(balance!.balance_denom)
                assetAmount.attributedText = WDP.dpAmount(tokenAmount.stringValue, assetAmount.font, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue("okt", NSDecimalNumber.zero, 0, assetValue.font)
                assetPrice.text = "-"
                assetPriceChange.text = ""
            }
        }
    }
    
    func onBindPriceView(_ geckoId: String) {
        assetPrice.attributedText = WUtils.dpPrice(geckoId, assetPrice.font)
        assetPriceChange.attributedText = WUtils.dpPriceChange(geckoId, assetPriceChange.font)
        
        let changePrice = WUtils.priceChange(geckoId)
        WDP.setPriceColor(assetPriceChange, changePrice)
    }
}
