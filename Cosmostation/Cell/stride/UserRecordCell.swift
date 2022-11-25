//
//  UserRecordCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class UserRecordCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeGapLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func bindView(_ chainConfig: ChainConfig?, _ zone: Stride_Stakeibc_HostZone?, _ record: Stride_Records_UserRedemptionRecord?, _ dayEpoch: Stride_Stakeibc_EpochTracker?) {
        if (chainConfig == nil || zone == nil || record == nil || dayEpoch == nil) { return }
        
        addressLabel.text = record?.receiver
        
        let gap = dayEpoch!.epochNumber - record!.epochNumber
        if (gap <= 0) {
            timeGapLabel.text = "Today"
        } else {
            timeGapLabel.text = String(gap) + " Days Ago"
        }
        let dpCoin = Coin.init(zone!.ibcDenom, String(record!.amount))
        WDP.dpCoin(chainConfig, dpCoin, denomLabel, amountLabel)
        
    }
    
}
