//
//  Portfolio2Cell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/4/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SkeletonView

class Portfolio2Cell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bechAddressLabel: UILabel!
    @IBOutlet weak var evmAddressLabel: UILabel!
    @IBOutlet weak var legacyTag: RoundedPaddingLabel!
    @IBOutlet weak var erc20Tag: RoundedPaddingLabel!
    @IBOutlet weak var cw20Tag: RoundedPaddingLabel!
    @IBOutlet weak var nftTag: RoundedPaddingLabel!
    @IBOutlet weak var dappTag: RoundedPaddingLabel!
    @IBOutlet weak var priceCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangePercentLabel: UILabel!
    @IBOutlet weak var valuecurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueLoadingLabel: UILabel!
    @IBOutlet weak var assetCntLabel: UILabel!
    @IBOutlet weak var assetCntLoadingLabel: UILabel!
    @IBOutlet weak var reposeErrorLabel: UILabel!
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        valuecurrencyLabel.text = ""
        valueLabel.text = ""
        assetCntLabel.text = ""
        priceCurrencyLabel.text = ""
        priceLabel.text = ""
        priceChangeLabel.text = ""
        priceChangePercentLabel.text = ""
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        bechAddressLabel.alpha = 1.0
        evmAddressLabel.alpha = 1.0
        valueLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
        assetCntLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color04, .color03]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        valuecurrencyLabel.text = ""
        valueLabel.text = ""
        assetCntLabel.text = ""
        legacyTag.isHidden = true
        erc20Tag.isHidden = true
        cw20Tag.isHidden = true
        nftTag.isHidden = true
        dappTag.isHidden = true
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        priceCurrencyLabel.text = ""
        priceLabel.text = ""
        priceChangeLabel.text = ""
        priceChangePercentLabel.text = ""
        valueLoadingLabel.isHidden = false
        assetCntLoadingLabel.isHidden = false
        reposeErrorLabel.isHidden = true
        bechAddressLabel.alpha = 1.0
        evmAddressLabel.alpha = 1.0
        bechAddressLabel.layer.removeAllAnimations()
        evmAddressLabel.layer.removeAllAnimations()
    }
    
    func bindChain(_ account: BaseAccount, _ chain: BaseChain) {
        logoImg1.image = UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        if (chain.supportCosmos) {
            bechAddressLabel.text = chain.bechAddress
        }
        if (chain.supportEvm) {
            evmAddressLabel.text = chain.evmAddress
        }
        if (chain.supportCosmos && chain.supportEvm) {
            starEvmAddressAnimation()
        }
        
        legacyTag.isHidden = chain.isDefault
        cw20Tag.isHidden = !chain.supportCw20
        erc20Tag.isHidden = !chain.supportEvm
        nftTag.isHidden = !(BaseData.instance.showEvenReview() && chain.supportCw721)
        dappTag.isHidden = !(BaseData.instance.showEvenReview() && chain.isDefault && chain.isEcosystem())
        
        if (chain.fetchState == .Fail) {
            valueLoadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            valueLoadingLabel.isHidden = true
            assetCntLoadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            assetCntLoadingLabel.isHidden = true
            reposeErrorLabel.isHidden = false
            
        } else if (chain.fetchState == .Success) {
            valueLoadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            valueLoadingLabel.isHidden = true
            assetCntLoadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            assetCntLoadingLabel.isHidden = true
            
            if (BaseData.instance.getHideValue()) {
                valuecurrencyLabel.text = ""
                valueLabel.font = .fontSize14Bold
                valueLabel.text = "✱✱✱✱"
            } else {
                valueLabel.font = .fontSize16Bold
                WDP.dpValue(chain.allValue(), valuecurrencyLabel, valueLabel)
            }
            
            if (chain.tokensCnt == 0) {
                assetCntLabel.text =  String(chain.coinsCnt) + " Coins"
            } else {
                assetCntLabel.text = String(chain.tokensCnt) + " Tokens " + String(chain.coinsCnt) + " Coins"
            }
            
        } else {
            valueLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            valueLoadingLabel.isHidden = false
            assetCntLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color04, .color03]), animation: skeletonAnimation, transition: .none)
            assetCntLoadingLabel.isHidden = false
        }
        
        //DP Price
        if (chain.name == "OKT") {
            WDP.dpPrice(OKT_GECKO_ID, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(OKT_GECKO_ID, priceChangeLabel, priceChangePercentLabel)
            
        } else if (chain.supportCosmos) {
            if let stakeDenom = chain.stakeDenom,
               let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
            }
            
        } else if (chain.supportEvm) {
            WDP.dpPrice(chain.coinGeckoId, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(chain.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
        }
    }
    
    func starEvmAddressAnimation() {
        bechAddressLabel.layer.removeAllAnimations()
        evmAddressLabel.layer.removeAllAnimations()
        bechAddressLabel.alpha = 0.0
        evmAddressLabel.alpha = 1.0
        
        UIView.animateKeyframes(withDuration: 10.0,
                                delay: 0,
                                options: [.repeat, .calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 4 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.evmAddressLabel.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 5 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.bechAddressLabel.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 14 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.bechAddressLabel.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 15 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.evmAddressLabel.alpha = 1.0
            }
        }
    }
}




