//
//  DeriveCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SkeletonView

class DeriveCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var logoImg2: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var coinCntLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var reposeErrorLabel: UILabel!
    
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        loadingLabel.isHidden = false
        amountLabel.isHidden = true
        denomLabel.isHidden = true
        coinCntLabel.isHidden = true
        reposeErrorLabel.isHidden = true
    }
    
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass, _ selectedList: [String]) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        
        if (selectedList.contains(chain.tag)) {
            rootView.layer.borderWidth = 1.0
            rootView.layer.borderColor = UIColor.white.cgColor
        } else {
            rootView.layer.borderWidth = 0.5
            rootView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
        
        if (account.type == .withMnemonic) {
            hdPathLabel.text = chain.getHDPath(account.lastHDPath)
//            if (chain.evmCompatible) {
//                evmCompatTag.isHidden = false
//            } else 
            
            if (!chain.isDefault) {
                legacyTag.isHidden = false
            }
            
        } else {
//            if (chain.evmCompatible) {
//                evmCompatTag.isHidden = false
//            }
            if (chain is ChainOkt60Keccak || chain.tag == "kava60" || chain.tag == "althea60" || chain.tag == "xplaKeccak256") {
                hdPathLabel.text = chain.evmAddress
            } else {
                hdPathLabel.text = chain.bechAddress
            }
        }
        
        if (chain.fetched) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            
            let stakeDenom = chain.stakeDenom!
            if let bnbChain = chain as? ChainBinanceBeacon {
                let availableAmount = bnbChain.lcdBalanceAmount(stakeDenom)
                amountLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, amountLabel!.font, 8)
                denomLabel.text = stakeDenom.uppercased()
                denomLabel.textColor = .color01
                denomLabel.isHidden = false
                amountLabel.isHidden = false
                
                let coinCnt = bnbChain.lcdAccountInfo.bnbCoins?.count ?? 0
                coinCntLabel.text = String(coinCnt) + " Coins"
                coinCntLabel.isHidden = false
                
            } else if let oktChain = chain as? ChainOkt60Keccak {
                let availableAmount = oktChain.lcdBalanceAmount(stakeDenom)
                amountLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, amountLabel!.font, 18)
                denomLabel.text = stakeDenom.uppercased()
                denomLabel.textColor = .color01
                denomLabel.isHidden = false
                amountLabel.isHidden = false
                
                let coinCnt = oktChain.lcdAccountInfo.oktCoins?.count ?? 0
                coinCntLabel.text = String(coinCnt) + " Coins"
                coinCntLabel.isHidden = false
                
            } else {
                if (chain.cosmosBalances == nil) {
                    reposeErrorLabel.isHidden  = false
                } else {
                    let availableAmount = chain.balanceAmount(stakeDenom)
                    if let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
                        WDP.dpCoin(msAsset, availableAmount, nil, denomLabel, amountLabel, msAsset.decimals)
                        denomLabel.isHidden = false
                        amountLabel.isHidden = false
                    }
                    let coinCnt = chain.cosmosBalances?.count ?? 0
                    coinCntLabel.text = String(coinCnt) + " Coins"
                    coinCntLabel.isHidden = false
                }
            }
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
        }
    }
}
