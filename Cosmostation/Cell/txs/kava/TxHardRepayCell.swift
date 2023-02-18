//
//  TxHardRepayCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxHardRepayCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var hardRepayTitle: UILabel!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var senderTitle: UILabel!
    @IBOutlet weak var owener: UILabel!
    @IBOutlet weak var owenerTitle: UILabel!
    @IBOutlet weak var repayAmount: UILabel!
    @IBOutlet weak var repayAmountTitle: UILabel!
    @IBOutlet weak var repayDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        hardRepayTitle.text = NSLocalizedString("tx_kava_hard_repay2", comment: "")
        senderTitle.text = NSLocalizedString("str_sender", comment: "")
        owenerTitle.text = NSLocalizedString("str_owner", comment: "")
        repayAmountTitle.text = NSLocalizedString("str_repay_amount", comment: "")
        repayAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Hard_V1beta1_MsgRepay.init(serializedData: response.tx.body.messages[position].value) {
            sender.text = msg.sender
            owener.text = msg.owner
            
            let coin = Coin.init(msg.amount[0].denom, msg.amount[0].amount)
            WDP.dpCoin(chainConfig, coin, repayDenom, repayAmount)
        }
    }
    
}
