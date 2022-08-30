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
            assetValue.attributedText = WUtils.dpValueUserCurrency(asset!.base_denom.lowercased(), allAmount, decimal, assetValue.font)
            
        } else {
            let available = NSDecimalNumber.init(string: coin.amount)
            assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
            assetValue.attributedText = WUtils.dpValueUserCurrency(asset!.base_denom.lowercased(), available, decimal, assetValue.font)
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
        assetValue.attributedText = WUtils.dpValueUserCurrency(asset!.base_denom.lowercased(), available, decimal, assetValue.font)
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
        assetValue.attributedText = WUtils.dpValueUserCurrency(asset!.base_denom.lowercased(), available, decimal, assetValue.font)
        onBindPriceView(asset!.base_denom)
    }
    
    func onBindContractToken(_ chainConfig: ChainConfig?, _ token: MintscanToken?) {
        if (chainConfig == nil || token == nil) { return }
        let decimal = token!.decimal
        let available = NSDecimalNumber.init(string: token!.amount)
        if let assetImgeUrl = token!.assetImg() {
            assetImg.af_setImage(withURL: assetImgeUrl)
        }
        assetSymbol.text = token!.denom.uppercased()
        assetDescription.text = token?.contract_address
        assetDescription.lineBreakMode = .byTruncatingMiddle
        assetAmount.attributedText = WDP.dpAmount(available.stringValue, assetAmount.font!, decimal, 6)
        assetValue.attributedText = WUtils.dpValueUserCurrency(token!.denom, available, decimal, assetValue.font)
        onBindPriceView(token!.denom)
    }
    
    func onBindPriceView(_ priceDenom: String) {
        assetPrice.attributedText = WUtils.dpPerUserCurrencyValue(priceDenom, assetPrice.font)
        assetPriceChange.attributedText = WUtils.dpValueChange2(priceDenom, assetPriceChange.font)
        
        let changeValue = WUtils.valueChange(priceDenom)
        if (changeValue.compare(NSDecimalNumber.zero).rawValue >= 0) {
            assetPriceChange.textColor = UIColor(named: "_voteYes")
        } else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) {
            assetPriceChange.textColor = UIColor(named: "_voteNo")
        }
    }
}
