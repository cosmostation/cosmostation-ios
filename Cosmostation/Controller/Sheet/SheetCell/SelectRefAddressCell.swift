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
    @IBOutlet weak var deprecatedLabel: UILabel!
    @IBOutlet weak var evmLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var evmAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        deprecatedLabel.isHidden = true
        evmLabel.isHidden = true
        memoLabel.isHidden = true
        evmAddressLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deprecatedLabel.isHidden = true
        evmLabel.isHidden = true
        memoLabel.isHidden = true
        evmAddressLabel.isHidden = true
    }
    
    func onBindRefAddress(_ refAddress: RefAddress) {
        addressLabel.text = refAddress.dpAddress
        let all = ALLCOSMOSCLASS()
        
        if let chain = all.filter({ $0.tag == refAddress.chainTag }).first {
            if (chain.evmCompatible) {
                evmLabel.isHidden = false
                evmAddressLabel.text = "(" + KeyFac.convertBech32ToEvm(refAddress.dpAddress) + ")"
                evmAddressLabel.isHidden = false
                
            } else if (!chain.isDefault) {
                deprecatedLabel.isHidden = false
            }
        }
        
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
    }
    
}
