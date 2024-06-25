//
//  ClaimAllChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/06.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class ClaimAllChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var etcCntLabel: UILabel!
    @IBOutlet weak var feeValueCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var pendingView: LottieAnimationView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        legacyTag.isHidden = true
        pendingView.isHidden = false
        pendingView.animation = LottieAnimation.named("loadingSmallYellow")
        pendingView.contentMode = .scaleAspectFit
        pendingView.loopMode = .loop
        pendingView.animationSpeed = 1.3
        pendingView.play()
        
        stateImg.image = UIImage(named: "iconClaimAllReady")
        stateImg.isHidden = true
        
        etcCntLabel.text = ""
        feeValueCurrencyLabel.text = ""
        feeValueLabel.text = ""
        feeAmountLabel.text = ""
        feeDenomLabel.text = ""
    }
    
    override func prepareForReuse() {
        legacyTag.isHidden = true
        pendingView.isHidden = false
        stateImg.image = UIImage(named: "iconClaimAllReady")
        stateImg.isHidden = true
        
        etcCntLabel.text = ""
        feeValueCurrencyLabel.text = ""
        feeValueLabel.text = ""
        feeAmountLabel.text = ""
        feeDenomLabel.text = ""
    }
    
    func onBindRewards(_ model: ClaimAllModel) {
        let chain = model.cosmosChain!
        let rewards = model.rewards
        let txFee = (model.txFee == nil) ? chain.getInitPayableFee() : model.txFee
        let isBusy = model.isBusy
        let result = model.txResponse
        
        
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        if (!chain.isDefault) {
            legacyTag.isHidden = false
        }
        
        var mainRewardDenom = ""
        var mainRewardAmount = NSDecimalNumber.zero
        if (chain is ChainDydx) {
            mainRewardDenom = DYDX_USDC_DENOM
        } else {
            mainRewardDenom = chain.stakeDenom!
        }
        
        rewards.forEach { reward in
            if let rewardCoin = reward.reward.filter({ $0.denom == mainRewardDenom }).first {
                let amount = NSDecimalNumber(string: rewardCoin.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                mainRewardAmount = mainRewardAmount.adding(amount)
            }
        }
        
        let mainRewardCoin = Cosmos_Base_V1beta1_Coin(mainRewardDenom, mainRewardAmount.stringValue)
        if let msAsset = BaseData.instance.getAsset(chain.apiName, mainRewardDenom) {
            WDP.dpCoin(msAsset, mainRewardCoin, nil, denomLabel, amountLabel, msAsset.decimals)
        }
        
        var rewardsValue = NSDecimalNumber.zero
        var rewardDenoms = [String]()
        rewards.forEach { reward in
            reward.reward.forEach { deCoin in
                if let msAsset = BaseData.instance.getAsset(chain.apiName, deCoin.denom) {
                    let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, false)
                    let amount = NSDecimalNumber(string: deCoin.amount) .multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                    let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                    rewardsValue = rewardsValue.adding(value)
                    if (amount != NSDecimalNumber.zero && !rewardDenoms.contains(deCoin.denom)) {
                        rewardDenoms.append(deCoin.denom)
                    }
                }
            }
        }
        WDP.dpValue(rewardsValue, valueCurrencyLabel, valueLabel)
        
        if (rewardDenoms.count > 1) {
            etcCntLabel.text = "(+" + String(rewardDenoms.count - 1) + ")"
        }
        
        if let txFee = txFee,
            let msAsset = BaseData.instance.getAsset(chain.apiName, txFee.amount[0].denom) {
                WDP.dpCoin(msAsset, txFee.amount[0], nil, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let amount = NSDecimalNumber(string: txFee.amount[0].amount)
                let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpValue(value, feeValueCurrencyLabel, feeValueLabel)
                
                pendingView.isHidden = true
                stateImg.isHidden = false
        }
        
        if (isBusy) {
            pendingView.isHidden = false
            stateImg.isHidden = true
            
        } else {
            stateImg.isHidden = false
            if (result == nil) {
                stateImg.image = UIImage(named: "iconClaimAllReady")
            } else {
                stateImg.image = UIImage(named: "iconClaimAllDone")
            }
        }
    }
    
    func onBindCompounding(_ model: ClaimAllModel) {
        rewardTitle.text = "To Compounding"
        etcCntLabel.text = ""
        
        let chain = model.cosmosChain!
        let rewards = model.rewards
        let txFee = (model.txFee == nil) ? chain.getInitPayableFee() : model.txFee
        let isBusy = model.isBusy
        let result = model.txResponse
        
        
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        if (!chain.isDefault) {
            legacyTag.isHidden = false
        }
        
        let mainRewardDenom = chain.stakeDenom
        var mainRewardAmount = NSDecimalNumber.zero
        rewards.forEach { reward in
            if let rewardCoin = reward.reward.filter({ $0.denom == mainRewardDenom }).first {
                let amount = rewardCoin.getAmount()
                mainRewardAmount = mainRewardAmount.adding(amount)
            }
        }
        let mainRewardCoin = Cosmos_Base_V1beta1_Coin(mainRewardDenom!, mainRewardAmount.stringValue)
        if let msAsset = BaseData.instance.getAsset(chain.apiName, mainRewardDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, false)
            let value = msPrice.multiplying(by: mainRewardAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, mainRewardCoin, nil, denomLabel, amountLabel, msAsset.decimals)
            WDP.dpValue(value, valueCurrencyLabel, valueLabel)
        }
        
        if let txFee = txFee,
            let msAsset = BaseData.instance.getAsset(chain.apiName, txFee.amount[0].denom) {
                WDP.dpCoin(msAsset, txFee.amount[0], nil, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let amount = NSDecimalNumber(string: txFee.amount[0].amount)
                let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpValue(value, feeValueCurrencyLabel, feeValueLabel)
                
                pendingView.isHidden = true
                stateImg.isHidden = false
        }
        
        if (isBusy) {
            pendingView.isHidden = false
            stateImg.isHidden = true
            
        } else {
            stateImg.isHidden = false
            if (result == nil) {
                stateImg.image = UIImage(named: "iconClaimAllReady")
            } else {
                stateImg.image = UIImage(named: "iconClaimAllDone")
            }
        }
    }
    
}
