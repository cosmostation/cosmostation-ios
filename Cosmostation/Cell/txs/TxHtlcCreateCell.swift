//
//  TxHtlcCreateCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/04/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxHtlcCreateCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txTitle: UILabel!
    @IBOutlet weak var sendAmount: UILabel!
    @IBOutlet weak var sendDenom: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var randomHashLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        sendAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Bep3_V1beta1_MsgCreateAtomicSwap.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.from
            recipientLabel.text = msg.recipientOtherChain
            randomHashLabel.text = msg.randomNumberHash
            
            let coin = Coin.init(msg.amount[0].denom, msg.amount[0].amount)
            WUtils.showCoinDp(coin, sendDenom, sendAmount, chain)
        }
    }
    
}
