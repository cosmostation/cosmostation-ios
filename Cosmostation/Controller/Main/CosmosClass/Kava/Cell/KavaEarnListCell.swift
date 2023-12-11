//
//  KavaEarnListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

class KavaEarnListCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var depositedAmountLabel: UILabel!
    @IBOutlet weak var depositedDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        logoImg.af.cancelImageRequest()
        logoImg.image = UIImage(named: "validatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
    }
    
    func onBindEarnView(_ coin: Cosmos_Base_V1beta1_Coin) {
        
    }
    
}
