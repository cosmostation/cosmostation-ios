//
//  SelectSwapChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectSwapChainCell: UITableViewCell {

    @IBOutlet weak var chainLogoImg: UIImageView!
    @IBOutlet weak var chainNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindChain(_ chain: JSON) {
        if let chainLogo = URL(string: chain["logo_uri"].stringValue) {
            chainLogoImg.af.setImage(withURL: chainLogo)
        } else {
            chainLogoImg.image = UIImage(named: "chainDefault")
        }
        chainNameLabel.text = chain["chain_name"].stringValue.uppercased()
    }
    
    
    func onBindCosmosChain(_ chain: CosmosClass) {
        chainLogoImg.image =  UIImage.init(named: chain.logo1)
        chainNameLabel.text = chain.name.uppercased()
    }
    
    
//    SelectSwapOutputChain
}
