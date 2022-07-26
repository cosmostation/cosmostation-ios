//
//  AuthzGranteeCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/26.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzGranteeCell: UITableViewCell {

    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var granteeAddressLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
}
