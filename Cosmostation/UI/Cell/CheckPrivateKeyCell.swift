//
//  CheckPrivateKeyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CheckPrivateKeyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var keyTypeTag: PaddingLabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var pkeyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    func bindPrivateKey(_ account: BaseAccount, _ chain: BaseChain) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        pkeyLabel.text = "0x" + chain.privateKey!.toHexString()
        
        legacyTag.isHidden = chain.isDefault
    }
}
