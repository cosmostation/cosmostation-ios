//
//  GranteeViewCell.swift
//  Cosmostation
//
//  Created by albertopeam on 14/10/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

final class GranteeViewCell: UITableViewCell {
    
    @IBOutlet weak var granteeAddressLabel: UILabel!
    @IBOutlet weak var grantTypeLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ grant: Cosmos_Authz_V1beta1_GrantAuthorization) {
        granteeAddressLabel.text = grant.grantee
        grantTypeLabel.text = grant.authzType
        dataLabel.text = grant.authzData
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        expirationDateLabel.text = formatter.string(from: grant.expiration.date)        
    }
}
