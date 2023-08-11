//
//  GranteeViewCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class GranteeViewCell: UITableViewCell {

    @IBOutlet weak var granteeAddressLabel: UILabel!
    @IBOutlet weak var granteeTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ grant: Cosmos_Authz_V1beta1_GrantAuthorization) {
        granteeAddressLabel.text = grant.grantee
        granteeTypeLabel.text = WUtils.setAuthzType(grant)
        expirationLabel.text = WDP.dpTimeGap(grant.expiration.seconds * 1000)
    }
}
