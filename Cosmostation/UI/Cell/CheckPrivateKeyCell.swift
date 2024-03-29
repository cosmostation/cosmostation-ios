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
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var pkeyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        evmCompatTag.isHidden = true
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
        if (chain.tag == "okt996_Keccak") {
            keyTypeTag.text = "ethsecp256k1"
            keyTypeTag.isHidden = false
            
        } else if (chain.tag == "okt996_Secp") {
            keyTypeTag.text = "secp256k1"
            keyTypeTag.isHidden = false
        }
    }
}
