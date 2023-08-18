//
//  PortfolioCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PortfolioCell: UITableViewCell {

    @IBOutlet weak var rootView: CardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var logoImg2: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var priceImg: UIImageView!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
        
        pathLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func bindCosmosClassChain(_ chain: BaseChain) {
        nameLabel.text = chain.name
        
        print("chain ", chain.cosmosBalances)
        
    }
    
}
