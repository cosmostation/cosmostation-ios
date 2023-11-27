//
//  AboutRewardAddressCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AboutRewardAddressCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var rewardAddressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindStakingInfo(_ chain: CosmosClass) {
        rewardAddressLabel.text = chain.rewardAddress
        rewardAddressLabel.adjustsFontSizeToFitWidth = true
        if (!chain.rewardAddress.isEmpty && chain.rewardAddress != chain.bechAddress) {
            rootView.backgroundView.layer.borderWidth = 1
            rootView.backgroundView.layer.borderColor = UIColor.colorPrimary.cgColor
        }
    }
    
}
