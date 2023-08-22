//
//  PortfolioCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PortfolioCell: UITableViewCell {

    @IBOutlet weak var rootView: CardViewCell!
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
    
    func bindCosmosClassChain(_ chain: CosmosClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom) {
            let priceChanged = BaseData.instance.priceChange(msAsset.coinGeckoId)
//            WDP.dpPriceChangeImg(priceImg, priceChanged)
//            WDP.dpPriceChanged(priceChangeLabel, priceChanged)
            WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
        }
    }
    
}
