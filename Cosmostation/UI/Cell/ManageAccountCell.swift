//
//  ManageAccountCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class ManageAccountCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    var actionRename: (() -> Void)? = nil
    var actionDelete: (() -> Void)? = nil
    var actionMnemonic: (() -> Void)? = nil
    var actionPrivateKey: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func bindAccount(_ account: BaseAccount) {
        editBtn.showsMenuAsPrimaryAction = true
        let rename = UIAction(title: NSLocalizedString("str_rename", comment: ""), image: nil, handler: { _ in
            self.actionRename?()
        })
        let delete = UIAction(title: NSLocalizedString("str_delete_account", comment: ""), image: nil, handler: { _ in
            self.actionDelete?()
        })
        let mnemonic = UIAction(title: NSLocalizedString("str_check_mnemonic", comment: ""), image: nil, handler: { _ in
            self.actionMnemonic?()
        })
        let privateKey = UIAction(title: NSLocalizedString("str_check_private_key", comment: ""), image: nil, handler: { _ in
            self.actionPrivateKey?()
        })
        
        
        
        nameLabel.text = account.name
        
        if (account.type == .withMnemonic) {
            typeImg.image = UIImage(named: "iconMnemonic")
            editBtn.menu = UIMenu(title: "",
                                  image: nil,
                                  identifier: nil,
                                  options: .displayInline,
                                  children: [rename, delete, mnemonic])
            
        } else {
            typeImg.image = UIImage(named: "iconPrivateKey")
            editBtn.menu = UIMenu(title: "",
                                  image: nil,
                                  identifier: nil,
                                  options: .displayInline,
                                  children: [rename, delete, privateKey])
            
        }
    }
}
