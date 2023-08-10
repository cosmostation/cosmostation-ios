//
//  PortfolioCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PortfolioCell: UITableViewCell {

    @IBOutlet weak var rootView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
}
