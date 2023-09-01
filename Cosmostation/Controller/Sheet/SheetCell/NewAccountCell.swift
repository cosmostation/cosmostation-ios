//
//  NewAccountCell.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2023/04/10.
//

import UIKit

class NewAccountCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ position: Int) {
        if (position == 0) {
            titleLabel.text = NSLocalizedString("create_wallet", comment: "")
            descriptionLabel.text = NSLocalizedString("create_wallet_msg", comment: "")
            
        } else if (position == 1) {
            titleLabel.text = NSLocalizedString("import_mnemonic", comment: "")
            descriptionLabel.text = NSLocalizedString("import_mnemonic_msg", comment: "")
            
        } else if (position == 2) {
            titleLabel.text = NSLocalizedString("import_private_key", comment: "")
            descriptionLabel.text = NSLocalizedString("import_private_key_msg", comment: "")
            
        } else {
            titleLabel.text = ""
        }
    }
    
}
