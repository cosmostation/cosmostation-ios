//
//  StakeUnbondingCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class StakeUnbondingCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var finishGapLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var unstakingTitle: UILabel!
    @IBOutlet weak var unstakingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "validatorDefault")
        inactiveTag.isHidden = true
        jailedTag.isHidden = true
    }
    func onBindMyUnbonding(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator, _ unbonding: UnbondingEntry) {
        
        logoImg.setMonikerImg(baseChain, validator.operatorAddress)
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let cosmosFetcher = baseChain.getCosmosfetcher() else { return }
            inactiveTag.isHidden = cosmosFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: unbonding.entry.balance).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
            let completionTime = unbonding.entry.completionTime
            finishTimeLabel.text = WDP.dpDateWithSimpleTime(WUtils.timeInt64ToDate(completionTime.seconds * 1000))
            finishGapLabel.text = WDP.protoDpTimeGap(completionTime.seconds)
        }
    }
    
    func onBindInitiaMyUnbonding(_ baseChain: BaseChain, _ validator: Initia_Mstaking_V1_Validator, _ unbonding: InitiaUnbondingEntry) {
        
        logoImg.setMonikerImg(baseChain, validator.operatorAddress)
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let fetcher = (baseChain as? ChainInitia)?.getInitiaFetcher() else { return }
            inactiveTag.isHidden = fetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: unbonding.entry.balance.filter({ $0.denom == stakeDenom }).first?.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
            let completionTime = unbonding.entry.completionTime
            finishTimeLabel.text = WDP.dpDateWithSimpleTime(WUtils.timeInt64ToDate(completionTime.seconds * 1000))
            finishGapLabel.text = WDP.protoDpTimeGap(completionTime.seconds)
        }
    }
    
    func onBindZenrockMyUnbonding(_ baseChain: BaseChain, _ validator: Zrchain_Validation_ValidatorHV, _ unbonding: ZenrockUnbondingEntry) {
        
        logoImg.setMonikerImg(baseChain, validator.operatorAddress)
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let fetcher = (baseChain as? ChainZenrock)?.getZenrockFetcher() else { return }
            inactiveTag.isHidden = fetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: unbonding.entry.balance).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
            let completionTime = unbonding.entry.completionTime
            finishTimeLabel.text = WDP.dpDateWithSimpleTime(WUtils.timeInt64ToDate(completionTime.seconds * 1000))
            finishGapLabel.text = WDP.protoDpTimeGap(completionTime.seconds)
        }
    }

    func onBindBabylonUnbonding(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator, _ unbonding: UnbondingEntry) {
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "validatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let cosmosFetcher = baseChain.getCosmosfetcher() else { return }
            inactiveTag.isHidden = cosmosFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom),
           let fetcher = (baseChain as? ChainBabylon)?.getBabylonFetcher() {
            let unbondingAmount = NSDecimalNumber(string: unbonding.entry.balance).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
            
            let daysToSubtract: Int64 = Int64(baseChain.getChainParam()["params"]["staking_params"]["params"]["unbonding_time"].stringValue.filter({ $0.isNumber })) ?? 0
            let unbondedTime = unbonding.entry.completionTime.seconds - daysToSubtract
            let completionTime = unbondedTime + Int64(fetcher.unbondingCompletionTime ?? 0)
            
            finishTimeLabel.text = WDP.dpDateWithSimpleTime(WUtils.timeInt64ToDate(completionTime * 1000))
            finishGapLabel.text = "Est. " + WDP.dpTimeUntil(completionTime)
        }
    }
}
