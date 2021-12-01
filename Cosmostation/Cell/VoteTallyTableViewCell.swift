//
//  VoteTallyTableViewCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/05/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class VoteTallyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.cardYes.borderWidth = 1
        self.cardNo.borderWidth = 1
        self.cardVeto.borderWidth = 1
        self.cardAbstain.borderWidth = 1
    }
    
    @IBOutlet weak var cardYes: CardView!
    @IBOutlet weak var progressYes: UIProgressView!
    @IBOutlet weak var percentYes: UILabel!
    @IBOutlet weak var myVoteYes: UIImageView!
    @IBOutlet weak var imgYes: UIImageView!
    @IBOutlet weak var cntYes: UILabel!
    
    @IBOutlet weak var cardNo: CardView!
    @IBOutlet weak var progressNo: UIProgressView!
    @IBOutlet weak var percentNo: UILabel!
    @IBOutlet weak var myVoteNo: UIImageView!
    @IBOutlet weak var imgNo: UIImageView!
    @IBOutlet weak var cntNo: UILabel!
    
    @IBOutlet weak var cardVeto: CardView!
    @IBOutlet weak var progressVeto: UIProgressView!
    @IBOutlet weak var percentVeto: UILabel!
    @IBOutlet weak var myVoteVeto: UIImageView!
    @IBOutlet weak var imgVeto: UIImageView!
    @IBOutlet weak var cntVeto: UILabel!
    
    @IBOutlet weak var cardAbstain: CardView!
    @IBOutlet weak var propressAbstain: UIProgressView!
    @IBOutlet weak var percentAbstain: UILabel!
    @IBOutlet weak var myVoteAbstain: UIImageView!
    @IBOutlet weak var imgAbstain: UIImageView!
    @IBOutlet weak var cntAbstain: UILabel!
    
    @IBOutlet weak var quorumTitle: UILabel!
    @IBOutlet weak var quorumRate: UILabel!
    @IBOutlet weak var turnoutTitle: UILabel!
    @IBOutlet weak var turnoutRate: UILabel!
    
    func onCheckMyVote (_ myVote:Vote?) {
        if (myVote == nil) { return }
        if (myVote?.option.caseInsensitiveCompare(Vote.OPTION_YES) == .orderedSame) {
            self.myVoteYes.isHidden = false
            self.cardYes.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
            
        } else if (myVote?.option.caseInsensitiveCompare(Vote.OPTION_NO) == .orderedSame) {
            self.myVoteNo.isHidden = false
            self.cardNo.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
            
        } else if (myVote?.option.caseInsensitiveCompare(Vote.OPTION_VETO) == .orderedSame) {
            self.myVoteVeto.isHidden = false
            self.cardVeto.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
            
        } else if (myVote?.option.caseInsensitiveCompare(Vote.OPTION_ABSTAIN) == .orderedSame) {
            self.myVoteAbstain.isHidden = false
            self.cardAbstain.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
        }
    }
    
    func onCheckMyVote_gRPC(_ option: Cosmos_Gov_V1beta1_VoteOption?) {
        if (option == nil) { return }
        if (option == Cosmos_Gov_V1beta1_VoteOption.yes) {
            self.myVoteYes.isHidden = false
            self.cardYes.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
            
        } else if (option == Cosmos_Gov_V1beta1_VoteOption.no) {
            self.myVoteNo.isHidden = false
            self.cardNo.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
            
        } else if (option == Cosmos_Gov_V1beta1_VoteOption.noWithVeto) {
            self.myVoteVeto.isHidden = false
            self.cardVeto.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
            
        } else if (option == Cosmos_Gov_V1beta1_VoteOption.abstain) {
            self.myVoteAbstain.isHidden = false
            self.cardAbstain.borderColor = UIColor.init(hexString: "#e4185d", alpha: 1.0)
        }
    }
    
    func onUpdateCards(_ chain: ChainType?, _ detail: MintscanProposalDetail) {
        progressYes.progress = detail.getYes().floatValue / 100
        progressNo.progress = detail.getNo().floatValue / 100
        progressVeto.progress = detail.getVeto().floatValue / 100
        propressAbstain.progress = detail.getAbstain().floatValue / 100

        percentYes.attributedText = WUtils.displayPercent(detail.getYes(), percentYes.font)
        percentNo.attributedText = WUtils.displayPercent(detail.getNo(), percentNo.font)
        percentVeto.attributedText = WUtils.displayPercent(detail.getVeto(), percentVeto.font)
        percentAbstain.attributedText = WUtils.displayPercent(detail.getAbstain(), percentAbstain.font)
        
        if (detail.proposal_status?.contains("VOTING") == true) {
            imgYes.isHidden = false
            imgNo.isHidden = false
            imgVeto.isHidden = false
            imgAbstain.isHidden = false
            cntYes.isHidden = false
            cntNo.isHidden = false
            cntVeto.isHidden = false
            cntAbstain.isHidden = false
            
            cntYes.text = detail.voteMeta?.yes
            cntNo.text = detail.voteMeta?.no
            cntVeto.text = detail.voteMeta?.no_with_veto
            cntAbstain.text = detail.voteMeta?.abstain
            
            quorumTitle.isHidden = false
            quorumRate.isHidden = false
            turnoutRate.isHidden = false
            turnoutTitle.isHidden = false
            quorumRate.attributedText = WUtils.displayPercent(WUtils.systemQuorum(chain).multiplying(byPowerOf10: 2), quorumRate.font)
            turnoutRate.attributedText = WUtils.displayPercent(detail.getTurnout(), turnoutRate.font)
        }
    }
}
