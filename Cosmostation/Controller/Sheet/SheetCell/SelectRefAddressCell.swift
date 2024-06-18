//
//  SelectRefAddressCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectRefAddressCell: UITableViewCell {
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var keyTypeTag: PaddingLabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    func onBindBechRefAddress(_ toChain: BaseChain, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        
        let allChain = ALLCHAINS()
        if let chain = allChain.filter({ $0.tag == refAddress.chainTag }).first {
            legacyTag.isHidden = chain.isDefault
            if (chain.name == "OKT" && !chain.supportEvm) {
                keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
                keyTypeTag.isHidden = false
            }
        }
        
        addressLabel.text = refAddress.bechAddress
        addressLabel.adjustsFontSizeToFitWidth = true
    }
    
    func onBindEvmRefAddress(_ toChain: BaseChain, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        addressLabel.text = refAddress.evmAddress
        addressLabel.adjustsFontSizeToFitWidth = true
    }
}
