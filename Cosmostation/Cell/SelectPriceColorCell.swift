//
//  SelectPriceColorCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SelectPriceColorCell: UITableViewCell {
    @IBOutlet weak var bullLabel: UILabel!
    @IBOutlet weak var bearLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.bullLabel.text = NSLocalizedString("str_bull", comment: "")
        self.bearLabel.text = NSLocalizedString("str_bear", comment: "")
    }
    
}
