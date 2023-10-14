//
//  NeutronMultiVoteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NeutronMultiVoteCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var option0Layer: UIView!
    @IBOutlet weak var option0Btn: UIButton!
    @IBOutlet weak var option0TitleLabel: UILabel!
    @IBOutlet weak var option0DescriptionLabel: UILabel!
    @IBOutlet weak var option1Layer: UIView!
    @IBOutlet weak var option1Btn: UIButton!
    @IBOutlet weak var option1TitleLabel: UILabel!
    @IBOutlet weak var option1DescriptionLabel: UILabel!
    @IBOutlet weak var option2Layer: UIView!
    @IBOutlet weak var option2Btn: UIButton!
    @IBOutlet weak var option2TitleLabel: UILabel!
    @IBOutlet weak var option2DescriptionLabel: UILabel!
    @IBOutlet weak var option3Layer: UIView!
    @IBOutlet weak var option3Btn: UIButton!
    @IBOutlet weak var option3TitleLabel: UILabel!
    @IBOutlet weak var option3DescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        option0Btn.tag = 0
        option1Btn.tag = 1
        option2Btn.tag = 2
        option3Btn.tag = 3
        option0Btn.setImage(nil, for: .normal)
        option1Btn.setImage(nil, for: .normal)
        option2Btn.setImage(nil, for: .normal)
        option3Btn.setImage(nil, for: .normal)
        option0Btn.layer.borderWidth = 1
        option1Btn.layer.borderWidth = 1
        option2Btn.layer.borderWidth = 1
        option3Btn.layer.borderWidth = 1
        option0Btn.layer.borderColor = UIColor.color05.cgColor
        option1Btn.layer.borderColor = UIColor.color05.cgColor
        option2Btn.layer.borderColor = UIColor.color05.cgColor
        option3Btn.layer.borderColor = UIColor.color05.cgColor
    }
    
    override func prepareForReuse() {
        option0Btn.setImage(nil, for: .normal)
        option1Btn.setImage(nil, for: .normal)
        option2Btn.setImage(nil, for: .normal)
        option3Btn.setImage(nil, for: .normal)
        option0Btn.layer.borderColor = UIColor.color05.cgColor
        option1Btn.layer.borderColor = UIColor.color05.cgColor
        option2Btn.layer.borderColor = UIColor.color05.cgColor
        option3Btn.layer.borderColor = UIColor.color05.cgColor
        
        option0Layer.isHidden = false
        option1Layer.isHidden = false
        option2Layer.isHidden = true
        option3Layer.isHidden = true
    }
    
    var actionToggle: ((Int) -> Void)? = nil
    @IBAction func onClickVote(_ sender: UIButton) {
        actionToggle?(sender.tag)
    }
    
    func onBindmultiVote(_ proposal: JSON) {
        let id = proposal["id"].int64Value
        let contents = proposal["proposal"]
        
        titleLabel.text = "# ".appending(String(id)).appending("  ").appending(contents["title"].stringValue)
        
        let expirationTime = contents["expiration"]["at_time"].int64Value
        if (expirationTime > 0) {
            let time = expirationTime / 1000000
            timeLabel.text = WDP.dpFullTime(time).appending(" ").appending(WDP.dpTimeGap(time))
        }
        let expirationHeight = contents["expiration"]["at_height"].int64Value
        if (expirationHeight > 0) {
            timeLabel.text = "Expiration at : " + String(expirationHeight) + " Block"
        }
        timeLabel.isHidden = false
        
        
        let choice0 = proposal["proposal"]["choices"].arrayValue[0]
        option0TitleLabel.text = "Option 0" + "   : " + choice0["option_type"].stringValue
        option0DescriptionLabel.text = choice0["description"].stringValue
        
        let choice1 = proposal["proposal"]["choices"].arrayValue[1]
        option1TitleLabel.text = "Option 1" + "   : " + choice1["option_type"].stringValue
        option1DescriptionLabel.text = choice1["description"].stringValue
        
        
        if (proposal["proposal"]["choices"].arrayValue.count > 2) {
            let choice2 = proposal["proposal"]["choices"].arrayValue[2]
            option2TitleLabel.text = "Option 2" + "   : " + choice2["option_type"].stringValue
            option2DescriptionLabel.text = choice2["description"].stringValue
            option2Layer.isHidden = false
            
        } else if (proposal["proposal"]["choices"].arrayValue.count > 3) {
            let choice3 = proposal["proposal"]["choices"].arrayValue[3]
            option3TitleLabel.text = "Option 3" + "   : " + choice3["option_type"].stringValue
            option3DescriptionLabel.text = choice3["description"].stringValue
            option3Layer.isHidden = false
            option3Layer.isHidden = false
        }
        
        if (proposal["myVote"].int == 0) {
            option0Btn.setImage(UIImage(named: "iconCheck"), for: .normal)
            option0Btn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal["myVote"].int == 1) {
            option1Btn.setImage(UIImage(named: "iconCheck"), for: .normal)
            option1Btn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal["myVote"].int == 2) {
            option2Btn.setImage(UIImage(named: "iconCheck"), for: .normal)
            option2Btn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal["myVote"].int == 3) {
            option3Btn.setImage(UIImage(named: "iconCheck"), for: .normal)
            option3Btn.layer.borderColor = UIColor.white.cgColor
        }
        
    }
    
}
