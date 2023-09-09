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
    @IBOutlet weak var lagacyLayer: UIStackView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var priceCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangePercentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        valueLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        currencyLabel.text = ""
        lagacyLayer.isHidden = true
    }
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()

        if (!chain.isDefault) {
            lagacyLayer.isHidden = false
            pathLabel.text = chain.getHDPath(account.lastHDPath)
        }
        if (chain is ChainKava60) {
            tagLabel.text = "EVM"
        } else {
            tagLabel.text = "LEGACY"
        }
        
        if (chain.fetched) {
            valueLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
            
//            if (chain is ChainBinanceBeacon) {
//                WDP.dpPrice(ChainBinanceBeacon.BNB_GECKO_ID, priceCurrencyLabel, priceLabel)
//                WDP.dpPriceChanged(ChainBinanceBeacon.BNB_GECKO_ID, priceChangeLabel, priceChangePercentLabel)
//
//            } else if (chain is ChainOktKeccak256) {
//                WDP.dpPrice(ChainOktKeccak256.OKT_GECKO_ID, priceCurrencyLabel, priceLabel)
//                WDP.dpPriceChanged(ChainOktKeccak256.OKT_GECKO_ID, priceChangeLabel, priceChangePercentLabel)
//
//            } else {
//                if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
//                    WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
//                    WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
//                }
//            }
        }
    }
    
}
