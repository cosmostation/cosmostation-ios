//
//  OktValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class OktValidatorCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vpLabel: UILabel!

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
    
    func bindOktValidator( _ chain: BaseChain, _ validator: JSON) {
        logoImg.setMonikerImg(chain, validator["operator_address"].stringValue)
        nameLabel.text = validator["description"]["moniker"].stringValue
        
        let vp = validator["delegator_shares"].doubleValue
        vpLabel?.attributedText = WDP.dpAmount(String(vp), vpLabel!.font, 2)
        
        if (validator["jailed"].boolValue) {
            jailedTag.isHidden = false
        } else {
            inactiveTag.isHidden = validator["status"].intValue == 2
        }
    }
    
}
