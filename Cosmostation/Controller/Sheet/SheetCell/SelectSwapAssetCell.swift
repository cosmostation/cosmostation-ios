//
//  SelectSwapAssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectSwapAssetCell: UITableViewCell {
    
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    
    func onBindAsset(_ asset: JSON) {
        if let assetLogo = URL(string: asset["logo_uri"].stringValue) {
            coinImg.af.setImage(withURL: assetLogo)
        } else {
            coinImg.image = UIImage(named: "tokenDefault")
        }
        symbolLabel.text = asset["symbol"].stringValue
    }
}
