//
//  CosmosClaimRewards.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CosmosClaimRewards: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorsLabel: UILabel!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var rewardCntLabel: UILabel!
    @IBOutlet weak var rewardCurrencyLabel: UILabel!
    @IBOutlet weak var rewardValueLabel: UILabel!
    
    
    
    @IBOutlet weak var claimBtn: BaseButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
