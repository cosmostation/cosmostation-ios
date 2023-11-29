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
    var actionPrivateKeys: (() -> Void)? = nil
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
        nameLabel.text = account.name
        if (account.type == .withMnemonic) {
            typeImg.image = UIImage(named: "iconMnemonic")
        } else {
            typeImg.image = UIImage(named: "iconPrivateKey")
        }
    }
}
