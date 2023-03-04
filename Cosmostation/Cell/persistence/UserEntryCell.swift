//
//  UserEntryCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class UserEntryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func bindView(_ chainConfig: ChainConfig?, _ entry: Pstake_Lscosmos_V1beta1_DelegatorUnbondingEpochEntry?, _ currentEpochNumber: Int64) {
        if (chainConfig == nil || entry == nil || currentEpochNumber == 0) { return }
        
        addressLabel.text = entry?.delegatorAddress
        
        let gap = entry!.epochNumber - currentEpochNumber
        if (gap <= 0) {
            dateLabel.text = "Today"
        } else {
            dateLabel.text = String(gap) + " Days Ago"
        }
        
        WDP.dpCoin(chainConfig, entry!.amount.denom, String(entry!.amount.amount), denomLabel, amountLabel)
    }
}
