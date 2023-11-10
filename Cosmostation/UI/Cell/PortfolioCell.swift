//
//  PortfolioCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SkeletonView

class PortfolioCell: UITableViewCell {

    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var logoImg2: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagLayer: UIStackView!
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var priceCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangePercentLabel: UILabel!
    
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        valueLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        currencyLabel.text = ""
        tagLayer.isHidden = true
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
    }
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        
        if (chain.evmCompatible) {
            tagLayer.isHidden = false
            evmCompatTag.isHidden = false
            
        } else if (!chain.isDefault) {
            tagLayer.isHidden = false
            legacyTag.isHidden = false
        }
        
        if (chain.fetched) {
            valueLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
            
//            if (chain is ChainBinanceBeacon) {
//                WDP.dpPrice(BNB_GECKO_ID, priceCurrencyLabel, priceLabel)
//                WDP.dpPriceChanged(BNB_GECKO_ID, priceChangeLabel, priceChangePercentLabel)
//
//            } else if (chain is ChainOkt60Keccak) {
//                WDP.dpPrice(ChainOkt996Keccak.OKT_GECKO_ID, priceCurrencyLabel, priceLabel)
//                WDP.dpPriceChanged(ChainOkt996Keccak.OKT_GECKO_ID, priceChangeLabel, priceChangePercentLabel)
//
//            } else {
//                if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
//                    WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
//                    WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
//                }
//            }
        } else {
            valueLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
        }
    }
    
}
