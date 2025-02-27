//
//  AssetBabylonCell.swift
//  Cosmostation
//
//  Created by 차소민 on 2/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import SDWebImage

class AssetBabylonCell: UITableViewCell {
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
    @IBOutlet weak var stakingLayer: UIView!
    @IBOutlet weak var stakingTitle: UILabel!
    @IBOutlet weak var stakingLabel: UILabel!
    @IBOutlet weak var unstakingLayer: UIView!
    @IBOutlet weak var unstakingTitle: UILabel!
    @IBOutlet weak var unstakingLabel: UILabel!
    @IBOutlet weak var rewardLayer: UIView!
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var btcRewardLayer: UIView!
    @IBOutlet weak var btcRewardTitle: UILabel!
    @IBOutlet weak var btcRewardLabel: UILabel!
    
    @IBOutlet weak var btcStakeView: UIView!
    
    var btcStakeDelegate: BtcStakeSheetDelegate?
    
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
        
        let btcStakeGesture = UITapGestureRecognizer(target: self, action: #selector(onBindBtcStakeSheet))
        btcStakeView.addGestureRecognizer(btcStakeGesture)
        btcStakeView.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        coinImg.sd_cancelCurrentImageLoad()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
        hidenValueLabel.isHidden = true
    }
    
    @objc func onBindBtcStakeSheet() {
        btcStakeDelegate?.onBindBtcStakeSheet()
    }

    func bindStakeAsset(_ baseChain: BaseChain) {
        let stakeDenom = baseChain.stakeDenom!
        if let cosmosFetcher = baseChain.getCosmosfetcher(),
           let babylonBtcFetcher = (baseChain as? ChainBabylon)?.getBabylonBtcFetcher(),
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let value = cosmosFetcher.denomValue(stakeDenom)
            
            coinImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            symbolLabel.text = msAsset.symbol
            
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
            
            //TODO: BTC reward
            let btcStakedReward = babylonBtcFetcher.btcStakedReward.multiplying(byPowerOf10: -msAsset.decimals!)
            if btcStakedReward != .zero {
                btcRewardLayer.isHidden = false
                btcRewardLabel.attributedText = WDP.dpAmount(btcStakedReward.stringValue, btcRewardLabel!.font, 6)
            }
            
            let totalAmount = availableAmount.adding(stakingAmount)
                .adding(unStakingAmount).adding(rewardAmount)
            amountLabel?.attributedText = WDP.dpAmount(totalAmount.stringValue, amountLabel!.font, 6)
            
            if (BaseData.instance.getHideValue()) {
                availableLabel.text = "✱✱✱✱"
                stakingLabel.text = "✱✱✱✱"
                unstakingLabel.text = "✱✱✱✱"
                rewardLabel.text = "✱✱✱✱"
            }
        }
    }
}


protocol BtcStakeSheetDelegate {
    func onBindBtcStakeSheet()
    func onBindBtcStakingInfoVC()
}
