//
//  SelectValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

class SelectValidatorCell: UITableViewCell {
    
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var jailedImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vpLabel: UILabel!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.af.cancelImageRequest()
        logoImg.image = UIImage(named: "validatorDefault")
    }
    
    func onBindValidator(_ baseChain: CosmosClass, _ validator: Cosmos_Staking_V1beta1_Validator) {
        
        logoImg.af.setImage(withURL: baseChain.monikerImg(validator.operatorAddress))
        nameLabel.text = validator.description_p.moniker
        jailedImg.isHidden = !validator.jailed
        
        let stakeDenom = baseChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            
            let vpAmount = NSDecimalNumber(string: validator.tokens).multiplying(byPowerOf10: -msAsset.decimals!)
            vpLabel?.attributedText = WDP.dpAmount(vpAmount.stringValue, vpLabel!.font, 0)
            
            let commission = NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
            if (commission == NSDecimalNumber.zero) {
                commLabel.textColor = .colorGreen
                commPercentLabel.textColor = .colorGreen
            } else {
                commLabel.textColor = .color02
                commPercentLabel.textColor = .color02
            }
        }
    }
    
}
