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
        self.assetSymbol.textColor = UIColor(named: "_font05")
        self.assetPrice.textColor = UIColor(named: "_font05")
        self.assetPriceChange.textColor = UIColor(named: "_font05")
        self.assetDescription.lineBreakMode = .byTruncatingTail
    }
    
    func onBindNativeAsset(_ chainConfig: ChainConfig?, _ asset: MintscanAsset?, _ coin: Coin) {
        if (chainConfig == nil || asset == nil) { return }
        let decimal = asset!.decimal
        if let assetImgeUrl = asset!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = asset!.dp_denom
        assetDescription.text = asset!.description
        if (coin.denom == chainConfig?.stakeDenom) {
            let allAmount = WUtils.getAllMainAsset(coin.denom)
            assetAmount.attributedText = WDP.dpAmount(allAmount.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpAssetValue(asset!.base_denom.lowercased(), allAmount, decimal, assetValue.font)
            
        } else if (chainConfig?.chainType == .KAVA_MAIN) {
            let allAmount = WUtils.getKavaTokenAll(coin.denom)
            assetAmount.attributedText = WDP.dpAmount(allAmount.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpAssetValue(asset!.base_denom.lowercased(), allAmount, decimal, assetValue.font)
            
        } else {
            let available = NSDecimalNumber.init(string: coin.amount)
            assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpAssetValue(asset!.base_denom.lowercased(), available, decimal, assetValue.font)
        }
        onBindPriceView(asset!.base_denom)
    }
    
    func onBindIbcAsset(_ chainConfig: ChainConfig?, _ asset: MintscanAsset?, _ coin: Coin) {
        if (chainConfig == nil || asset == nil) { return }
        let decimal = asset!.decimal
        let available = BaseData.instance.getAvailableAmount_gRPC(coin.denom)
        if let assetImgeUrl = asset!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = asset!.dp_denom
        assetDescription.text = WDP.dpPath(asset!.path)
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpAssetValue(asset!.base_denom.lowercased(), available, decimal, assetValue.font)
        onBindPriceView(asset!.base_denom)
    }
    
    func onBindBridgeAsset(_ chainConfig: ChainConfig?, _ asset: MintscanAsset?, _ coin: Coin) {
        if (chainConfig == nil || asset == nil) { return }
        let decimal = asset!.decimal
        let available = BaseData.instance.getAvailableAmount_gRPC(coin.denom)
        if let assetImgeUrl = asset!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = asset!.dp_denom
        assetDescription.text = WDP.dpPath(asset!.path)
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpAssetValue(asset!.base_denom.lowercased(), available, decimal, assetValue.font)
        onBindPriceView(asset!.base_denom)
    }
    
    //for bind cw20 & erc20
    func onBindContractToken(_ chainConfig: ChainConfig?, _ token: MintscanToken?) {
        if (chainConfig == nil || token == nil) { return }
        let decimal = token!.decimal
        let available = NSDecimalNumber.init(string: token!.amount)
        if let assetImgeUrl = token!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = token!.denom.uppercased()
//        assetDescription.text = token?.contract_address
        assetDescription.text = ""
        assetDescription.lineBreakMode = .byTruncatingMiddle
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpAssetValue(token!.denom, available, decimal, assetValue.font)
        onBindPriceView(token!.denom)
    }
    
    //for Legacy lcd (binance, okc)
    func onBindStakingCoin(_ chainConfig: ChainConfig?, _ balance: Balance?) {
        if (chainConfig == nil || balance == nil) { return }
        if (chainConfig?.chainType == .BINANCE_MAIN && balance?.balance_denom == BNB_MAIN_DENOM) {
            if let bnbToken = WUtils.getBnbToken(BNB_MAIN_DENOM) {
                let amount = WUtils.getAllBnbToken(BNB_MAIN_DENOM)
                assetImg.image = UIImage(named: "tokenBinance")
                assetSymbol.text = bnbToken.original_symbol.uppercased()
                assetDescription.text = bnbToken.name
                assetAmount.attributedText = WDP.dpAmount(amount.stringValue, assetAmount.font!, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue(BNB_MAIN_DENOM, amount, 0, assetValue.font)
            }
            
        } else if (chainConfig?.chainType == .OKEX_MAIN && balance?.balance_denom == OKEX_MAIN_DENOM) {
            if let okToken = WUtils.getOkToken(OKEX_MAIN_DENOM) {
                let amount = WUtils.getAllExToken(OKEX_MAIN_DENOM)
                assetImg.image = UIImage(named: "tokenOkc")
                assetSymbol.text = okToken.symbol!.uppercased()
                assetDescription.text = okToken.description
                assetAmount.attributedText = WDP.dpAmount(amount.stringValue, assetAmount.font!, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue(OKEX_MAIN_DENOM, amount, 0, assetValue.font)
            }
        }
        onBindPriceView(balance!.balance_denom)
    }
    
    func onBindEtcCoin(_ chainConfig: ChainConfig?, _ balance: Balance?) {
        if (chainConfig == nil || balance == nil) { return }
        if (chainConfig?.chainType == .BINANCE_MAIN) {
            if let bnbToken = WUtils.getBnbToken(balance!.balance_denom) {
                assetImg.af_setImage(withURL: URL(string: BinanceTokenImgUrl + bnbToken.original_symbol + ".png")!)
                assetSymbol.text = bnbToken.original_symbol.uppercased()
                assetDescription.text = bnbToken.name
                
                let tokenAmount = WUtils.getAllBnbToken(balance!.balance_denom)
                let convertAmount = WUtils.getBnbConvertAmount(balance!.balance_denom)
                assetAmount.attributedText = WDP.dpAmount(tokenAmount.stringValue, assetAmount.font, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue(BNB_MAIN_DENOM, convertAmount, 0, assetValue.font)
                assetPrice.attributedText = WUtils.dpBnbTokenUserCurrencyPrice(balance!.balance_denom, assetPrice.font)
                assetPriceChange.text = ""
            }
            
        } else if (chainConfig?.chainType == .OKEX_MAIN) {
            if let okToken = WUtils.getOkToken(balance!.balance_denom) {
                assetImg.af_setImage(withURL: URL(string: OKTokenImgUrl + okToken.original_symbol! + ".png")!)
                assetSymbol.text = okToken.original_symbol?.uppercased()
                assetDescription.text = okToken.description
                
                let tokenAmount = WUtils.getAllExToken(balance!.balance_denom)
                let convertedAmount = WUtils.convertTokenToOkt(balance!.balance_denom)
                assetAmount.attributedText = WDP.dpAmount(tokenAmount.stringValue, assetAmount.font, 0, 6)
                assetValue.attributedText = WUtils.dpAssetValue(OKEX_MAIN_DENOM, convertedAmount, 0, assetValue.font)
                assetPrice.text = "-"
                assetPriceChange.text = ""
            }
        }
    }
    
    
    
    func onBindPriceView(_ priceDenom: String) {
        assetPrice.attributedText = WUtils.dpPrice(priceDenom, assetPrice.font)
        assetPriceChange.attributedText = WUtils.dpPriceChange2(priceDenom, assetPriceChange.font)
        
        let changePrice = WUtils.priceChange(priceDenom)
        if (changePrice.compare(NSDecimalNumber.zero).rawValue > 0) {
            assetPriceChange.textColor = UIColor(named: "_voteYes")
        } else if (changePrice.compare(NSDecimalNumber.zero).rawValue < 0) {
            assetPriceChange.textColor = UIColor(named: "_voteNo")
        } else if (changePrice.compare(NSDecimalNumber.zero).rawValue == 0) {
            assetPriceChange.text = ""
        }
    }
}
