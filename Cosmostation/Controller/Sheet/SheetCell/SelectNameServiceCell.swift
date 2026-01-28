//
//  SelectNameServiceCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectNameServiceCell: UITableViewCell {
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindNameservice(_ nameservice: NameService) {
        if nameservice.type == "ens" {
            serviceLabel.text = "Ethereum Name Service"
            
        } else if nameservice.type == "starname" {
            serviceLabel.text = "Starname Name Service"
            
        } else if nameservice.type == "osmosis" {
            serviceLabel.text = "Osmosis ICNS"
            
        } else if nameservice.type == "stargaze" {
            serviceLabel.text = "Stargaze Name Service"
            
        } else if nameservice.type == "archway" {
            serviceLabel.text = "Archway ARCH ID"
        }
        addressLabel.text = nameservice.address
        addressLabel.adjustsFontSizeToFitWidth = true
    }
    
}
