//
//  SelectAccountCell.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2023/02/27.
//

import UIKit

class SwitchAccountCell: UITableViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var checkedImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.checkedImg.isHidden = true
    }
    
    func onBindAccount(_ account: BaseAccount) {
        nameLabel.text = account.name
        
        if (account.name == BaseData.instance.baseAccount.name) {
            self.checkedImg.isHidden = false
        } else {
            self.checkedImg.isHidden = true
        }
        
        if (account.type == .withMnemonic) {
            
        } else if (account.type == .onlyPrivateKey) {
            
        }
//
//        Task {
//            if let baseAccount = await baseAccount.getBaseAddress(currentChain!) {
//                addressLabel.text = baseAccount.address
//                if (baseAccount.account_id == currentAddress.id) {
//                    self.rootView.backgroundColor = .base02
//                    self.checkedImg.isHidden = false
//                } else {
//                    self.rootView.backgroundColor = .base01
//                    self.checkedImg.isHidden = true
//                }
//            }
//        }
    }
    
}
