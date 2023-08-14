//
//  GranteeViewCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class GranteeViewCell: UITableViewCell {

    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var granteeAddressLabel: UILabel!
    @IBOutlet weak var granteeTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ grant: (Bool, Cosmos_Authz_V1beta1_GrantAuthorization)) {
        if (grant.0 == true) {
            rootCardView.borderWidth = 1
            rootCardView.borderColor = UIColor.font05
            rootCardView.layer.borderWidth = 1
        } else {
            rootCardView.borderWidth = 0
            rootCardView.layer.borderWidth = 0
        }
        granteeAddressLabel.text = grant.1.grantee
        granteeTypeLabel.text = WUtils.setAuthzType(grant.1)
        expirationLabel.text = WDP.dpTimeGap(grant.1.expiration.seconds * 1000)
    }
}
