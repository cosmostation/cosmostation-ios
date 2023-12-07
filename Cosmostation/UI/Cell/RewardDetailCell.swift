//
//  RewardDetailCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

class RewardDetailCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
    }
    
    override func prepareForReuse() {
        coinImg.af.cancelImageRequest()
        coinImg.image = UIImage(named: "tokenDefault")
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
    }
    
}
