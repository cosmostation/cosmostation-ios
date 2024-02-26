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
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    func onBindBechRefAddress(_ toChain: BaseChain, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        
        let allCosmos = ALLCOSMOSCLASS()
        if let chain = allCosmos.filter({ $0.tag == refAddress.chainTag }).first {
            legacyTag.isHidden = chain.isDefault
            //for okt legacy
            if (chain.tag == "okt996_Keccak") {
                keyTypeTag.text = "ethsecp256k1"
                keyTypeTag.isHidden = false
                
            } else if (chain.tag == "okt996_Secp") {
                keyTypeTag.text = "secp256k1"
                keyTypeTag.isHidden = false
            }
        }
        let allEvm = ALLEVMCLASS()
        if (allEvm.filter({ $0.tag == refAddress.chainTag }).count != 0) {
            evmCompatTag.isHidden = false
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
