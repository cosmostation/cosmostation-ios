//
//  WalletDetailRewardCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/12.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletDetailRewardCell: UITableViewCell {

    @IBOutlet weak var rootView: CardView!
    @IBOutlet weak var rewardAddressTitle: UILabel!
    @IBOutlet weak var rewardAddressLabel: UILabel!
    
    var actionReward: (() -> Void)? = nil
    @IBAction func onClickReward(_ sender: UIButton) {
        actionReward?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig, _ account: Account, _ rewardAddress: String?) {
        rootView.backgroundColor = chainConfig.chainColorBG
        rewardAddressLabel.text = rewardAddress
        rewardAddressLabel.adjustsFontSizeToFitWidth = true
        if (account.account_address != rewardAddress) {
            rewardAddressLabel.textColor = UIColor.init(hexString: "f31963")
        }
        rewardAddressTitle.text = NSLocalizedString("str_reward_recipient_address", comment: "")
    }
}
