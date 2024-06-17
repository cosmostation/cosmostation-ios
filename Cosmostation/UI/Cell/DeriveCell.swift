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
        
        denomLabel.text = ""
        amountLabel.text = ""
        coinCntLabel.text = ""
        loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
        loadingLabel.isHidden = false
        denomLabel.text = ""
        denomLabel.textColor = .color01
        amountLabel.text = ""
        coinCntLabel.text = ""
        reposeErrorLabel.isHidden = true
    }
    
    func bindDeriveChain(_ account: BaseAccount, _ chain: BaseChain, _ selectedList: [String]) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        
        legacyTag.isHidden = chain.isDefault
        if (chain.name == "OKT" && !chain.supportEvm) {
            keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
            keyTypeTag.isHidden = false
        }
        
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
        
        if (chain.fetchState == .Fail) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            reposeErrorLabel.isHidden  = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            
            if (chain.name == "OKT") {
                let dpAmount =  chain.getLcdfetcher()?.lcdBalanceAmount(chain.stakeDenom!) ?? NSDecimalNumber.zero
                denomLabel.text = "OKT"
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 18)
                
                let coinCnt = chain.getLcdfetcher()?.lcdAccountInfo.oktCoins?.count ?? 0
                coinCntLabel.text = String(coinCnt) + " Coins"
                
            } else if (chain.supportEvm) {
                let dpAmount = chain.getEvmfetcher()?.evmBalances.multiplying(byPowerOf10: -18, withBehavior: handler18) ?? NSDecimalNumber.zero
                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 18)
                
                if (dpAmount != NSDecimalNumber.zero) {
                    coinCntLabel.text = "1 Coins"
                } else {
                    coinCntLabel.text = "0 Coins"
                }
                
            } else if (chain.supportCosmos) {
                let stakeDenom = chain.stakeDenom!
                let availableAmount = chain.getGrpcfetcher()?.balanceAmount(stakeDenom) ?? NSDecimalNumber.zero
                if let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
                    WDP.dpCoin(msAsset, availableAmount, nil, denomLabel, amountLabel, msAsset.decimals)
                }
                
                let coinCnt = chain.getGrpcfetcher()?.cosmosBalances?.count ?? 0
                coinCntLabel.text = String(coinCnt) + " Coins"
            }
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
        }
    }
}
