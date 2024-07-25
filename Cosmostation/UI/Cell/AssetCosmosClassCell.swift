//
//  AssetCosmosClassCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Kingfisher

class AssetCosmosClassCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangePercentLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var hidenValueLabel: UILabel!
    
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var vestingLayer: UIView!
    @IBOutlet weak var vestingTitle: UILabel!
    @IBOutlet weak var vestingLabel: UILabel!
    @IBOutlet weak var stakingLayer: UIView!
    @IBOutlet weak var stakingTitle: UILabel!
    @IBOutlet weak var stakingLabel: UILabel!
    @IBOutlet weak var unstakingLayer: UIView!
    @IBOutlet weak var unstakingTitle: UILabel!
    @IBOutlet weak var unstakingLabel: UILabel!
    @IBOutlet weak var rewardLayer: UIView!
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var commissionLayer: UIView!
    @IBOutlet weak var commissionTitle: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        coinImg.kf.cancelDownloadTask()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    func bindCosmosStakeAsset(_ baseChain: BaseChain) {
        if let oktChain = baseChain as? ChainOktEVM {
            bindOktAsset(oktChain)
            
        } else if let neutronChain = baseChain as? ChainNeutron {
            bindNeutron(neutronChain)
            
        } else {
            let stakeDenom = baseChain.stakeDenom!
            if let cosmosFetcher = baseChain.getCosmosfetcher(),
               let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
                let value = cosmosFetcher.denomValue(stakeDenom)
                
                coinImg.kf.setImage(with: msAsset.assetImg(), placeholder: UIImage(named: "tokenDefault"))
                symbolLabel.text = msAsset.symbol?.uppercased()
                
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
                if (BaseData.instance.getHideValue()) {
                    hidenValueLabel.isHidden = false
                } else {
                    WDP.dpValue(value, valueCurrencyLabel, valueLabel)
                    amountLabel.isHidden = false
                    valueCurrencyLabel.isHidden = false
                    valueLabel.isHidden = false
                }
                
                let availableAmount = cosmosFetcher.balanceAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 6)
                
                let vestingAmount = cosmosFetcher.vestingAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                if (vestingAmount != NSDecimalNumber.zero) {
                    vestingLayer.isHidden = false
                    vestingLabel?.attributedText = WDP.dpAmount(vestingAmount.stringValue, vestingLabel!.font, 6)
                }
                
                let stakingAmount = cosmosFetcher.delegationAmountSum().multiplying(byPowerOf10: -msAsset.decimals!)
                stakingLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakingLabel!.font, 6)
                
                let unStakingAmount = cosmosFetcher.unbondingAmountSum().multiplying(byPowerOf10: -msAsset.decimals!)
                if (unStakingAmount != NSDecimalNumber.zero) {
                    unstakingLayer.isHidden = false
                    unstakingLabel?.attributedText = WDP.dpAmount(unStakingAmount.stringValue, unstakingLabel!.font, 6)
                }
                
                let rewardAmount = cosmosFetcher.rewardAmountSum(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                if (cosmosFetcher.rewardAllCoins().count > 0) {
                    rewardLayer.isHidden = false
                    if (cosmosFetcher.rewardOtherDenomTypeCnts() > 0) {
                        rewardTitle.text = "Reward + " + String(cosmosFetcher.rewardOtherDenomTypeCnts())
                    } else {
                        rewardTitle.text = "Reward"
                    }
                    rewardLabel?.attributedText = WDP.dpAmount(rewardAmount.stringValue, rewardLabel!.font, 6)
                }
                
                let commissionAmount = cosmosFetcher.commissionAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                if (cosmosFetcher.cosmosCommissions.count > 0) {
                    commissionLayer.isHidden = false
                    if (cosmosFetcher.commissionOtherDenoms() > 0) {
                        commissionTitle.text = "Commission + " + String(cosmosFetcher.commissionOtherDenoms())
                    } else {
                        commissionTitle.text = "Commission"
                    }
                    commissionLabel?.attributedText = WDP.dpAmount(commissionAmount.stringValue, commissionLabel!.font, 6)
                }
                
                let totalAmount = availableAmount.adding(vestingAmount).adding(stakingAmount)
                    .adding(unStakingAmount).adding(rewardAmount).adding(commissionAmount)
                amountLabel?.attributedText = WDP.dpAmount(totalAmount.stringValue, amountLabel!.font, 6)
                
                if (BaseData.instance.getHideValue()) {
                    availableLabel.text = "✱✱✱✱"
                    vestingLabel.text = "✱✱✱✱"
                    stakingLabel.text = "✱✱✱✱"
                    unstakingLabel.text = "✱✱✱✱"
                    rewardLabel.text = "✱✱✱✱"
                    commissionLabel.text = "✱✱✱✱"
                }
            }
        }
        
    }
    
    func bindOktAsset(_ oktChain: ChainOktEVM) {
        if let oktFetcher = oktChain.getOktfetcher(),
           let stakeDenom = oktChain.stakeDenom {
            stakingTitle.text = "Deposited"
            unstakingTitle.text = "Withdrawing"
            
            let value = oktFetcher.allCoinValue()
            coinImg.kf.setImage(with: ChainOktEVM.assetImg(stakeDenom), placeholder: UIImage(named: "tokenDefault"))
            symbolLabel.text = stakeDenom.uppercased()
            
            WDP.dpPrice(OKT_GECKO_ID, priceCurrencyLabel, priceLabel)
            WDP.dpPriceChanged(OKT_GECKO_ID, priceChangeLabel, priceChangePercentLabel)
            if (BaseData.instance.getHideValue()) {
                hidenValueLabel.isHidden = false
            } else {
                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
                amountLabel.isHidden = false
                valueCurrencyLabel.isHidden = false
                valueLabel.isHidden = false
            }
            
            let availableAmount = oktFetcher.oktBalanceAmount(stakeDenom)
            availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 18)
            
            let depositAmount = oktFetcher.oktDepositAmount()
            stakingLabel?.attributedText = WDP.dpAmount(depositAmount.stringValue, stakingLabel!.font, 18)
            
            let withdrawAmount = oktFetcher.oktWithdrawAmount()
            if (withdrawAmount != NSDecimalNumber.zero) {
                unstakingLayer.isHidden = false
                unstakingLabel?.attributedText = WDP.dpAmount(withdrawAmount.stringValue, unstakingLabel!.font, 18)
            }
            
            let totalAmount = availableAmount.adding(depositAmount).adding(withdrawAmount)
            amountLabel?.attributedText = WDP.dpAmount(totalAmount.stringValue, amountLabel!.font, 18)
            
            if (BaseData.instance.getHideValue()) {
                availableLabel.text = "✱✱✱✱"
                stakingLabel.text = "✱✱✱✱"
                unstakingLabel.text = "✱✱✱✱"
            }
        }
    }
    
    func bindNeutron(_ baseChain: ChainNeutron) {
        if let neutronFetcher = baseChain.getNeutronFetcher(),
           let stakeDenom = baseChain.stakeDenom {
            stakingTitle.text = "Vault Deposited"
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
                let value = neutronFetcher.denomValue(stakeDenom)
                coinImg.kf.setImage(with: msAsset.assetImg(), placeholder: UIImage(named: "tokenDefault"))
                symbolLabel.text = msAsset.symbol?.uppercased()
                
                WDP.dpPrice(msAsset, priceCurrencyLabel, priceLabel)
                WDP.dpPriceChanged(msAsset, priceChangeLabel, priceChangePercentLabel)
                if (BaseData.instance.getHideValue()) {
                    hidenValueLabel.isHidden = false
                } else {
                    WDP.dpValue(value, valueCurrencyLabel, valueLabel)
                    amountLabel.isHidden = false
                    valueCurrencyLabel.isHidden = false
                    valueLabel.isHidden = false
                }
                
                let availableAmount = neutronFetcher.balanceAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 6)
                
                let vestingAmount = neutronFetcher.neutronVestingAmount().multiplying(byPowerOf10: -msAsset.decimals!)
                if (vestingAmount != NSDecimalNumber.zero) {
                    vestingLayer.isHidden = false
                    vestingLabel?.attributedText = WDP.dpAmount(vestingAmount.stringValue, vestingLabel!.font, 6)
                }
                
                let depositedAmount = neutronFetcher.neutronDeposited.multiplying(byPowerOf10: -msAsset.decimals!)
                stakingLabel?.attributedText = WDP.dpAmount(depositedAmount.stringValue, stakingLabel!.font, 6)
                
                let totalAmount = availableAmount.adding(vestingAmount).adding(depositedAmount)
                amountLabel?.attributedText = WDP.dpAmount(totalAmount.stringValue, amountLabel!.font, 6)
                
                if (BaseData.instance.getHideValue()) {
                    availableLabel.text = "✱✱✱✱"
                    vestingLabel.text = "✱✱✱✱"
                    stakingLabel.text = "✱✱✱✱"
                }
            }
        }
    }
}
