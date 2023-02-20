//
//  TxIbcSendCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/06/23.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxIbcSendCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var ibcSendTitle: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var senderTitle: UILabel!
    @IBOutlet weak var receipientLabel: UILabel!
    @IBOutlet weak var receipientTitle: UILabel!
    @IBOutlet weak var sendAmount: UILabel!
    @IBOutlet weak var sendAmountTitle: UILabel!
    @IBOutlet weak var sendDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        ibcSendTitle.text = NSLocalizedString("tx_ibc_send", comment: "")
        senderTitle.text = NSLocalizedString("str_ibc_sender", comment: "")
        receipientTitle.text = NSLocalizedString("str_ibc_recipient", comment: "")
        sendAmountTitle.text = NSLocalizedString("str_ibc_send_amount", comment: "")
        sendAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Ibc_Applications_Transfer_V1_MsgTransfer.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.sender
            receipientLabel.text = msg.receiver
            
            let sendCoin = Coin.init(msg.token.denom, msg.token.amount)
            WDP.dpCoin(chainConfig, sendCoin, sendDenom, sendAmount)
        }
    }
    
}
