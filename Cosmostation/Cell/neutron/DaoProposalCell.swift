//
//  DaoProposalCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class DaoProposalCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLayer: UIView!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var myVoteImg: UIImageView!
    @IBOutlet weak var myVoteNum: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        self.timeLabel.isHidden = true
        self.statusLayer.isHidden = true
        self.myVoteImg.isHidden = true
        self.myVoteNum.isHidden = true
    }
    
    func onBindView(_ module: NeutronProposalModule, _ proposal: JSON, _ myVotes: Array<MintscanDaoVote>) {
        let id = proposal["id"].int64Value
        let contents = proposal["proposal"]
        
        titleLabel.text = "# ".appending(String(id)).appending("  ").appending(contents["title"].stringValue)
        
        let status = contents["status"].stringValue.lowercased()
        if (status == "open") {
            let expirationTime = contents["expiration"]["at_time"].int64Value
            if (expirationTime > 0) {
                let time = expirationTime / 1000000
                timeLabel.text = WDP.dpTime(time).appending(" ").appending(WDP.dpTimeGap(time))
            }
            let expirationHeight = contents["expiration"]["at_height"].int64Value
            if (expirationHeight > 0) {
                timeLabel.text = "Expiration at : " + String(expirationHeight) + " Block"
            }
            timeLabel.isHidden = false

        } else {
            if (status == "passed" || status == "executed") {
                statusImg.image = UIImage.init(named: "ImgGovPassed")
            } else if (status == "rejected" || status == "failed") {
                statusImg.image = UIImage.init(named: "ImgGovRejected")
            }
            statusTitle.text = status.uppercased()
            statusLayer.isHidden = false
        }
        
        if let myVote = myVotes.filter({ $0.contract_address == module.address && $0.proposal_id == id }).first {
            if (myVote.option == "yes") {
                myVoteImg.image = UIImage.init(named: "imgVoteYes")
                myVoteImg.isHidden = false
                return
                
            } else if (myVote.option == "no") {
                myVoteImg.image = UIImage.init(named: "imgVoteNo")
                myVoteImg.isHidden = false
                return
                
            } else if (myVote.option == "abstain") {
                myVoteImg.image = UIImage.init(named: "imgVoteAbstain")
                myVoteImg.isHidden = false
                return
            }
            
            if let numberOption = myVote.option {
                myVoteNum.text = "Option " + numberOption
//                myVoteNum.text = numberOption
                myVoteNum.isHidden = false
                return
            }
            
        } else {
            myVoteImg.image = UIImage.init(named: "imgNotVoted")
            myVoteImg.isHidden = false
        }
    }
    
}
