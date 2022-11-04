//
//  VoteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/07.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class VoteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var btnVeto: UIButton!
    @IBOutlet weak var vetoLabel: UILabel!
    @IBOutlet weak var btnAbstain: UIButton!
    @IBOutlet weak var abstainLabel: UILabel!
    
    var actionYes: (() -> Void)? = nil
    var actionNo: (() -> Void)? = nil
    var actionVeto: (() -> Void)? = nil
    var actionAbstain: (() -> Void)? = nil
    
    @IBAction func onClickYes(_ sender: UIButton) {
        actionYes?()
    }
    @IBAction func onClickNo(_ sender: UIButton) {
        actionNo?()
    }
    @IBAction func onClickVeto(_ sender: UIButton) {
        actionVeto?()
    }
    @IBAction func onClickAbstain(_ sender: UIButton) {
        actionAbstain?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ proposal: MintscanProposalDetail) {
        let title = "# ".appending(proposal.id!).appending("  ").appending(proposal.title ?? "")
        let time = WDP.dpTime(proposal.voting_end_time).appending(" ").appending(WDP.dpTimeGap(proposal.voting_end_time))
        titleLabel.text = title
        timeLabel.text = time
        
        onCheckDim()
        if (proposal.getMyVote() == "Yes") {
            yesLabel.textColor = chainConfig?.chainColor
            btnYes.tintColor = chainConfig?.chainColor
            btnYes.layer.borderColor = chainConfig!.chainColor.cgColor
            
        } else if (proposal.getMyVote() == "No") {
            noLabel.textColor = chainConfig?.chainColor
            btnNo.tintColor = chainConfig?.chainColor
            btnNo.layer.borderColor = chainConfig!.chainColor.cgColor
            
        } else if (proposal.getMyVote() == "NoWithVeto") {
            vetoLabel.textColor = chainConfig?.chainColor
            btnVeto.tintColor = chainConfig?.chainColor
            btnVeto.layer.borderColor = chainConfig!.chainColor.cgColor
            
        } else if (proposal.getMyVote() == "Abstain") {
            abstainLabel.textColor = chainConfig?.chainColor
            btnAbstain.tintColor = chainConfig?.chainColor
            btnAbstain.layer.borderColor = chainConfig!.chainColor.cgColor
            
        }
    }
    
    func onCheckDim() {
        yesLabel.textColor = UIColor.font03
        btnYes.tintColor = UIColor.font03
        btnYes.layer.borderColor = UIColor.font03.cgColor
        noLabel.textColor = UIColor.font03
        btnNo.layer.borderColor = UIColor.font03.cgColor
        btnNo.tintColor = UIColor.font03
        vetoLabel.textColor = UIColor.font03
        btnVeto.tintColor = UIColor.font03
        btnVeto.layer.borderColor = UIColor.font03.cgColor
        abstainLabel.textColor = UIColor.font03
        btnAbstain.tintColor = UIColor.font03
        btnAbstain.layer.borderColor = UIColor.font03.cgColor
    }
    
}
