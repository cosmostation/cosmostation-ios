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
    @IBOutlet weak var legacyTag: PaddingLabel!
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
        legacyTag.isHidden = true
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
        legacyTag.isHidden = true
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
        nameLabel.text = chain.name.uppercased()
        if (chain.isCosmos()) {
            bechAddressLabel.text = chain.bechAddress
        }
        if (chain.supportEvm) {
            evmAddressLabel.text = chain.evmAddress
        }
        if (chain.isCosmos() && chain.supportEvm) {
            starEvmAddressAnimation()
        }
        
        legacyTag.isHidden = chain.isDefault
        
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
            
            var coinCntString = ""
            var tokenCnt = 0
            if (chain.name == "OKT") {
                if let lcdFetcher = chain.getLcdfetcher() {
                    coinCntString = String(lcdFetcher.lcdAccountInfo.oktCoins?.count ?? 0) + " Coins"
                }
                if let evmFetcher = chain.getEvmfetcher() {
                    tokenCnt = evmFetcher.mintscanErc20Tokens.filter { $0.getAmount() != NSDecimalNumber.zero }.count
                }
                
            } else if let grpcFetcher = chain.getGrpcfetcher() {
                coinCntString = String(grpcFetcher.cosmosBalances?.filter({ BaseData.instance.getAsset(chain.apiName, $0.denom) != nil }).count ?? 0) + " Coins"
                if (chain.supportCw20) {
                    tokenCnt = grpcFetcher.mintscanCw20Tokens.filter { $0.getAmount() != NSDecimalNumber.zero }.count
                }
                
            } else if let evmFetcher = chain.getEvmfetcher() {
                coinCntString = String(evmFetcher.evmBalances != NSDecimalNumber.zero ? 1 : 0) + " Coins"
                tokenCnt = evmFetcher.mintscanErc20Tokens.filter { $0.getAmount() != NSDecimalNumber.zero }.count
            }
            
            if (tokenCnt == 0) {
                assetCntLabel.text = coinCntString
            } else {
                assetCntLabel.text = String(tokenCnt) + " Tokens,  " + coinCntString
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
