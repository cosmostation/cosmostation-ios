//
//  VoteDetailStatusCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/05/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class VoteDetailStatusCell: UITableViewCell {
    
    @IBOutlet weak var currentStatusTitle: UILabel!
    @IBOutlet weak var myVoteTitle: UILabel!
    @IBOutlet weak var quorumTitle: UILabel!
    @IBOutlet weak var turnoutTitle: UILabel!
    
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var myVoteImg: UIImageView!
    @IBOutlet weak var myVoteLabel: UILabel!
    @IBOutlet weak var quorumLabel: UILabel!
    @IBOutlet weak var turnoutLabel: UILabel!
    
    @IBOutlet weak var titleYes: UILabel!
    @IBOutlet weak var progressYes: UIProgressView!
    @IBOutlet weak var percentYes: UILabel!
    @IBOutlet weak var titleNo: UILabel!
    @IBOutlet weak var progressNo: UIProgressView!
    @IBOutlet weak var percentNo: UILabel!
    @IBOutlet weak var titleVeto: UILabel!
    @IBOutlet weak var progressVeto: UIProgressView!
    @IBOutlet weak var percentVeto: UILabel!
    @IBOutlet weak var titleAbstain: UILabel!
    @IBOutlet weak var propressAbstain: UIProgressView!
    @IBOutlet weak var percentAbstain: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        currentStatusTitle.text = NSLocalizedString("str_current_status", comment: "")
        myVoteTitle.text = NSLocalizedString("str_opinion", comment: "")
        quorumTitle.text = NSLocalizedString("str_quorum", comment: "")
        turnoutTitle.text = NSLocalizedString("str_current_turnout", comment: "")
        titleYes.text = NSLocalizedString("str_vote_yes", comment: "")
        titleNo.text = NSLocalizedString("str_vote_no", comment: "")
        titleVeto.text = NSLocalizedString("str_vote_veto", comment: "")
        titleAbstain.text = NSLocalizedString("str_vote_abstain", comment: "")
    }
    
    func onBindView(_ proposalDetail: MintscanProposalDetail?, _ myVotes: MintscanMyVotes?) {
        
        if let detail = proposalDetail {
            if (proposalDetail?.is_expedited == true) {
                quorumLabel.attributedText = WUtils.displayPercent(WUtils.expeditedQuorum().multiplying(byPowerOf10: 2), quorumLabel.font)
            } else {
                quorumLabel.attributedText = WUtils.displayPercent(WUtils.systemQuorum().multiplying(byPowerOf10: 2), quorumLabel.font)
            }
            turnoutLabel.attributedText = WUtils.displayPercent(detail.getTurnout(), turnoutLabel.font)
            
            let status = detail.getStatus()
            if (status.pass == true) {
                currentStatusLabel.text = "PASS"
                currentStatusLabel.textColor = UIColor(named: "_voteYes")
            } else {
                currentStatusLabel.text = "REJECT"
                currentStatusLabel.textColor = UIColor(named: "_voteNo")
            }
            reasonLabel.text = status.reason
            
            progressYes.progress = detail.getYes().floatValue / 100
            progressNo.progress = detail.getNo().floatValue / 100
            progressVeto.progress = detail.getVeto().floatValue / 100
            propressAbstain.progress = detail.getAbstain().floatValue / 100

            percentYes.attributedText = WUtils.displayPercent(detail.getYes(), percentYes.font)
            percentNo.attributedText = WUtils.displayPercent(detail.getNo(), percentNo.font)
            percentVeto.attributedText = WUtils.displayPercent(detail.getVeto(), percentVeto.font)
            percentAbstain.attributedText = WUtils.displayPercent(detail.getAbstain(), percentAbstain.font)
        }
        
        if let myVotes = myVotes {
            if (myVotes.votes.count > 1) {
                myVoteImg.image = UIImage.init(named: "imgMyVoteWeight")
                myVoteLabel.text = NSLocalizedString("str_vote_weight", comment: "").uppercased()
                myVoteLabel.textColor = UIColor(named: "_voteWeight")
                
            } else {
                let myVote = myVotes.votes[0]
                if (myVote.option?.contains("OPTION_YES") == true) {
                    myVoteImg.image = UIImage.init(named: "imgMyVoteYes")
                    myVoteLabel.text = NSLocalizedString("str_vote_yes", comment: "").uppercased()
                    myVoteLabel.textColor = UIColor(named: "_voteYes")
                    return
                } else if (myVote.option?.contains("OPTION_NO_WITH_VETO") == true) {
                    myVoteImg.image = UIImage.init(named: "imgMyVoteVeto")
                    myVoteLabel.text = NSLocalizedString("str_vote_veto", comment: "").uppercased()
                    myVoteLabel.textColor = UIColor(named: "_voteVeto")
                    return
                } else if (myVote.option?.contains("OPTION_NO") == true) {
                    myVoteImg.image = UIImage.init(named: "imgMyVoteNo")
                    myVoteLabel.text = NSLocalizedString("str_vote_no", comment: "").uppercased()
                    myVoteLabel.textColor = UIColor(named: "_voteNo")
                    return
                } else if (myVote.option?.contains("OPTION_ABSTAIN") == true) {
                    myVoteImg.image = UIImage.init(named: "imgMyVoteAbstain")
                    myVoteLabel.text = NSLocalizedString("str_vote_abstain", comment: "").uppercased()
                    myVoteLabel.textColor = UIColor(named: "_voteAbstain")
                    return
                }
            }
            
        } else {
            myVoteImg.image = UIImage.init(named: "imgMyVoteNone")
            myVoteLabel.text = NSLocalizedString("str_vote_yet", comment: "").uppercased()
            myVoteLabel.textColor = UIColor(named: "_voteNotVoted")
        }
    }
}
