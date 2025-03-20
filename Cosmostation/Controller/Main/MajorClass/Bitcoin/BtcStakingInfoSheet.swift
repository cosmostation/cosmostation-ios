//
//  BtcStakingInfoSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 3/6/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class BtcStakingInfoSheet: BaseVC {

    @IBOutlet weak var timeLockDescriptionLabel: UILabel!
    @IBOutlet weak var unstakingDescriptionLabel: UILabel!
    
    var chain: ChainBitCoin86!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let babylonBtcFetcher = chain.getBabylonBtcFetcher() else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        configureTimeLockDescription(babylonBtcFetcher, paragraphStyle)
        configureUnstakingPeriodDescription(babylonBtcFetcher, paragraphStyle)
    }
    
    @IBAction func onBindConfirm(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func configureTimeLockDescription(_ fetcher: BabylonBTCFetcher, _ style: NSMutableParagraphStyle) {
        let symbol = chain.coinSymbol
        
        let timeLockWeeks = fetcher.btcStakingTimeLockWeeks
        let weeksString = String(format: NSLocalizedString("btc_timelock_weeks", comment: ""), timeLockWeeks)
        let timeLockFullText = String(format: NSLocalizedString("msg_btc_stake_timelock", comment: ""), symbol, weeksString)
        let weeksRange = (timeLockFullText as NSString).range(of: weeksString)
        let timeLockAttributedString = NSMutableAttributedString(string: timeLockFullText)
        timeLockAttributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: timeLockFullText.count))
        timeLockAttributedString.addAttribute(.foregroundColor, value: UIColor.color02, range: weeksRange)
        timeLockDescriptionLabel.attributedText = timeLockAttributedString
    }
    
    private func configureUnstakingPeriodDescription(_ fetcher: BabylonBTCFetcher, _ style: NSMutableParagraphStyle) {
        let unstakingPeriodDays = fetcher.btcUnbondingTimeDays
        let daysString = String(format: NSLocalizedString("btc_unstake_period_days", comment: ""), unstakingPeriodDays)
        let unstakingFullText = String(format: NSLocalizedString("msg_btc_unstake_period", comment: ""), daysString)
        let daysRange = (unstakingFullText as NSString).range(of: daysString)
        let unstakingAttributtedString = NSMutableAttributedString(string: unstakingFullText)
        unstakingAttributtedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: unstakingFullText.count))
        unstakingAttributtedString.addAttribute(.foregroundColor, value: UIColor.color02, range: daysRange)
        unstakingDescriptionLabel.attributedText = unstakingAttributtedString
    }
}
