//
//  AuthzRevokeCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AuthzRevokeCell: UITableViewCell {

    @IBOutlet weak var granteeTitleLabel: UILabel!
    @IBOutlet weak var granteeAddressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var granteeTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ grant: Cosmos_Authz_V1beta1_GrantAuthorization) {
        granteeTitleLabel.text = NSLocalizedString("str_grantee", comment: "")
        typeLabel.text = NSLocalizedString("str_grant_type", comment: "")
        
        granteeAddressLabel.text = grant.grantee
        granteeTypeLabel.text = WUtils.setAuthzType(grant)
    }
}
