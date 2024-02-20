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
    @IBOutlet weak var masterAddressLabel: UILabel!
    @IBOutlet weak var slaveAddressabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        slaveAddressabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        legacyTag.isHidden = true
        evmCompatTag.isHidden = true
        slaveAddressabel.isHidden = true
    }
    
    func onBindBechRefAddress(_ toChain: BaseChain, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        let allCosmos = ALLCOSMOSCLASS()
        if let chain = allCosmos.filter({ $0.tag == refAddress.chainTag }).first {
            legacyTag.isHidden = chain.isDefault
        }
        let allEvm = ALLEVMCLASS()
//        if let chain = allEvm.filter({ $0.tag == refAddress.chainTag }).first {
//            evmCompatTag.isHidden = false
//        }
//        print("refAddress ", refAddress)
        evmCompatTag.isHidden = allEvm.filter({ $0.tag == refAddress.chainTag }).count <= 0
        masterAddressLabel.text = refAddress.bechAddress
    }
    
    func onBindEvmRefAddress(_ toChain: BaseChain, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        masterAddressLabel.text = refAddress.evmAddress
    }
    
    
    func onBindCosmosRefAddress(_ recipientChain: CosmosClass, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        let all = ALLCOSMOSCLASS()
        if let chain = all.filter({ $0.tag == refAddress.chainTag }).first {
//            if (chain.evmCompatible) {
//                evmCompatTag.isHidden = false
//                
//            } else 
            
            if (!chain.isDefault) {
                legacyTag.isHidden = false
            }
            
            if (recipientChain is ChainOkt60Keccak) {
                masterAddressLabel.text = refAddress.evmAddress
                slaveAddressabel.text = "(" + refAddress.bechAddress + ")"
                slaveAddressabel.isHidden = false
                
            } 
            
//            else if (chain.evmCompatible) {
//                masterAddressLabel.text = refAddress.bechAddress
//                slaveAddressabel.text = "(" + refAddress.evmAddress + ")"
//                slaveAddressabel.isHidden = false
//                
//            } 
            
            else {
                masterAddressLabel.text = refAddress.bechAddress
                slaveAddressabel.isHidden = true
            }
        }
        

    }
    
    func onBindCosmosEvmRefAddress(_ recipientChain: CosmosClass, _ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        
        let all = ALLCOSMOSCLASS()
        if let chain = all.filter({ $0.tag == refAddress.chainTag }).first {
//            if (chain.evmCompatible) {
//                evmCompatTag.isHidden = false
//            } else 
            if (!chain.isDefault) {
                legacyTag.isHidden = false
            }
        }
        masterAddressLabel.text = refAddress.evmAddress
        slaveAddressabel.text = "(" + refAddress.bechAddress + ")"
        slaveAddressabel.isHidden = false
        
    }
    
    func onBindEvmRefAddress(_ refAddress: RefAddress) {
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
        masterAddressLabel.text = refAddress.evmAddress
        masterAddressLabel.adjustsFontSizeToFitWidth = true
    }
}
