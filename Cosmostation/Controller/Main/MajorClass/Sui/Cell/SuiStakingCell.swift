//
//  SuiStakingCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/11/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class SuiStakingCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pendingTag: UIImageView!
    @IBOutlet weak var objectIdLabel: UILabel!
    @IBOutlet weak var totalStakedLabel: UILabel!
    @IBOutlet weak var principalLabel: UILabel!
    @IBOutlet weak var estimatedRewardLabel: UILabel!
    @IBOutlet weak var startEaringLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "iconValidatorDefault")
        pendingTag.isHidden = true
    }
    
    func onBindMyStake(_ baseChain: ChainSui, _ stake: SuiStakeReward) {
        if let suiFetcher = baseChain.suiFetcher {
            if let validator = suiFetcher.suiValidators.filter({ $0.address == stake.validatorAddress }).first {
                logoImg.sd_setImage(with: URL(string: validator.imageURL), placeholderImage: UIImage(named: "iconValidatorDefault"))
                nameLabel.text = validator.name
            }
        }
        
        if (stake.isPending) {
            pendingTag.isHidden = false
        }
        objectIdLabel.text = stake.objectId
        
        let principal = NSDecimalNumber(value: stake.principal).multiplying(byPowerOf10: -9)
        let estimatedReward = NSDecimalNumber(value: stake.estimatedReward).multiplying(byPowerOf10: -9)
        principalLabel?.attributedText = WDP.dpAmount(principal.stringValue, principalLabel!.font, 9)
        estimatedRewardLabel?.attributedText = WDP.dpAmount(estimatedReward.stringValue, estimatedRewardLabel!.font, 9)
        totalStakedLabel?.attributedText = WDP.dpAmount(estimatedReward.adding(principal).stringValue, totalStakedLabel!.font, 9)
        startEaringLabel.text = "Epoch #" + String(stake.activationEpoch)
    }
    
    func onBindMyStake(_ baseChain: ChainIota, _ stake: (String, JSON)) {
        if let iotaFetcher = baseChain.iotaFetcher {
            if let validator = iotaFetcher.iotaValidators.filter({ $0["iotaAddress"].stringValue == stake.0 }).first {
                logoImg.sd_setImage(with: validator.iotaValidatorImg(), placeholderImage: UIImage(named: "iconValidatorDefault"))
                nameLabel.text = validator.iotaValidatorName()
            }
        }
        
        if (stake.1["status"].stringValue == "Pending") {
            pendingTag.isHidden = false
        }
        objectIdLabel.text = stake.1["stakedIotaId"].stringValue
        
        let principal = NSDecimalNumber(value: stake.1["principal"].uInt64Value).multiplying(byPowerOf10: -9)
        let estimatedReward = NSDecimalNumber(value: stake.1["estimatedReward"].uInt64Value).multiplying(byPowerOf10: -9)
        principalLabel?.attributedText = WDP.dpAmount(principal.stringValue, principalLabel!.font, 9)
        estimatedRewardLabel?.attributedText = WDP.dpAmount(estimatedReward.stringValue, estimatedRewardLabel!.font, 9)
        totalStakedLabel?.attributedText = WDP.dpAmount(estimatedReward.adding(principal).stringValue, totalStakedLabel!.font, 9)
        startEaringLabel.text = "Epoch #" + stake.1["stakeActiveEpoch"].stringValue
    }

}
