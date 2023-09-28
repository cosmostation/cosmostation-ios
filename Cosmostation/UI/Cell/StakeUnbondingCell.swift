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
    @IBOutlet weak var jailedImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var finishGapLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var unstakingTitle: UILabel!
    @IBOutlet weak var unstakingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        logoImg.layer.cornerRadius = logoImg.frame.height/2
        logoImg.clipsToBounds = true
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        logoImg.af.cancelImageRequest()
        logoImg.image = UIImage(named: "validatorDefault")
    }
    
    func onBindMyUnbonding(_ baseChain: CosmosClass, _ validator: Cosmos_Staking_V1beta1_Validator, _ unbonding: UnbondingEntry) {
        
        logoImg.af.setImage(withURL: baseChain.monikerImg(validator.operatorAddress))
        nameLabel.text = validator.description_p.moniker
        jailedImg.isHidden = !validator.jailed
        
        let stakeDenom = baseChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: unbonding.entry.balance).multiplying(byPowerOf10: -msAsset.decimals!)
            unstakingLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, unstakingLabel!.font, msAsset.decimals!)
            
            let completionTime = unbonding.entry.completionTime
            finishTimeLabel.text = WDP.protoDpTime(completionTime.seconds)
            finishGapLabel.text = WDP.protoDpTimeGap(completionTime.seconds)
        }
    }
    
}
