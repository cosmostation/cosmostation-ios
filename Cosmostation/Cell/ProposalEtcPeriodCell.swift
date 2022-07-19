//
//  ProposalEtcPeriodCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/06.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import GRPC
import NIO

class ProposalEtcPeriodCell: UITableViewCell {
    
    @IBOutlet weak var proposalTitleLabel: UILabel!
    @IBOutlet weak var myVoteStatusImg: UIImageView!
    @IBOutlet weak var proposalStateLabel: UILabel!
    @IBOutlet weak var proposalStateImg: UIImageView!
    
    var myVotes = Array<MintscanMyVote>()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        self.myVotes.removeAll()
        self.myVoteStatusImg.isHidden = true
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ proposal: MintscanProposalDetail, _ address: String) {
        let title = "# ".appending(proposal.id!).appending("  ").appending(proposal.title ?? "")
        proposalTitleLabel.text = title
        proposalStateLabel.text = WUtils.onProposalStatusTxt(proposal)
        proposalStateImg.image = WUtils.onProposalStatusImg(proposal)
        myVoteStatusImg.isHidden = true
        
        let request = Alamofire.request(BaseNetWork.mintscanMyVote(chainConfig, String(proposal.id!), address),
                                        method: .get,
                                        parameters: [:],
                                        encoding: URLEncoding.default,
                                        headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseDatas = res as? Array<NSDictionary> {
                    responseDatas.forEach { rawMyVote in
                        self.myVotes.append(MintscanMyVote.init(rawMyVote))
                    }
                    
                } else {
                    self.myVotes.removeAll()
                }
                
            case .failure(let error):
                self.myVotes.removeAll()
            }
            self.onBindMyVote()
        }
    }
    
    func onBindMyVote() {
        if (myVotes.count <= 0) {
            self.myVoteStatusImg.isHidden = true
            
        } else if (myVotes.count > 1) {
            self.myVoteStatusImg.image = UIImage.init(named: "imgVoteWeight")
            self.myVoteStatusImg.isHidden = false
            
        } else {
            let myVote = myVotes[0]
            if (myVote.answer == "yes") {
                self.myVoteStatusImg.image = UIImage.init(named: "imgVoteYes")
                self.myVoteStatusImg.isHidden = false
                
            } else if (myVote.answer == "no") {
                self.myVoteStatusImg.image = UIImage.init(named: "imgVoteNo")
                self.myVoteStatusImg.isHidden = false
                
            } else if (myVote.answer == "no with veto") {
                self.myVoteStatusImg.image = UIImage.init(named: "imgVoteVeto")
                self.myVoteStatusImg.isHidden = false
                
            } else if (myVote.answer == "abstain") {
                self.myVoteStatusImg.image = UIImage.init(named: "imgVoteAbstain")
                self.myVoteStatusImg.isHidden = false
                
            } else {
                self.myVoteStatusImg.isHidden = true
            }
        }
    }
    
}
