//
//  SelectAccountCell.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2023/02/27.
//

import UIKit

class SelectAccountCell: UITableViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var checkedImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.checkedImg.isHidden = true
//        self.rootView.backgroundColor = .base01
//        self.addressLabel.text = ""
//    }
//    
//    func onBindAccount(_ currentAddress: BaseAccount, _ currentChain: ChainConfig?, _ baseAccount: BaseAccount) {
//        nameLabel.text = baseAccount.name
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
//    }
    
}
