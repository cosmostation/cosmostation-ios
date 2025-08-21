//
//  BaseMsgSheetCell.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2023/04/10.
//

import UIKit

class BaseMsgSheetCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var checkColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindCreate(_ position: Int) {
        if (position == 0) {
            titleLabel.text = NSLocalizedString("create_wallet", comment: "")
            descriptionLabel.text = NSLocalizedString("create_wallet_msg", comment: "")
            
        } else if (position == 1) {
            titleLabel.text = NSLocalizedString("import_mnemonic", comment: "")
            descriptionLabel.text = NSLocalizedString("import_mnemonic_msg", comment: "")
            
        } else if (position == 2) {
            titleLabel.text = NSLocalizedString("import_private_key", comment: "")
            descriptionLabel.text = NSLocalizedString("import_private_key_msg", comment: "")
            
        } else if (position == 3) {
            titleLabel.text = NSLocalizedString("import_qr", comment: "")
            descriptionLabel.text = NSLocalizedString("import_qr_msg", comment: "")
            
        } else {
            titleLabel.text = ""
        }
    }
    
    func onBindMnemonicAccount(_ position: Int) {
        if (position == 0) {
            titleLabel.text = NSLocalizedString("str_rename", comment: "")
            descriptionLabel.text = ""
            
        } else if (position == 1) {
            titleLabel.text = NSLocalizedString("str_check_mnemonic", comment: "")
            descriptionLabel.text = ""
            
        } else if (position == 2) {
            titleLabel.text = NSLocalizedString("str_check_each_private_keys", comment: "")
            descriptionLabel.text = ""
            
        } else {
            titleLabel.text = NSLocalizedString("str_delete_account", comment: "")
            descriptionLabel.text = ""
        }
    }
    
    func onBindPrivateKeyAccount(_ position: Int) {
        if (position == 0) {
            titleLabel.text = NSLocalizedString("str_rename", comment: "")
            descriptionLabel.text = ""
            
        } else if (position == 1) {
            titleLabel.text = NSLocalizedString("str_check_private_key", comment: "")
            descriptionLabel.text = ""
            
        } else {
            titleLabel.text = NSLocalizedString("str_delete_account", comment: "")
            descriptionLabel.text = ""
        }
        
    }
    
    
    func onBindDelegate(_ position: Int) {
        if (position == 0) {
            titleLabel.text = NSLocalizedString("str_stake", comment: "")
            descriptionLabel.text = NSLocalizedString("str_stake_msg", comment: "")
            
        } else if (position == 1) {
            titleLabel.text = NSLocalizedString("str_unstake", comment: "")
            descriptionLabel.text = NSLocalizedString("str_unstake_msg", comment: "")
            
        } else if (position == 2) {
            titleLabel.text = NSLocalizedString("str_switch_validator", comment: "")
            descriptionLabel.text = NSLocalizedString("str_switch_validator_msg", comment: "")
            
        } else if (position == 3) {
            titleLabel.text = NSLocalizedString("str_cliam_reward", comment: "")
            descriptionLabel.text = NSLocalizedString("str_cliam_reward_msg", comment: "")
            
        } else if (position == 4) {
            titleLabel.text = NSLocalizedString("str_compounding", comment: "")
            descriptionLabel.text = NSLocalizedString("str_compounding_msg", comment: "")
            
        } else {
            titleLabel.text = ""
        }
    }
    
    func onBindUndelegate(_ position: Int) {
        titleLabel.text = NSLocalizedString("str_cancel_unbonding", comment: "")
        descriptionLabel.text = NSLocalizedString("str_cancel_unbonding_msg", comment: "")
    }
    
    func onBindDappSort(_ position: Int, _ selectedSortType: DappSortType?) {
        checkImageView.isHidden = !(position == selectedSortType?.rawValue)
        checkColorView.isHidden = !(position == selectedSortType?.rawValue)
        contentView.backgroundColor = position == selectedSortType?.rawValue ? UIColor.color08 : UIColor.clear
        descriptionLabel.textColor = .color03

        if position == 0 {
            titleLabel.text = "Alphabetical Asc. (A -> Z)"
            descriptionLabel.text = "Sort the list alphabetically"

        } else {
            titleLabel.text = "Multi-Network Support"
            descriptionLabel.text = "Sort the list by the number of supported networks"
        }
    }
    
    func onBindBtcWithdraw() {
        titleLabel.text = NSLocalizedString("str_withdraw", comment: "")
        descriptionLabel.text = NSLocalizedString("str_withdraw_msg", comment: "")
    }
    
    func onBindSendType(_ position: Int, _ targetChain: BaseChain) {
        if position == 0 {
            titleLabel.text = "Send to EVM Type Address"
            descriptionLabel.textColor = .color03
            let fullText = "Use this option for ‘0x...’ address"
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.color02, range: (fullText as NSString).range(of: "‘0x...’"))
            descriptionLabel.attributedText = attributedString

            
        } else {
            let prefix = targetChain.bechAddressPrefix()
            titleLabel.text = "Send to COSMOS Type Address"
            descriptionLabel.textColor = .color03
            let fullText = "Use this option for ‘\(prefix)1...’ address or IBC Send"
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.color02, range: (fullText as NSString).range(of: "‘\(prefix)1...’"))
            descriptionLabel.attributedText = attributedString
        }
    }

}
