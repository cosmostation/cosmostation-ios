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
    @IBOutlet weak var btcTag: RoundedPaddingLabel!
    @IBOutlet weak var oldTag: RoundedPaddingLabel!
    @IBOutlet weak var symbolLabel: UILabel!
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
        symbolLabel.text = ""
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
        btcTag.isHidden = true
        oldTag.isHidden = true
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        symbolLabel.text = ""
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
        nameLabel.text = chain.getChainName()
        logoImg1.image = chain.getChainImage()
        
        if (chain.supportCosmos && chain.supportEvm) {
            bechAddressLabel.text = chain.bechAddress
            evmAddressLabel.text = chain.evmAddress
            starEvmAddressAnimation()
            
        } else if (chain.supportCosmos) {
            bechAddressLabel.text = chain.bechAddress
            
        } else if (chain.supportEvm) {
            evmAddressLabel.text = chain.evmAddress
            
        } else {
            bechAddressLabel.text = chain.mainAddress
        }
        
        if (chain is ChainBitCoin86) {
            if chain.accountKeyType.pubkeyType == .BTC_Legacy {
                btcTag.text = "Legacy"
                btcTag.backgroundColor = .color07
                btcTag.textColor = .color02

            } else if chain.accountKeyType.pubkeyType == .BTC_Nested_Segwit {
                btcTag.text = "Nested Segwit"
                btcTag.backgroundColor = .color07
                btcTag.textColor = .color02

            } else if chain.accountKeyType.pubkeyType == .BTC_Native_Segwit {
                btcTag.text = "Native Segwit"
                btcTag.backgroundColor = .colorNativeSegwit
                btcTag.textColor = .color01
            
            } else if chain.accountKeyType.pubkeyType == .BTC_Taproot {
                btcTag.text = "Taproot"
                btcTag.backgroundColor = .colorBtcTaproot
                btcTag.textColor = .color01
            }
            btcTag.isHidden = false
            
        } else {
            oldTag.isHidden = chain.isDefault
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
        
        symbolLabel.text = chain.getChainListParam()["main_asset_symbol"].string ?? chain.getChainListParam()["staking_asset_symbol"].string
        
        //DP Price
        if chain is ChainOktEVM {
            guard let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom ?? chain.coinSymbol) else { return }
            WDP.dpPrice(msAsset.coinGeckoId, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(msAsset.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
            
        } else if (chain.supportCosmos) {
            if let denom = chain.getChainListParam()["main_asset_denom"].string ?? chain.getChainListParam()["staking_asset_denom"].string,
               let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
            }
            
        } else if (chain.supportEvm) {
            if let denom = chain.getChainListParam()["main_asset_denom"].string,
               let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
                
            } else if let symbol = chain.getChainListParam()["main_asset_symbol"].string,
               let geckoId = chain.getEvmfetcher()?.mintscanErc20Tokens.filter({ $0.symbol == symbol }).first?.coinGeckoId {
                WDP.dpPrice(geckoId, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(geckoId, priceChangeLabel, priceChangePercentLabel)
            }
            
        } else {
            if let stakeDenom = chain.stakeDenom,
               let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)

            } else if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.coinSymbol) {
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)

            }
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




