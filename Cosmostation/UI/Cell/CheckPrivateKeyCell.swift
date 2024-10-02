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
    @IBOutlet weak var oldTag: RoundedPaddingLabel!
    @IBOutlet weak var keyTypeTag: RoundedPaddingLabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var pkeyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        oldTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        oldTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    func bindPrivateKey(_ account: BaseAccount, _ chain: BaseChain) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        pkeyLabel.text = "0x" + chain.privateKey!.toHexString()
        
        if chain is ChainBitCoin84 {
            if chain.accountKeyType.pubkeyType == .BTC_Legacy {
                keyTypeTag.text = "Legacy"
                keyTypeTag.backgroundColor = .color07
                keyTypeTag.textColor = .color02

            } else if chain.accountKeyType.pubkeyType == .BTC_Nested_Segwit {
                keyTypeTag.text = "Nested Segwit"
                keyTypeTag.backgroundColor = .color07
                keyTypeTag.textColor = .color02

            } else if chain.accountKeyType.pubkeyType == .BTC_Native_Segwit {
                keyTypeTag.text = "Native Segwit"
                keyTypeTag.backgroundColor = .colorNativeSegwit
                keyTypeTag.textColor = .color01
            }
            keyTypeTag.isHidden = false
            
        } else {
            oldTag.isHidden = chain.isDefault
        }
    }
}
