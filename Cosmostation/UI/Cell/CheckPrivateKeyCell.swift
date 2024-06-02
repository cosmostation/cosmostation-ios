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
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    func bindEvmClassPrivateKey(_ account: BaseAccount, _ chain: EvmClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        pkeyLabel.text = "0x" + chain.privateKey!.toHexString()
    }
    
    
    func bindCosmosClassPrivateKey(_ account: BaseAccount, _ chain: CosmosClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        pkeyLabel.text = "0x" + chain.privateKey!.toHexString()
        
        legacyTag.isHidden = chain.isDefault
        if (chain is ChainOkt996Keccak) {
            keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
            keyTypeTag.isHidden = false
        }
    }
}
