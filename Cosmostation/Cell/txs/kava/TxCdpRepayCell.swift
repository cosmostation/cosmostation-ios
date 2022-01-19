//
//  TxRepayCdpCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/12.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxCdpRepayCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var coinTypeLabel: UILabel!
    @IBOutlet weak var paymentAmount: UILabel!
    @IBOutlet weak var paymentDenom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        paymentAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Cdp_V1beta1_MsgRepayDebt.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.sender
            coinTypeLabel.text = msg.collateralType
            
            let paymentCoin = Coin.init(msg.payment.denom, msg.payment.amount)
            WUtils.showCoinDp(paymentCoin, paymentDenom, paymentAmount, chain)
        }
    }
    
}
