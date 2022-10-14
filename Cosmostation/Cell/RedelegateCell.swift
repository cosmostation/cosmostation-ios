//
//  RedelegateCell.swift
//  Cosmostation
//
//  Created by yongjoo on 24/05/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class RedelegateCell: UITableViewCell {

    @IBOutlet weak var rootCard: CardView!
    @IBOutlet weak var valImg: UIImageView!
    @IBOutlet weak var valjailedImg: UIImageView!
    @IBOutlet weak var valCheckedImg: UIImageView!
    @IBOutlet weak var valMonikerLabel: UILabel!
    @IBOutlet weak var valPowerLabel: UILabel!
    @IBOutlet weak var valCommissionLabel: UILabel!
    
    @IBOutlet weak var votingPowerTitleLabel: UILabel!
    @IBOutlet weak var estAprTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        valImg.layer.borderWidth = 1
        valImg.layer.masksToBounds = false
        valImg.layer.borderColor = UIColor(named: "_font04")!.cgColor
        valImg.layer.cornerRadius = valImg.frame.height/2
        valImg.clipsToBounds = true
        
        self.selectionStyle = .none
        votingPowerTitleLabel.text = NSLocalizedString("str_voting_power", comment: "")
        estAprTitleLabel.text = NSLocalizedString("str_est_apr", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.valImg.image = UIImage(named: "validatorDefault")
    }
    
}
