//
//  NeutronSingleVoteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NeutronSingleVoteCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var abstainBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        yesBtn.tag = 0
        noBtn.tag = 1
        abstainBtn.tag = 2
        yesBtn.setImage(nil, for: .normal)
        noBtn.setImage(nil, for: .normal)
        abstainBtn.setImage(nil, for: .normal)
        yesBtn.layer.borderWidth = 1
        noBtn.layer.borderWidth = 1
        abstainBtn.layer.borderWidth = 1
        yesBtn.layer.borderColor = UIColor.color05.cgColor
        noBtn.layer.borderColor = UIColor.color05.cgColor
        abstainBtn.layer.borderColor = UIColor.color05.cgColor
    }
    
    override func prepareForReuse() {
        yesBtn.setImage(nil, for: .normal)
        noBtn.setImage(nil, for: .normal)
        abstainBtn.setImage(nil, for: .normal)
        yesBtn.layer.borderColor = UIColor.color05.cgColor
        noBtn.layer.borderColor = UIColor.color05.cgColor
        abstainBtn.layer.borderColor = UIColor.color05.cgColor
    }
    
    var actionToggle: ((Int) -> Void)? = nil
    @IBAction func onClickVote(_ sender: UIButton) {
        actionToggle?(sender.tag)
    }
    
    func onBindsingleVote(_ proposal: JSON) {
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
        
        if (proposal["myVote"].string == "yes") {
            yesBtn.setImage(UIImage(named: "iconCheck"), for: .normal)
            yesBtn.layer.borderColor = UIColor.white.cgColor
        } else if (proposal["myVote"].string == "no") {
            noBtn.setImage(UIImage(named: "iconCheck"), for: .normal)
            noBtn.layer.borderColor = UIColor.white.cgColor
        } else if (proposal["myVote"].string == "abstain") {
            abstainBtn.setImage(UIImage(named: "iconCheck"), for: .normal)
            abstainBtn.layer.borderColor = UIColor.white.cgColor
        }
    }
}
