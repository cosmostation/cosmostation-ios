//
//  SelectValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class SelectValidatorCell: UITableViewCell {
    
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var vpTitle: UILabel!
    @IBOutlet weak var vpLabel: UILabel!
    
    @IBOutlet weak var commTitle: UILabel!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!
    
    @IBOutlet weak var stakingTitle: UILabel!
    @IBOutlet weak var stakingLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "validatorDefault")
        inactiveTag.isHidden = true
        jailedTag.isHidden = true
        
        vpTitle.isHidden = true
        vpLabel.isHidden = true
        
        commTitle.isHidden = true
        commLabel.isHidden = true
        commPercentLabel.isHidden = true
        
        stakingTitle.isHidden = true
        stakingLabel.isHidden = true
    }
    
    func onBindValidator(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let cosmosFetcher = baseChain.getCosmosfetcher() else { return }
            inactiveTag.isHidden = cosmosFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            
            let vpAmount = NSDecimalNumber(string: validator.tokens).multiplying(byPowerOf10: -msAsset.decimals!)
            vpLabel?.attributedText = WDP.dpAmount(vpAmount.stringValue, vpLabel!.font, 0)
            
            let commission = NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        }
        
        vpTitle.isHidden = false
        vpLabel.isHidden = false
        
        commTitle.isHidden = false
        commLabel.isHidden = false
        commPercentLabel.isHidden = false
    }
    
    
    func onBindUnstakeValidator(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let cosmosFetcher = baseChain.getCosmosfetcher() else { return }
            inactiveTag.isHidden = cosmosFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let delegations = baseChain.getCosmosfetcher()?.cosmosDelegations,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            
            let staked = delegations.filter { $0.delegation.validatorAddress == validator.operatorAddress }.first?.balance.amount
            let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
            stakingLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakingLabel!.font, 6)
        }
        
        stakingTitle.isHidden = false
        stakingLabel.isHidden = false
    }
    
    
    func onBindSuiValidator(_ baseChain: BaseChain, _ validator: JSON) {
        logoImg.sd_setImage(with: validator.suiValidatorImg(), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.suiValidatorName()
        vpLabel?.attributedText = WDP.dpAmount(validator.suiValidatorVp().stringValue, vpLabel!.font, 0)
        commLabel?.attributedText = WDP.dpAmount(validator.suiValidatorCommission().stringValue, commLabel!.font, 2)
        
        vpTitle.isHidden = false
        vpLabel.isHidden = false
        commTitle.isHidden = false
        commLabel.isHidden = false
        commPercentLabel.isHidden = false
    }
    
    func onBindInitiaValidator(_ baseChain: BaseChain, _ validator: Initia_Mstaking_V1_Validator) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            
            let vpAmount = NSDecimalNumber(string: validator.tokens.filter({$0.denom == stakeDenom}).first?.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            vpLabel?.attributedText = WDP.dpAmount(vpAmount.stringValue, vpLabel!.font, 0)
            
            let commission = NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        }
        
        vpTitle.isHidden = false
        vpLabel.isHidden = false
        
        commTitle.isHidden = false
        commLabel.isHidden = false
        commPercentLabel.isHidden = false
    }
    
    func onBindUnstakeValidator(_ baseChain: BaseChain, _ validator: Initia_Mstaking_V1_Validator) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let initiaFetcher = (baseChain as? ChainInitia)?.getInitiaFetcher() else { return }
            inactiveTag.isHidden = initiaFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let delegations = (baseChain as? ChainInitia)?.getInitiaFetcher()?.initiaDelegations,
        let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let staked = delegations.filter { $0.delegation.validatorAddress == validator.operatorAddress }.first?.balance.filter({ $0.denom == stakeDenom }).first?.amount
            let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
            stakingLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakingLabel!.font, 6)
        }
        
        stakingTitle.isHidden = false
        stakingLabel.isHidden = false
    }
    
    func onBindValidator(_ baseChain: BaseChain, _ validator: Zrchain_Validation_ValidatorHV) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            
            let vpAmount = NSDecimalNumber(string: validator.tokensNative).multiplying(byPowerOf10: -msAsset.decimals!)
            vpLabel?.attributedText = WDP.dpAmount(vpAmount.stringValue, vpLabel!.font, 0)
            
            let commission = NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        }
        
        vpTitle.isHidden = false
        vpLabel.isHidden = false
        
        commTitle.isHidden = false
        commLabel.isHidden = false
        commPercentLabel.isHidden = false
    }
    
    func onBindUnstakeValidator(_ baseChain: BaseChain, _ validator: Zrchain_Validation_ValidatorHV) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let zenrockFetcher = (baseChain as? ChainZenrock)?.getZenrockFetcher() else { return }
            inactiveTag.isHidden = zenrockFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let delegations = (baseChain as? ChainZenrock)?.getZenrockFetcher()?.delegations,
        let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let staked = delegations.filter { $0.delegation.validatorAddress == validator.operatorAddress }.first?.balance.amount
            let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
            stakingLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakingLabel!.font, 6)
        }
        
        stakingTitle.isHidden = false
        stakingLabel.isHidden = false
    }

}
