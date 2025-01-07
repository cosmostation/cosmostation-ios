//
//  SelectChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SkeletonView

class SelectChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bechAddressLabel: UILabel!
    @IBOutlet weak var evmAddressLabel: UILabel!
    @IBOutlet weak var btcTag: RoundedPaddingLabel!
    @IBOutlet weak var oldTag: RoundedPaddingLabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var assetCntLabel: UILabel!
    @IBOutlet weak var loadingLabel1: UILabel!
    @IBOutlet weak var loadingLabel2: UILabel!
    @IBOutlet weak var reposeErrorLabel: UILabel!
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        currencyLabel.text = ""
        valueLabel.text = ""
        assetCntLabel.text = ""
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        oldTag.isHidden = true
        loadingLabel1.isHidden = false
        loadingLabel2.isHidden = false
        reposeErrorLabel.isHidden = true
        bechAddressLabel.alpha = 1.0
        evmAddressLabel.alpha = 1.0
        loadingLabel1.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color05, .color04]), animation: skeletonAnimation, transition: .none)
        loadingLabel2.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color06, .color05]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        currencyLabel.text = ""
        valueLabel.text = ""
        assetCntLabel.text = ""
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        btcTag.isHidden = true
        oldTag.isHidden = true
        loadingLabel1.isHidden = false
        loadingLabel2.isHidden = false
        reposeErrorLabel.isHidden = true
        bechAddressLabel.alpha = 1.0
        evmAddressLabel.alpha = 1.0
        bechAddressLabel.layer.removeAllAnimations()
        evmAddressLabel.layer.removeAllAnimations()
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func bindSelectChain(_ account: BaseAccount, _ chain: BaseChain, _ selectedList: [String]) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name
        
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
        
        if (chain is ChainBitCoin84) {
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
            }
            btcTag.isHidden = false
            
        } else {
            oldTag.isHidden = chain.isDefault
        }
        
        if (selectedList.contains(chain.tag)) {
            rootView.layer.borderWidth = 1.0
            rootView.layer.borderColor = UIColor.white.cgColor
        } else {
            rootView.layer.borderWidth = 0.5
            rootView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
        
        if (chain.fetchState == .Fail) {
            loadingLabel1.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel1.isHidden = true
            loadingLabel2.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel2.isHidden = true
            reposeErrorLabel.isHidden = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel1.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel1.isHidden = true
            loadingLabel2.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel2.isHidden = true
            
            WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
            
            if (chain.tokensCnt == 0) {
                assetCntLabel.text =  String(chain.coinsCnt) + " Coins"
            } else {
                assetCntLabel.text = String(chain.tokensCnt) + " Tokens " + String(chain.coinsCnt) + " Coins"
            }
            
        } else {
            loadingLabel1.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color05, .color04]), animation: skeletonAnimation, transition: .none)
            loadingLabel1.isHidden = false
            loadingLabel2.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color06, .color05]), animation: skeletonAnimation, transition: .none)
            loadingLabel2.isHidden = false
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
