//
//  VoteAllChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class VoteAllChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var myVotedImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var vetoBtn: UIButton!
    @IBOutlet weak var abstainBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        yesBtn.tag = Cosmos_Gov_V1beta1_VoteOption.yes.rawValue
        noBtn.tag = Cosmos_Gov_V1beta1_VoteOption.no.rawValue
        vetoBtn.tag = Cosmos_Gov_V1beta1_VoteOption.noWithVeto.rawValue
        abstainBtn.tag = Cosmos_Gov_V1beta1_VoteOption.abstain.rawValue
        yesBtn.layer.borderWidth = 1
        noBtn.layer.borderWidth = 1
        vetoBtn.layer.borderWidth = 1
        abstainBtn.layer.borderWidth = 1
        yesBtn.layer.borderColor = UIColor.color05.cgColor
        noBtn.layer.borderColor = UIColor.color05.cgColor
        vetoBtn.layer.borderColor = UIColor.color05.cgColor
        abstainBtn.layer.borderColor = UIColor.color05.cgColor
    }
    
    override func prepareForReuse() {
        yesBtn.layer.borderColor = UIColor.color05.cgColor
        noBtn.layer.borderColor = UIColor.color05.cgColor
        vetoBtn.layer.borderColor = UIColor.color05.cgColor
        abstainBtn.layer.borderColor = UIColor.color05.cgColor
    }
    
    var actionToggle: ((Int) -> Void)? = nil
    @IBAction func onClickVote(_ sender: UIButton) {
        actionToggle?(sender.tag)
    }
    
    func onBindVote(_ proposal: MintscanProposal, _ myVotes: [MintscanMyVotes]) {
        let title = "# ".appending(String(proposal.id!)).appending("  ").appending(proposal.title ?? "")
        titleLabel.text = title
        timeLabel.text = WDP.dpTime(proposal.voting_end_time).appending(" ").appending(WDP.dpTimeGap(proposal.voting_end_time))
        
        
        if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.yes) {
            yesBtn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.no) {
            noBtn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.noWithVeto) {
            vetoBtn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.abstain) {
            abstainBtn.layer.borderColor = UIColor.white.cgColor
            
        }
        
        if let rawVote = myVotes.filter({ $0.proposal_id == proposal.id }).first {
            if (rawVote.votes.count > 1) {
                self.myVotedImg.image = UIImage.init(named: "imgMyVoteWeight")
            } else {
                let myVote = rawVote.votes[0]
                if (myVote.option?.contains("OPTION_YES") == true) {
                    self.myVotedImg.image = UIImage.init(named: "imgMyVoteYes")
                } else if (myVote.option?.contains("OPTION_NO_WITH_VETO") == true) {
                    self.myVotedImg.image = UIImage.init(named: "imgMyVoteVeto")
                } else if (myVote.option?.contains("OPTION_NO") == true) {
                    self.myVotedImg.image = UIImage.init(named: "imgMyVoteNo")
                } else if (myVote.option?.contains("OPTION_ABSTAIN") == true) {
                    self.myVotedImg.image = UIImage.init(named: "imgMyVoteAbstain")
                } else {
                    self.myVotedImg.image = nil
                }
            }
        } else {
            self.myVotedImg.image = UIImage.init(named: "imgMyVoteNone")
        }
    }
    
}
