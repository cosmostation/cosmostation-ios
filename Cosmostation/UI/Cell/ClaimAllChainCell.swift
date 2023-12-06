//
//  ClaimAllChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/06.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class ClaimAllChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var assetCntLabel: UILabel!
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var pendingView: LottieAnimationView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}
