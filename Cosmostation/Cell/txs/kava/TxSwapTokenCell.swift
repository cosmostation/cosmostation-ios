//
//  TxSwapTokenCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/30.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxSwapTokenCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txTypeLabel: UILabel!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txPoolInAmountLabel: UILabel!
    @IBOutlet weak var txPoolInDenomLabel: UILabel!
    @IBOutlet weak var txPoolOutAmountLabel: UILabel!
    @IBOutlet weak var txPoolOutDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Kava_Swap_V1beta1_MsgSwapExactForTokens.init(serializedData: response.tx.body.messages[position].value) {
            txTypeLabel.text = "SwapExactForTokens"
            txSenderLabel.text = msg.requester

            let coin0 = Coin.init(msg.exactTokenA.denom, msg.exactTokenA.amount)
            let coin1 = Coin.init(msg.tokenB.denom, msg.tokenB.amount)
            WUtils.showCoinDp(coin0, txPoolInDenomLabel, txPoolInAmountLabel, chain.chainType)
            WUtils.showCoinDp(coin1, txPoolOutDenomLabel, txPoolOutAmountLabel, chain.chainType)
        }
        
        if let msg = try? Kava_Swap_V1beta1_MsgSwapForExactTokens.init(serializedData: response.tx.body.messages[position].value) {
            txTypeLabel.text = "SwapForExactTokens"
            txSenderLabel.text = msg.requester

            let coin0 = Coin.init(msg.tokenA.denom, msg.tokenA.amount)
            let coin1 = Coin.init(msg.exactTokenB.denom, msg.exactTokenB.amount)
            WUtils.showCoinDp(coin0, txPoolInDenomLabel, txPoolInAmountLabel, chain.chainType)
            WUtils.showCoinDp(coin1, txPoolOutDenomLabel, txPoolOutAmountLabel, chain.chainType)
        }
    }
}
