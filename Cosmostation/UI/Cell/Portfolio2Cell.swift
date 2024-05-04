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
    @IBOutlet weak var loadingLabel: UILabel!
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
        loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        valuecurrencyLabel.text = ""
        valuecurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        cosmosTag.isHidden = true
        keyTypeTag.isHidden = true
        cw20Tag.isHidden = true
        nftTag.isHidden = true
        priceCurrencyLabel.text = ""
        priceLabel.text = ""
        priceChangeLabel.text = ""
        priceChangePercentLabel.text = ""
        loadingLabel.isHidden = false
        reposeErrorLabel.isHidden = true
    }
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass) {
        logoImg1.image = UIImage.init(named: chain.logo1)
        logoImg2.image = UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        
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
        
        if ((!BaseData.instance.reviewMode || BaseData.instance.checkInstallTime()) && chain.supportCw721) {
            nftTag.isHidden = false
        }
        
        
        if (chain.fetchState == .Fail) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            reposeErrorLabel.isHidden = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            if (BaseData.instance.getHideValue()) {
                valuecurrencyLabel.text = ""
                valueLabel.font = .fontSize14Bold
                valueLabel.text = "✱✱✱✱"
            } else {
                valueLabel.font = .fontSize16Bold
                WDP.dpValue(chain.allValue(), valuecurrencyLabel, valueLabel)
            }
            valuecurrencyLabel.isHidden = false
            valueLabel.isHidden = false
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
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
        
        if (chain.fetchState == .Fail) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            reposeErrorLabel.isHidden = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            
            if (BaseData.instance.getHideValue()) {
                valuecurrencyLabel.text = ""
                valueLabel.font = .fontSize14Bold
                valueLabel.text = "✱✱✱✱"
            } else {
                valueLabel.font = .fontSize16Bold
                WDP.dpValue(chain.allValue(), valuecurrencyLabel, valueLabel)
            }
            valuecurrencyLabel.isHidden = false
            valueLabel.isHidden = false
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
        }
        
        WDP.dpPrice(chain.coinGeckoId, priceCurrencyLabel, priceLabel)
        WDP.dpPriceChanged(chain.coinGeckoId, priceChangeLabel, priceChangePercentLabel)
    }
}
