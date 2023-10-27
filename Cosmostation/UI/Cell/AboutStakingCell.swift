//
//  AboutStakingCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class AboutStakingCell: UITableViewCell {
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var unbondingTimeTitle: UILabel!
    @IBOutlet weak var unbondingTimeLabel: UILabel!
    @IBOutlet weak var inflationTitle: UILabel!
    @IBOutlet weak var inflationLabel: UILabel!
    @IBOutlet weak var stakingAprTitle: UILabel!
    @IBOutlet weak var stakingAprLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindStakingInfo(_ chain: CosmosClass, _ json: JSON) {
        
        let unbondingSec = json["params"]["staking_params"]["params"]["unbonding_time"].stringValue.filter({ $0.isNumber })
        let time = UInt64(unbondingSec) ?? 1814400
        let unbondingDay = UInt16(time / 24 / 60 / 60)
        unbondingTimeLabel.text = String(unbondingDay) + " Days"
        
        
        let nf = WUtils.getNumberFormatter(2)
        if let inflation = json["params"]["minting_inflation"]["inflation"].string {
            print("inflation ", inflation)
            let formatInflation = nf.string(from: NSDecimalNumber(string: inflation).multiplying(byPowerOf10: 2))!
            print("formatInflation ", formatInflation)
            inflationLabel.attributedText = WUtils.getDpAttributedString(formatInflation, 2, inflationLabel.font)
        }
        
        if let apr = json["params"]["apr"].string {
            let formatApr = nf.string(from: NSDecimalNumber(string: apr).multiplying(byPowerOf10: 2))!
            stakingAprLabel.attributedText = WUtils.getDpAttributedString(formatApr, 2, stakingAprLabel.font)
        }
    }
    
}
