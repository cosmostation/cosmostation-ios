//
//  KavaDefiCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class KavaDefiCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var defiImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
        
    func onBindKava(_ position: Int) {
        if (position == 1) {
            defiImg.image = UIImage(named: "imgKavaMint")
            titleLabel.text = "MINT"
            msgLabel.text = NSLocalizedString("msg_kava_mint_msg", comment: "")
            
        } else if (position == 2) {
            defiImg.image = UIImage(named: "imgKavaLend")
            titleLabel.text = "LEND"
            msgLabel.text = NSLocalizedString("msg_kava_lend_msg", comment: "")
            
        } else if (position == 3) {
            defiImg.image = UIImage(named: "imgKavaSwap")
            titleLabel.text = "SWAP POOL"
            msgLabel.text = NSLocalizedString("msg_kava_swap_msg", comment: "")
            
        } else if (position == 4) {
            defiImg.image = UIImage(named: "imgKavaEarn")
            titleLabel.text = "EARN"
            msgLabel.text = NSLocalizedString("msg_kava_earn_msg", comment: "")
        }
    }
    
}
