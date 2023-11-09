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
    @IBOutlet weak var deprecatedTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var masterAddressLabel: UILabel!
    @IBOutlet weak var slaveAddressabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        deprecatedTag.isHidden = true
        evmCompatTag.isHidden = true
        slaveAddressabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deprecatedTag.isHidden = true
        evmCompatTag.isHidden = true
        slaveAddressabel.isHidden = true
    }
    
    func onBindRefAddress(_ recipientChain: CosmosClass, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        let all = ALLCOSMOSCLASS()
        if let chain = all.filter({ $0.tag == refAddress.chainTag }).first {
            if (chain.evmCompatible) {
                evmCompatTag.isHidden = false
                
            } else if (!chain.isDefault) {
                deprecatedTag.isHidden = false
            }
            
            if (recipientChain is ChainOkt60Keccak) {
                masterAddressLabel.text = refAddress.evmAddress
                slaveAddressabel.text = "(" + refAddress.bechAddress + ")"
                slaveAddressabel.isHidden = false
                
            } else if (chain.evmCompatible) {
                masterAddressLabel.text = refAddress.bechAddress
                slaveAddressabel.text = "(" + refAddress.evmAddress + ")"
                slaveAddressabel.isHidden = false
                
            } else {
                masterAddressLabel.text = refAddress.bechAddress
                slaveAddressabel.isHidden = true
            }
        }
        

    }
    
    func onBindEvmRefAddress(_ recipientChain: CosmosClass, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        
        let all = ALLCOSMOSCLASS()
        if let chain = all.filter({ $0.tag == refAddress.chainTag }).first {
            if (chain.evmCompatible) {
                evmCompatTag.isHidden = false
            } else if (!chain.isDefault) {
                deprecatedTag.isHidden = false
            }
        }
        masterAddressLabel.text = refAddress.evmAddress
        slaveAddressabel.text = "(" + refAddress.bechAddress + ")"
        slaveAddressabel.isHidden = false
        
    }
}
