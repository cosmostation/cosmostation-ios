//
//  VoteDetailStatusCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/05/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class VoteDetailStatusCell: UITableViewCell {
    
    @IBOutlet weak var cardYes: CardView!
    @IBOutlet weak var titleYes: UILabel!
    @IBOutlet weak var progressYes: UIProgressView!
    @IBOutlet weak var percentYes: UILabel!
    @IBOutlet weak var myVoteYes: UIImageView!
    @IBOutlet weak var cntYes: UILabel!
    
    @IBOutlet weak var cardNo: CardView!
    @IBOutlet weak var titleNo: UILabel!
    @IBOutlet weak var progressNo: UIProgressView!
    @IBOutlet weak var percentNo: UILabel!
    @IBOutlet weak var myVoteNo: UIImageView!
    @IBOutlet weak var cntNo: UILabel!
    
    @IBOutlet weak var cardVeto: CardView!
    @IBOutlet weak var titleVeto: UILabel!
    @IBOutlet weak var progressVeto: UIProgressView!
    @IBOutlet weak var percentVeto: UILabel!
    @IBOutlet weak var myVoteVeto: UIImageView!
    @IBOutlet weak var cntVeto: UILabel!
    
    @IBOutlet weak var cardAbstain: CardView!
    @IBOutlet weak var titleAbstain: UILabel!
    @IBOutlet weak var propressAbstain: UIProgressView!
    @IBOutlet weak var percentAbstain: UILabel!
    @IBOutlet weak var myVoteAbstain: UIImageView!
    @IBOutlet weak var cntAbstain: UILabel!
    
    @IBOutlet weak var quorumTitle: UILabel!
    @IBOutlet weak var quorumRate: UILabel!
    @IBOutlet weak var turnoutTitle: UILabel!
    @IBOutlet weak var turnoutRate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        myVoteYes.image = myVoteYes.image?.withRenderingMode(.alwaysTemplate)
        myVoteYes.tintColor = UIColor.font05
        titleYes.text = NSLocalizedString("str_vote_yes", comment: "")
        myVoteNo.image = myVoteNo.image?.withRenderingMode(.alwaysTemplate)
        myVoteNo.tintColor = UIColor.font05
        titleNo.text = NSLocalizedString("str_vote_no", comment: "")
        myVoteVeto.image = myVoteVeto.image?.withRenderingMode(.alwaysTemplate)
        myVoteVeto.tintColor = UIColor.font05
        titleVeto.text = NSLocalizedString("str_vote_veto", comment: "")
        myVoteAbstain.image = myVoteAbstain.image?.withRenderingMode(.alwaysTemplate)
        myVoteAbstain.tintColor = UIColor.font05
        titleAbstain.text = NSLocalizedString("str_vote_abstain", comment: "")
        
        quorumTitle.text = NSLocalizedString("str_quorum", comment: "")
        turnoutTitle.text = NSLocalizedString("str_current_turnout", comment: "")
    }
    
    func onCheckMyVote_gRPC(_ option: Cosmos_Gov_V1beta1_VoteOption?) {
        if (option == nil) { return }
        onCheckDim()
        if (option == Cosmos_Gov_V1beta1_VoteOption.yes) {
            cardYes.borderWidth = 1
            myVoteYes.isHidden = false
            titleYes.textColor = UIColor.init(named: "_voteYes")
            progressYes.progressTintColor = UIColor(named: "_voteYes")
            percentYes.textColor = UIColor.font05
            cntYes.textColor = UIColor.font05

        } else if (option == Cosmos_Gov_V1beta1_VoteOption.no) {
            cardNo.borderWidth = 1
            myVoteNo.isHidden = false
            titleNo.textColor = UIColor.init(named: "_voteNo")
            progressNo.progressTintColor = UIColor(named: "_voteNo")
            percentNo.textColor = UIColor.font05
            cntNo.textColor = UIColor.font05

        } else if (option == Cosmos_Gov_V1beta1_VoteOption.noWithVeto) {
            cardVeto.borderWidth = 1
            myVoteVeto.isHidden = false
            titleVeto.textColor = UIColor.init(named: "_voteVeto")
            progressVeto.progressTintColor = UIColor(named: "_voteVeto")
            percentVeto.textColor = UIColor.font05
            cntVeto.textColor = UIColor.font05

        } else if (option == Cosmos_Gov_V1beta1_VoteOption.abstain) {
            cardAbstain.borderWidth = 1
            myVoteAbstain.isHidden = false
            titleAbstain.textColor = UIColor.init(named: "_voteAbstain")
            propressAbstain.progressTintColor = UIColor(named: "_voteAbstain")
            percentAbstain.textColor = UIColor.font05
            cntAbstain.textColor = UIColor.font05
        }
    }
    
    func onCheckDim() {
        titleYes.textColor = UIColor.font03
        progressYes.progressTintColor = UIColor.font04
        percentYes.textColor = UIColor.font03
        cntYes.textColor = UIColor.font03
        
        titleNo.textColor = UIColor.font03
        progressNo.progressTintColor = UIColor.font04
        percentNo.textColor = UIColor.font03
        cntNo.textColor = UIColor.font03
        
        titleVeto.textColor = UIColor.font03
        progressVeto.progressTintColor = UIColor.font04
        percentVeto.textColor = UIColor.font03
        cntVeto.textColor = UIColor.font03
        
        titleAbstain.textColor = UIColor.font03
        propressAbstain.progressTintColor = UIColor.font04
        percentAbstain.textColor = UIColor.font03
        cntAbstain.textColor = UIColor.font03
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
            cntYes.isHidden = false
            cntNo.isHidden = false
            cntVeto.isHidden = false
            cntAbstain.isHidden = false
            
            cntYes.text = detail.voteMeta?.yes ?? "0"
            cntNo.text = detail.voteMeta?.no ?? "0"
            cntVeto.text = detail.voteMeta?.no_with_veto ?? "0"
            cntAbstain.text = detail.voteMeta?.abstain ?? "0"
            
            quorumTitle.isHidden = false
            quorumRate.isHidden = false
            turnoutRate.isHidden = false
            turnoutTitle.isHidden = false
            quorumRate.attributedText = WUtils.displayPercent(WUtils.systemQuorum(chain).multiplying(byPowerOf10: 2), quorumRate.font)
            turnoutRate.attributedText = WUtils.displayPercent(detail.getTurnout(), turnoutRate.font)
        }
    }
}
