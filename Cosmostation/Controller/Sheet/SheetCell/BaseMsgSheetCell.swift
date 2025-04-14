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
    
    func onBindBtcWithdraw() {
        titleLabel.text = NSLocalizedString("str_withdraw", comment: "")
        descriptionLabel.text = NSLocalizedString("str_withdraw_msg", comment: "")
    }
    

}
