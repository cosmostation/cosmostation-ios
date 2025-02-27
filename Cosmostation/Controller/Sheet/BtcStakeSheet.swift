//
//  BtcStakeSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 2/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import SkeletonView

class BtcStakeSheet: BaseVC {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stakeButton: BaseButton!
    @IBOutlet weak var stakedAmountLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var selectedChain: BaseChain?
    var btcStakeDelegate: BtcStakeSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseAccount = BaseData.instance.baseAccount
        
        titleLabel.text = selectedChain!.isTestnet ? "Staked sBTC" : "Staked BTC"
        symbolLabel.text = selectedChain!.isTestnet ? "sBTC" : "BTC"
        descriptionLabel.text = selectedChain!.isTestnet ? "Stake sBTC and earn tBABY as a reward.\nRealize your profits through staking." : "Stake BTC and earn BABY as a reward.\nRealize your profits through staking."
//TODO: localization
        
        if let fetcher = (selectedChain as? ChainBabylon)?.getBabylonBtcFetcher() {
            stakedAmountLabel.attributedText = WDP.dpAmount(NSDecimalNumber(integerLiteral: fetcher.btcDelegations.map({ $0.amount }).reduce(0, +)).multiplying(byPowerOf10: -8, withBehavior: handler6).stringValue, stakedAmountLabel.font, 8)
        }
    }
    
    @IBAction func onClickStake(_ sender: Any) {
        btcStakeDelegate?.onBindBtcStakingInfoVC()
    }
    
}
