//
//  SelectNameServiceCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectNameServiceCell: UITableViewCell {
    
    @IBOutlet weak var chainLogoImg: UIImageView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindNameservice(_ nameservice: NameService) {
        if (nameservice.type == "starname") {
            chainLogoImg.image = UIImage(named: "chainStarname")
            serviceLabel.text = "Starname Name Service"
            
        } else if (nameservice.type == "osmosis") {
            chainLogoImg.image = UIImage(named: "chainOsmosis")
            serviceLabel.text = "Osmosis ICNS"
            
        } else if (nameservice.type == "stargaze") {
            chainLogoImg.image = UIImage(named: "chainStargaze")
            serviceLabel.text = "Stargaze Name Service"
            
        } else if (nameservice.type == "archway") {
            chainLogoImg.image = UIImage(named: "chainAkash")
            serviceLabel.text = "Archway ARCH ID"
        }
        addressLabel.text = nameservice.address
        addressLabel.adjustsFontSizeToFitWidth = true
    }
    
}
