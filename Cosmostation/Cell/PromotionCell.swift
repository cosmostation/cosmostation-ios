//
//  PromotionCell.swift
//  Cosmostation
//
//  Created by yongjoo on 23/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class PromotionCell: UITableViewCell {

    @IBOutlet weak var promotionTitleLabel: UILabel!
    @IBOutlet weak var promotionMsgLabel: UILabel!
    @IBOutlet weak var cardView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        promotionTitleLabel.text = NSLocalizedString("title_promotion", comment: "")
        promotionMsgLabel.text = NSLocalizedString("msg_promotion", comment: "")
    }
    
}
