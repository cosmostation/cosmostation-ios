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
    
    func onBindCosmosChain(_ chain: BaseChain) {
        chainLogoImg.sd_setImage(with: chain.getChainImage(), placeholderImage: UIImage(named: "chainDefault"))
        chainNameLabel.text = chain.name
    }
}
