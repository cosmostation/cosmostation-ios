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
    @IBOutlet weak var warnView: UIView!
    @IBOutlet weak var warnIconImageView: UIImageView!
    @IBOutlet weak var warnMsgLabel: UILabel!
    @IBOutlet weak var rewardAddressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        warnView.isHidden = true
        rewardAddressLabel.text = ""
        rewardAddressLabel.textColor = .color01
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onTapAddressChange))
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(addressTap)
    }
    
    override func prepareForReuse() {
        rewardAddressLabel.text = ""
        rewardAddressLabel.textColor = .color01
    }
    
    var actionTap: (() -> Void)? = nil
    
    func onBindStakingInfo(_ chain: BaseChain) {
        warnMsgLabel.text = NSLocalizedString("msg_already_changed_reward_address", comment: "")
        let description = NSLocalizedString("msg_reward_address", comment: "")
        let description_underline = NSLocalizedString("msg_reward_address_under", comment: "")
        let attributedString = NSMutableAttributedString(string: description)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: (description as NSString).range(of:description_underline))
        descriptionLabel.attributedText = attributedString
        
        if let rewardAddress = chain.getCosmosfetcher()?.rewardAddress {
            rewardAddressLabel.text = rewardAddress
            rewardAddressLabel.adjustsFontSizeToFitWidth = true
            if (rewardAddress != chain.bechAddress) {
                warnView.isHidden = false
                rewardAddressLabel.textColor = .colorRed
            }
        }
    }
    
    @objc func onTapAddressChange() {
        print("onTapAddressChange")
        actionTap?()
    }
    
}
