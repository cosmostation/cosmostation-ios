//
//  SelectPriceColorCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SelectPriceColorCell: UITableViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var upLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var upColorImg: UIImageView!
    @IBOutlet weak var downColorImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
}
