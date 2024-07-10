//
//  StakeUnbondingCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage
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
        logoImg.af.cancelImageRequest()
        logoImg.image = UIImage(named: "validatorDefault")
        inactiveTag.isHidden = true
        jailedTag.isHidden = true
    }
    func onBindMyUnbonding(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator, _ unbonding: UnbondingEntry) {
        
        logoImg.af.setImage(withURL: baseChain.monikerImg(validator.operatorAddress))
        nameLabel.text = validator.description_p.moniker
        if (validator.jailed) {
            jailedTag.isHidden = false
        } else {
            inactiveTag.isHidden = validator.status == .bonded
        }
        
        if let stakeDenom = baseChain.stakeDenom,
           let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: unbonding.entry.balance).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
            let completionTime = unbonding.entry.completionTime
            finishTimeLabel.text = WDP.protoDpTime(completionTime.seconds)
            finishGapLabel.text = WDP.protoDpTimeGap(completionTime.seconds)
        }
    }
    
}
