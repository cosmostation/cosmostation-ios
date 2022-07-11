//
//  NewHistoryCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/06/23.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class NewHistoryCell: UITableViewCell {
    
    @IBOutlet weak var txTypeLabel: UILabel!
    @IBOutlet weak var txResultLabel: UILabel!
    @IBOutlet weak var txTimeLabel: UILabel!
    @IBOutlet weak var txTimeGapLabel: UILabel!
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var txDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        txTimeLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txTimeGapLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_11_caption2)
        txAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func prepareForReuse() {
        txDenomLabel.isHidden = false
        txAmountLabel.isHidden = false
    }
    
    func bindHistoryView(_ chainConfig: ChainConfig, _ history: ApiHistoryNewCustom, _ address: String) {
        txTypeLabel.text = history.getMsgType(address)
        txResultLabel.isHidden = history.isSuccess()
        txTimeLabel.text = WDP.dpTime(history.header?.timestamp)
        txTimeGapLabel.text = WDP.dpTimeGap(history.header?.timestamp)
        
        if (NSLocalizedString("tx_vote", comment: "") == history.getMsgType(address)) {
            txDenomLabel.textColor = .white
            txDenomLabel.text = history.getVoteOption()
            txAmountLabel.isHidden = true
            return
        }
        
        guard let dpCoin = history.getDpCoin(chainConfig) else {
            txDenomLabel.isHidden = true
            txAmountLabel.isHidden = true
            return
        }
        txDenomLabel.isHidden = false
        txAmountLabel.isHidden = false
        WDP.dpCoin(chainConfig, dpCoin, txDenomLabel, txAmountLabel)
    }
    
}
