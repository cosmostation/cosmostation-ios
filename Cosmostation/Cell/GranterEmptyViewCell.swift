//
//  GranterEmptyViewCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class GranterEmptyViewCell: UITableViewCell {

    @IBOutlet weak var rootCardView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
}
