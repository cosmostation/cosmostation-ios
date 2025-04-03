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
    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var mainButton: BaseButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var selectedChain: BaseChain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseAccount = BaseData.instance.baseAccount
        
        if let chain = selectedChain as? ChainBabylon,
           let fetcher = chain.getBabylonBtcFetcher() {
            
            let btcSymbol = chain.isTestnet ? "sBTC" : "BTC"
            
            titleLabel.text = "Staked \(btcSymbol)"
            tokenImageView.image = UIImage(named: chain.isTestnet ? "tokenBtc_signet" : "tokenBtc")
            symbolLabel.text = btcSymbol
            
            descriptionLabel.setLineSpacing(text: String(format: NSLocalizedString("msg_btc_stake", comment: ""), btcSymbol), font: .fontSize12Medium, alignment: .center)
            
            amountLabel.attributedText = WDP.dpAmount(fetcher.btcStakingAmount.multiplying(byPowerOf10: -8, withBehavior: handler6).stringValue, amountLabel.font, 8)
            mainButton.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
        }
    }

    
    @IBAction func onClickStake(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
