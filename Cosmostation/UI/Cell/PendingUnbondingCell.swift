//
//  PendingUnbondingCell.swift
//  Cosmostation
//
//  Created by 차소민 on 3/11/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class PendingUnbondingCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unstakingTitle: UILabel!
    @IBOutlet weak var unstakingLabel: UILabel!
    @IBOutlet weak var pendingInfoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "iconValidatorDefault")
        inactiveTag.isHidden = true
        jailedTag.isHidden = true
    }
    func onBindMyUnbonding(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator, _ pendingData: PendingTx, _ epoch: UInt64?) {
        if let statusStr = pendingData.type_url?.status,
           let epoch {
            pendingInfoLabel.text = "\(statusStr) will activate in Next Epoch #\(epoch + 1)"
            unstakingTitle.text = statusStr
        }
        
        logoImg.sd_setImage(with: baseChain.monikerImg(validator.operatorAddress), placeholderImage: UIImage(named: "iconValidatorDefault"))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            guard let cosmosFetcher = baseChain.getCosmosfetcher() else { return }
            inactiveTag.isHidden = cosmosFetcher.isActiveValidator(validator)
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: pendingData.msg.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
        }
    }

}
