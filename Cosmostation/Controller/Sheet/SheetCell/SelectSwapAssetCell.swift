//
//  SelectSwapAssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class SelectSwapAssetCell: UITableViewCell {
    
    @IBOutlet weak var coinImg: CircleImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var ibcTag: RoundedPaddingLabel!
    @IBOutlet weak var erc20Tag: RoundedPaddingLabel!
    @IBOutlet weak var cw20Tag: RoundedPaddingLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        ibcTag.isHidden = true
        erc20Tag.isHidden = true
        cw20Tag.isHidden = true
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
    }
    
    func onBindAsset(_ chain: BaseChain, _ asset: TargetAsset) {
        symbolLabel.text = asset.symbol
        coinImg?.sd_setImage(with: asset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        descriptionLabel.text = asset.name
        descriptionLabel.lineBreakMode = .byTruncatingMiddle
        
        if (asset.type == .ERC20) {
            erc20Tag.isHidden = false
            
        } else if (asset.type == .CW20) {
            cw20Tag.isHidden = false
            
        } else if (asset.type == .IBC) {
            ibcTag.isHidden = false
            
        }
        
        if (asset.balance != NSDecimalNumber.zero) {
            let dpInputBalance = asset.balance.multiplying(byPowerOf10: -asset.decimals!)
            self.amountLabel?.attributedText = WDP.dpAmount(dpInputBalance.stringValue, self.amountLabel!.font, asset.decimals)
            self.amountLabel.isHidden = false
            
            WDP.dpValue(asset.value, self.valueCurrencyLabel, self.valueLabel)
            self.valueCurrencyLabel.isHidden = false
            self.valueLabel.isHidden = false
        }
    }
}
