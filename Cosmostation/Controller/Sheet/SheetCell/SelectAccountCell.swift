//
//  SelectAccountCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/29/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectAccountCell: UITableViewCell {
    
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagLayer: UIStackView!
    @IBOutlet weak var deprecatedLabel: UILabel!
    @IBOutlet weak var evmLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func onBindChains(_ chain: CosmosClass) {
        let baseAccount = BaseData.instance.baseAccount
        addressLabel.text = chain.address
        addressLabel.adjustsFontSizeToFitWidth = true
        
        if (baseAccount?.type == .withMnemonic) {
            typeImg.image = UIImage(named: "iconMnemonic")
        } else if (baseAccount?.type == .onlyPrivateKey) {
            typeImg.image = UIImage(named: "iconPrivateKey")
        }
        
        if (chain.evmCompatible) {
            tagLayer.isHidden = false
            evmLabel.isHidden = false
            
        } else if (!chain.isDefault) {
            tagLayer.isHidden = false
            deprecatedLabel.isHidden = false
        }
    }
}
