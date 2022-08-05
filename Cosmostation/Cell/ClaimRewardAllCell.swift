//
//  ClaimRewardAllCell.swift
//  Cosmostation
//
//  Created by yongjoo on 23/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class ClaimRewardAllCell: UITableViewCell {
    
    @IBOutlet weak var totalRewardLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var claimAllCardView: CardView!
    @IBOutlet weak var compoundingCardView: CardView!
    
    weak var delegate: ClaimRewardAllDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.claimAllCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickReward (_:))))
        self.compoundingCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCompound (_:))))
    }
    
    var actionRewardAll: (() -> Void)? = nil
    var actionCompunding: (() -> Void)? = nil
    
    func updateView(_ chainConfig: ChainConfig?) {
        let mainDenom = WUtils.getMainDenom(chainConfig)
        let rewardSum = BaseData.instance.getRewardSum_gRPC(mainDenom)
        WDP.dpCoin(chainConfig, mainDenom, rewardSum, denomLabel, totalRewardLabel)
    }
    
    @objc func onClickReward (_ sender: UITapGestureRecognizer) {
        actionRewardAll?()
    }
    
    @objc func onClickCompound (_ sender: UITapGestureRecognizer) {
        actionCompunding?()
    }
    
}
