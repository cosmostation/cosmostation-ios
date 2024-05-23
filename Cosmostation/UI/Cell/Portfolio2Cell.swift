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
    @IBOutlet weak var logoImg2: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bechAddressLabel: UILabel!
    @IBOutlet weak var evmAddressLabel: UILabel!
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var cosmosTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    @IBOutlet weak var cw20Tag: UILabel!
    @IBOutlet weak var nftTag: UILabel!
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
        
        rootView.setBlur()
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
        rootView.setBlur()
        valuecurrencyLabel.text = ""
        valuecurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        assetCntLabel.isHidden = true
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        cosmosTag.isHidden = true
        keyTypeTag.isHidden = true
        cw20Tag.isHidden = true
        nftTag.isHidden = true
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
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass) {
        logoImg1.image = UIImage.init(named: chain.logo1)
        logoImg2.image = UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        bechAddressLabel.text = chain.bechAddress
        
        if (!chain.isDefault) {
            legacyTag.isHidden = false
            //for okt legacy
            if (chain.tag == "okt996_Keccak") {
                keyTypeTag.text = "ethsecp256k1"
                keyTypeTag.isHidden = false
                
            } else if (chain.tag == "okt996_Secp") {
                keyTypeTag.text = "secp256k1"
                keyTypeTag.isHidden = false
            }
        }
        
        if (chain.supportCw20) {
            cw20Tag.isHidden = false
        }
        
        if (BaseData.instance.showEvenReview() && chain.supportCw721) {
            nftTag.isHidden = false
        }
        
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
            
            let coinCntString = String(chain.cosmosBalances?.filter({ BaseData.instance.getAsset(chain.apiName, $0.denom) != nil }).count ?? 0) + " Coins"
            if (chain.supportCw20) {
                let tokenCnt = chain.mintscanCw20Tokens.filter { $0.getAmount() != NSDecimalNumber.zero }.count
                if (tokenCnt == 0) {
                    assetCntLabel.text = coinCntString
                } else {
                    assetCntLabel.text = String(tokenCnt) + " Tokens,  " + coinCntString
                }
            } else {
                assetCntLabel.text = coinCntString
            }
            valuecurrencyLabel.isHidden = false
            valueLabel.isHidden = false
            assetCntLabel.isHidden = false
            
        } else {
            valueLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            valueLoadingLabel.isHidden = false
            assetCntLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color04, .color03]), animation: skeletonAnimation, transition: .none)
            assetCntLoadingLabel.isHidden = false
        }
        
        if let stakeDenom = chain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
            WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
            priceCurrencyLabel.isHidden = false
            priceLabel.isHidden = false
            priceChangeLabel.isHidden = false
            priceChangePercentLabel.isHidden = false
        }
    }
    
    func bindEvmClassChain(_ account: BaseAccount, _ chain: EvmClass) {
        logoImg1.image = UIImage.init(named: chain.logo1)
        logoImg2.image = UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        evmAddressLabel.text = chain.evmAddress
        if (chain.supportCosmos == true) {
            bechAddressLabel.text = chain.bechAddress
            starEvmAddressAnimation()
        }
        
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
            
            let coinCntString = String(chain.evmBalances != NSDecimalNumber.zero ? 1 : 0) + " Coins"
            let tokenCnt = chain.mintscanErc20Tokens.filter { $0.getAmount() != NSDecimalNumber.zero }.count
            if (tokenCnt == 0) {
                assetCntLabel.text = coinCntString
            } else {
                assetCntLabel.text = String(tokenCnt) + " Tokens,  " + coinCntString
            }
            valuecurrencyLabel.isHidden = false
            valueLabel.isHidden = false
            assetCntLabel.isHidden = false
            
        } else {
            valueLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            valueLoadingLabel.isHidden = false
            assetCntLoadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color04, .color03]), animation: skeletonAnimation, transition: .none)
            assetCntLoadingLabel.isHidden = false
        }
        
        WDP.dpPrice(chain.coinGeckoId, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(chain.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
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




