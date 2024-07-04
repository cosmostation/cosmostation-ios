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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var erc20Tag: PaddingLabel!
    @IBOutlet weak var cw20Tag: PaddingLabel!
    @IBOutlet weak var nftTag: PaddingLabel!
    @IBOutlet weak var dappTag: PaddingLabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var reposeErrorLabel: UILabel!
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        rootView.setBlur()
        currencyLabel.text = ""
        valueLabel.text = ""
        loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        currencyLabel.text = ""
        valueLabel.text = ""
        legacyTag.isHidden = true
        erc20Tag.isHidden = true
        cw20Tag.isHidden = true
        nftTag.isHidden = true
        dappTag.isHidden = true
        loadingLabel.isHidden = false
        reposeErrorLabel.isHidden = true
    }
    
    
    func bindChain(_ account: BaseAccount, _ chain: BaseChain) {
        logoImg1.image = UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        legacyTag.isHidden = chain.isDefault
        erc20Tag.isHidden = !chain.supportEvm
        cw20Tag.isHidden = !chain.supportCw20
        nftTag.isHidden = !(BaseData.instance.showEvenReview() && chain.supportCw721)
        dappTag.isHidden = !(BaseData.instance.showEvenReview() && chain.isDefault && chain.isEcosystem())
        
        if (chain.fetchState == .Fail) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            reposeErrorLabel.isHidden = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            
            if (BaseData.instance.getHideValue()) {
                currencyLabel.text = ""
                valueLabel.font = .fontSize14Bold
                valueLabel.text = "✱✱✱✱"
            } else {
                valueLabel.font = .fontSize16Bold
                WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
            }
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
        }
    }
    
}
