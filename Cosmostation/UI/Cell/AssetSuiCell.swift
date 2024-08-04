//
//  AssetSuiCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/4/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SDWebImage

class AssetSuiCell: UITableViewCell {
    
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
    @IBOutlet weak var totalStakedTitle: UILabel!
    @IBOutlet weak var totalStakedLabel: UILabel!
    @IBOutlet weak var principalTitle: UILabel!
    @IBOutlet weak var principalLabel: UILabel!
    @IBOutlet weak var estimatedRewardTitle: UILabel!
    @IBOutlet weak var estimatedRewardLabel: UILabel!

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
    
    func bindStakeAsset(_ baseChain: BaseChain) {
        guard let stakeDenom = baseChain.stakeDenom,
              let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) else {
            return
        }
        
        coinImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        symbolLabel.text = msAsset.symbol?.uppercased()
        
        WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
        
        if let suiFetcher = (baseChain as? ChainSui)?.getSuiFetcher() {
            
            let allSui = suiFetcher.allSuiAmount().multiplying(byPowerOf10: -msAsset.decimals!)
            amountLabel?.attributedText = WDP.dpAmount(allSui.stringValue, amountLabel!.font, msAsset.decimals!)
            
            let allSuiValue = suiFetcher.allSuiValue()
            WDP.dpValue(allSuiValue, valueCurrencyLabel, valueLabel)
            
            let available = suiFetcher.balanceAmount(SUI_MAIN_DENOM).multiplying(byPowerOf10: -msAsset.decimals!)
            availableLabel?.attributedText = WDP.dpAmount(available.stringValue, availableLabel!.font, msAsset.decimals!)
            
            let staked = suiFetcher.stakedAmount().multiplying(byPowerOf10: -msAsset.decimals!)
            totalStakedLabel?.attributedText = WDP.dpAmount(staked.stringValue, totalStakedLabel!.font, msAsset.decimals!)
            
            let principal = suiFetcher.principalAmount().multiplying(byPowerOf10: -msAsset.decimals!)
            principalLabel?.attributedText = WDP.dpAmount(principal.stringValue, principalLabel!.font, msAsset.decimals!)
            
            let estimatedReward = suiFetcher.estimatedRewardAmount().multiplying(byPowerOf10: -msAsset.decimals!)
            estimatedRewardLabel?.attributedText = WDP.dpAmount(estimatedReward.stringValue, estimatedRewardLabel!.font, msAsset.decimals!)
            
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
                availableLabel.text = "✱✱✱✱"
                totalStakedLabel.text = "✱✱✱✱"
                principalLabel.text = "✱✱✱✱"
                estimatedRewardLabel.text = "✱✱✱✱"
            } else {
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
        }
    }
    
}
