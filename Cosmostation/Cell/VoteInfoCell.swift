//
//  VoteInfoCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/05/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class VoteInfoCell: UITableViewCell {
 
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var proposalTitle: UILabel!
    @IBOutlet weak var proposerLabel: UILabel!
    @IBOutlet weak var proposerTitle: UILabel!
    @IBOutlet weak var proposalTypeLabel: UILabel!
    @IBOutlet weak var proposerTypeTitle: UILabel!
    @IBOutlet weak var voteStartTime: UILabel!
    @IBOutlet weak var voteStartTimeTitle: UILabel!
    @IBOutlet weak var voteEndTime: UILabel!
    @IBOutlet weak var voteEndTimeTitle: UILabel!
    @IBOutlet weak var requestAmount: UILabel!
    @IBOutlet weak var requestAmountTitle: UILabel!
    @IBOutlet weak var requestAmountDenom: UILabel!
    @IBOutlet weak var voteDescription: UITextView!
    @IBOutlet weak var voteDescriptionTitle: UILabel!
    @IBOutlet weak var btnToggle: UIButton!
    
    var actionLink: (() -> Void)? = nil
    var actionToggle: (() -> Void)? = nil
    var expended: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        proposalTitle.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        proposerTitle.text = NSLocalizedString("str_proposer", comment: "")
        
        proposerLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        proposalTypeLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        proposerTypeTitle.text = NSLocalizedString("str_proposal_type", comment: "")

        voteStartTime.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        voteStartTimeTitle.text = NSLocalizedString("str_voting_start_time", comment: "")

        voteEndTime.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        voteEndTimeTitle.text = NSLocalizedString("str_voting_end_time", comment: "")

        requestAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        requestAmountTitle.text = NSLocalizedString("str_request_amount", comment: "")

        requestAmountDenom.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        
        voteDescriptionTitle.text = NSLocalizedString("str_voting_description", comment: "")
    }
    
    
    @IBAction func onClickLink(_ sender: UIButton) {
        actionLink?()
    }
    
    @IBAction func onClikcToggle(_ sender: UIButton) {
        if (expended) {
            btnToggle.setImage(UIImage(named: "arrowDown"), for: .normal)
        } else {
            btnToggle.setImage(UIImage(named: "arrowUp"), for: .normal)
        }
        actionToggle?()
        expended = !expended
    }
    
}
