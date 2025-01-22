//
//  AssetBtcCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SDWebImage

class AssetBtcCell: UITableViewCell {
    
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
    
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var pendingTitle: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        coinImg.sd_cancelCurrentImageLoad()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    
    func bindBtcAsset(_ baseChain: BaseChain) {
        symbolLabel.text = baseChain.coinSymbol
        coinImg.image =  UIImage.init(named: baseChain.coinLogo)
        
        WDP.dpPrice(baseChain.coinGeckoId, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(baseChain.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
        
        if let btcFetcher = (baseChain as? ChainBitCoin86)?.getBtcFetcher() {
            let msPrice = BaseData.instance.getPrice(baseChain.coinGeckoId)
            let avaibaleAmount = btcFetcher.btcBalances.multiplying(byPowerOf10: -8, withBehavior: handler8Down)
            let pendingInputAmount = btcFetcher.btcPendingInput.multiplying(byPowerOf10: -8, withBehavior: handler8Down)
            let totalAmount = avaibaleAmount.adding(pendingInputAmount)
            let value = totalAmount.multiplying(by: msPrice, withBehavior: handler6)
            
            amountLabel?.attributedText = WDP.dpAmount(totalAmount.stringValue, amountLabel!.font, 6)
            availableLabel?.attributedText = WDP.dpAmount(avaibaleAmount.stringValue, availableLabel!.font, 6)
            pendingLabel?.attributedText = WDP.dpAmount(pendingInputAmount.stringValue, pendingLabel!.font, 6)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
            
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
                availableLabel.text = "✱✱✱✱"
                pendingLabel.text = "✱✱✱✱"
            } else {
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
        }
    }
    
}
