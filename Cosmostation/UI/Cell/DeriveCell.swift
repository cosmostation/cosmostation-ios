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
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var keyTypeTag: PaddingLabel!
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
        keyTypeTag.isHidden = true
        loadingLabel.isHidden = false
        amountLabel.isHidden = true
        denomLabel.isHidden = true
        denomLabel.textColor = .color01
        coinCntLabel.isHidden = true
        reposeErrorLabel.isHidden = true
    }
    //YONG4
    func bindDeriveEvmClassChain(_ account: BaseAccount, _ chain: BaseChain, _ selectedList: [String]) {
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
        } else {
            hdPathLabel.text = chain.evmAddress
        }
        
//        if (chain.fetchState == .Fail) {
//            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
//            loadingLabel.isHidden = true
//            reposeErrorLabel.isHidden  = false
//            
//        } else if (chain.fetchState == .Success) {
//            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
//            loadingLabel.isHidden = true
//            
//            let dpAmount = chain.evmBalances.multiplying(byPowerOf10: -18, withBehavior: handler18)
//            denomLabel.text = chain.coinSymbol
//            amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 18)
//            if let stakeDenom = chain.stakeDenom,
//               let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
//                denomLabel.textColor = msAsset.assetColor()
//            } else {
//                denomLabel.textColor = .color01
//            }
//            
//            if (chain.evmBalances != NSDecimalNumber.zero) {
//                coinCntLabel.text = "1 Coins"
//            } else {
//                coinCntLabel.text = "0 Coins"
//            }
//            denomLabel.isHidden = false
//            amountLabel.isHidden = false
//            coinCntLabel.isHidden = false
//            
//        } else {
//            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
//            loadingLabel.isHidden = false
//        }
    }
    
    
    func bindDeriveCosmosClassChain(_ account: BaseAccount, _ chain: BaseChain, _ selectedList: [String]) {
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
        } else {
            hdPathLabel.text = ""
        }
        
        legacyTag.isHidden = chain.isDefault
        if (chain is ChainOkt996Keccak) {
            keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
            keyTypeTag.isHidden = false
        }
        
//        if (chain.fetchState == .Fail) {
//            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
//            loadingLabel.isHidden = true
//            reposeErrorLabel.isHidden  = false
//            
//        } else if (chain.fetchState == .Success) {
//            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
//            loadingLabel.isHidden = true
//            
//            let stakeDenom = chain.stakeDenom!
//           if let oktChain = chain as? ChainOkt996Keccak {
//                let availableAmount = oktChain.lcdBalanceAmount(stakeDenom)
//                amountLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, amountLabel!.font, 18)
//                denomLabel.text = stakeDenom.uppercased()
//                denomLabel.textColor = .color01
//                denomLabel.isHidden = false
//                amountLabel.isHidden = false
//                
//                let coinCnt = oktChain.lcdAccountInfo.oktCoins?.count ?? 0
//                coinCntLabel.text = String(coinCnt) + " Coins"
//                coinCntLabel.isHidden = false
//                
//            } else {
//                let availableAmount = chain.balanceAmount(stakeDenom)
//                if let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
//                    WDP.dpCoin(msAsset, availableAmount, nil, denomLabel, amountLabel, msAsset.decimals)
//                    denomLabel.isHidden = false
//                    amountLabel.isHidden = false
//                }
//                let coinCnt = chain.cosmosBalances?.count ?? 0
//                coinCntLabel.text = String(coinCnt) + " Coins"
//                coinCntLabel.isHidden = false
//            }
//            
//        } else {
//            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
//            loadingLabel.isHidden = false
//        }
    }
}
