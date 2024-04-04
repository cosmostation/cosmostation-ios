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
    @IBOutlet weak var cosmosTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    @IBOutlet weak var cw20Tag: UILabel!
    @IBOutlet weak var nftTag: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var reposeErrorLabel: UILabel!
    
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        rootView.setBlur()
        loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        currencyLabel.text = ""
        currencyLabel.isHidden = true
        valueLabel.isHidden = true
        tagLayer.isHidden = true
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        cosmosTag.isHidden = true
        keyTypeTag.isHidden = true
        cw20Tag.isHidden = true
        nftTag.isHidden = true
        loadingLabel.isHidden = false
        reposeErrorLabel.isHidden = true
    }
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass) {
        logoImg1.image = UIImage.init(named: chain.logo1)
        logoImg2.image = UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        
        if (!chain.isDefault) {
            tagLayer.isHidden = false
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
            tagLayer.isHidden = false
            cw20Tag.isHidden = false
        }
        
        if (!BaseData.instance.reviewMode && chain.supportCw721) {
            tagLayer.isHidden = false
            nftTag.isHidden = false
        }
        
        
        if (chain.fetchState == .Fail) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            reposeErrorLabel.isHidden = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            
//            if (!(chain is ChainOkt996Keccak) && !(chain is ChainBinanceBeacon)) {
//                if (chain.cosmosBalances == nil) {
//                    reposeErrorLabel.isHidden = false
//                    return
//                }
//            }
            
            if (BaseData.instance.getHideValue()) {
                currencyLabel.text = ""
                valueLabel.font = .fontSize14Bold
                valueLabel.text = "✱✱✱✱"
            } else {
                valueLabel.font = .fontSize16Bold
                WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
            }
            currencyLabel.isHidden = false
            valueLabel.isHidden = false
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
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
            
//            if (!(chain is ChainOktEVM)) {
//                if (chain.supportCosmos && chain.cosmosBalances == nil) {
//                    reposeErrorLabel.isHidden = false
//                    return
//                }
//            }
            
//            if (chain.web3 == nil) {
//                reposeErrorLabel.isHidden = false
//                return
//            }
            
            if (BaseData.instance.getHideValue()) {
                currencyLabel.text = ""
                valueLabel.font = .fontSize14Bold
                valueLabel.text = "✱✱✱✱"
            } else {
                valueLabel.font = .fontSize16Bold
                WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
            }
            currencyLabel.isHidden = false
            valueLabel.isHidden = false
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
        }
    }
    
}
