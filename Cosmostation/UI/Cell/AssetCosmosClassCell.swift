//
//  AssetCosmosClassCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

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
        rootView.setBlur()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        coinImg.af.cancelImageRequest()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    func bindCosmosStakeAsset(_ baseChain: CosmosClass) {
        if (baseChain is ChainOktEVM || baseChain is ChainOkt996Keccak) {
            bindOktAsset(baseChain)
            
        } else if (baseChain is ChainNeutron) {
            bindNeutron(baseChain)
            
        } else {
            let stakeDenom = baseChain.stakeDenom!
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
                let value = baseChain.denomValue(stakeDenom)
                coinImg.af.setImage(withURL: msAsset.assetImg())
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
                
                let availableAmount = baseChain.balanceAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 6)
                
                let vestingAmount = baseChain.vestingAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                if (vestingAmount != NSDecimalNumber.zero) {
                    vestingLayer.isHidden = false
                    vestingLabel?.attributedText = WDP.dpAmount(vestingAmount.stringValue, vestingLabel!.font, 6)
                }
                
                let stakingAmount = baseChain.delegationAmountSum().multiplying(byPowerOf10: -msAsset.decimals!)
                stakingLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakingLabel!.font, 6)
                
                let unStakingAmount = baseChain.unbondingAmountSum().multiplying(byPowerOf10: -msAsset.decimals!)
                if (unStakingAmount != NSDecimalNumber.zero) {
                    unstakingLayer.isHidden = false
                    unstakingLabel?.attributedText = WDP.dpAmount(unStakingAmount.stringValue, unstakingLabel!.font, 6)
                }
                
                let rewardAmount = baseChain.rewardAmountSum(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                if (baseChain.rewardAllCoins().count > 0) {
                    rewardLayer.isHidden = false
                    if (baseChain.rewardOtherDenomTypeCnts() > 0) {
                        rewardTitle.text = "Reward + " + String(baseChain.rewardOtherDenomTypeCnts())
                    } else {
                        rewardTitle.text = "Reward"
                    }
                    rewardLabel?.attributedText = WDP.dpAmount(rewardAmount.stringValue, rewardLabel!.font, 6)
                }
                
                let commissionAmount = baseChain.commissionAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                if (baseChain.cosmosCommissions.count > 0) {
                    commissionLayer.isHidden = false
                    if (baseChain.commissionOtherDenoms() > 0) {
                        commissionTitle.text = "Commission + " + String(baseChain.commissionOtherDenoms())
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
    
    func bindOktAsset(_ baseChain: CosmosClass) {
        if let oktChain = baseChain as? ChainOkt996Keccak {
            stakingTitle.text = "Deposited"
            unstakingTitle.text = "Withdrawing"
            
            let stakeDenom = baseChain.stakeDenom!
            let value = baseChain.allValue()
            coinImg.af.setImage(withURL: ChainOkt996Keccak.assetImg(stakeDenom))
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
            
            let availableAmount = oktChain.lcdBalanceAmount(stakeDenom)
            availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 18)
            
            let depositAmount = oktChain.lcdOktDepositAmount()
            stakingLabel?.attributedText = WDP.dpAmount(depositAmount.stringValue, stakingLabel!.font, 18)
            
            let withdrawAmount = oktChain.lcdOktWithdrawAmount()
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
            
        } else if let oktEvmChain = baseChain as? ChainOktEVM {
            stakingTitle.text = "Deposited"
            unstakingTitle.text = "Withdrawing"
            
            let stakeDenom = baseChain.stakeDenom!
            let value = baseChain.allValue()
            coinImg.af.setImage(withURL: ChainOkt996Keccak.assetImg(stakeDenom))
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
            
            let availableAmount = oktEvmChain.lcdBalanceAmount(stakeDenom)
            availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 18)
            
            let depositAmount = oktEvmChain.lcdOktDepositAmount()
            stakingLabel?.attributedText = WDP.dpAmount(depositAmount.stringValue, stakingLabel!.font, 18)
            
            let withdrawAmount = oktEvmChain.lcdOktWithdrawAmount()
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
    
    func bindNeutron(_ baseChain: CosmosClass) {
        if let neutronChain = baseChain as? ChainNeutron {
            stakingTitle.text = "Vault Deposited"
            let stakeDenom = neutronChain.stakeDenom!
            if let msAsset = BaseData.instance.getAsset(neutronChain.apiName, stakeDenom) {
                let value = neutronChain.denomValue(stakeDenom)
                coinImg.af.setImage(withURL: msAsset.assetImg())
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
                
                let availableAmount = neutronChain.balanceAmount(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
                availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, 6)
                
                let vestingAmount = neutronChain.neutronVestingAmount().multiplying(byPowerOf10: -msAsset.decimals!)
                if (vestingAmount != NSDecimalNumber.zero) {
                    vestingLayer.isHidden = false
                    vestingLabel?.attributedText = WDP.dpAmount(vestingAmount.stringValue, vestingLabel!.font, 6)
                }
                
                let depositedAmount = neutronChain.neutronDeposited.multiplying(byPowerOf10: -msAsset.decimals!)
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
