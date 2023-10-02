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
    @IBOutlet weak var tag0Label: UILabel!
    @IBOutlet weak var tag1Label: UILabel!
    @IBOutlet weak var tag2Label: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        tag0Label.isHidden = true
        tag1Label.isHidden = true
        tag2Label.isHidden = true
        memoLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tag0Label.isHidden = true
        tag1Label.isHidden = true
        tag2Label.isHidden = true
        memoLabel.isHidden = true
    }
    
    func onBindRefAddress(_ refAddress: RefAddress) {
        addressLabel.text = refAddress.dpAddress
        if let account = BaseData.instance.selectAccount(refAddress.accountId) {
            accountNameLabel.text = account.name
        }
    }
    
}
