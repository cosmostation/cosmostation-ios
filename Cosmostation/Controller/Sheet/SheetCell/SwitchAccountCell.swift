//
//  SelectAccountCell.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2023/02/27.
//

import UIKit

class SwitchAccountCell: UITableViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var checkedImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.checkedImg.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.checkedImg.isHidden = true
    }
    
    func onBindAccount(_ account: BaseAccount) {
        nameLabel.text = account.name
        
        if (account.name == BaseData.instance.baseAccount?.name) {
            self.checkedImg.isHidden = false
        } else {
            self.checkedImg.isHidden = true
        }
        
        if (account.type == .withMnemonic) {
            typeImg.image = UIImage(named: "iconMnemonic")
            addressLabel.text = NSLocalizedString("str_account_with_mnemonic", comment: "")
        } else if (account.type == .onlyPrivateKey) {
            typeImg.image = UIImage(named: "iconPrivateKey")
            addressLabel.text = NSLocalizedString("str_account_with_privateKey", comment: "")
        }
    }
    
}
