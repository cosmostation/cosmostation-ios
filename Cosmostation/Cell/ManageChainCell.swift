//
//  ManageChainCell.swift
//  Cosmostation
//
//  Created by yongjoo on 18/10/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class ManageChainCell: UITableViewCell {

    @IBOutlet weak var chainCard: CardView!
    @IBOutlet weak var chainImg: UIImageView!
    @IBOutlet weak var chainName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onSetView(_ selected: Bool) {
        if (selected) {
            chainCard.borderColor = UIColor.font05
            chainName.textColor = UIColor.font05
            chainImg.alpha = 1.0
        } else {
            chainCard.borderColor = UIColor.init(hexString: "#000000", alpha: 0.0)
            chainName.textColor = UIColor.font04
            chainImg.alpha = 0.1
        }
    }
    
}
