//
//  ClaimRewardAllCell.swift
//  Cosmostation
//
//  Created by yongjoo on 23/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class ClaimRewardAllCell: UITableViewCell {
    
    @IBOutlet weak var totalRewardTitleLabel: UILabel!
    @IBOutlet weak var totalRewardLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var claimAllButton: TwoLinesButton!
    @IBOutlet weak var compoundButton: TwoLinesButton!
    
    var actionRewardAll: (() -> Void)? = nil
    var actionCompunding: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        totalRewardTitleLabel.text = NSLocalizedString("str_total_reward", comment: "")
        claimAllButton.setTitle(firstLineTitle: NSLocalizedString("str_one_click", comment: ""), firstLineColor: UIColor.photon,
                                secondLineText: NSLocalizedString("str_claim_reward_all", comment: ""), secondLineColor: UIColor.font05,
                                state: .normal)
        compoundButton.setTitle(firstLineTitle: NSLocalizedString("str_one_click", comment: ""), firstLineColor: UIColor.photon,
                                secondLineText: NSLocalizedString("str_compounding", comment: ""), secondLineColor: UIColor.font05,
                                state: .normal)
    }
    
    func updateView(_ chainConfig: ChainConfig?) {
        let mainDenom = chainConfig!.stakeDenom
        let rewardSum = BaseData.instance.getRewardSum_gRPC(mainDenom)
        WDP.dpCoin(chainConfig, mainDenom, rewardSum, denomLabel, totalRewardLabel)
    }
    
    @IBAction func onClickAllRewards(_ sender: Any) {
        actionRewardAll?()
    }
    
    @IBAction func onClickCompound(_ sender: Any) {
        actionCompunding?()
    }
}
