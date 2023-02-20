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
    @IBOutlet weak var swapTokenTitle: UILabel!
    @IBOutlet weak var txTypeLabel: UILabel!
    @IBOutlet weak var txTypeTitle: UILabel!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txSenderTitle: UILabel!
    @IBOutlet weak var swapInTitle: UILabel!
    @IBOutlet weak var swapOutTitle: UILabel!
    @IBOutlet weak var txPoolInAmountLabel: UILabel!
    @IBOutlet weak var txPoolInDenomLabel: UILabel!
    @IBOutlet weak var txPoolOutAmountLabel: UILabel!
    @IBOutlet weak var txPoolOutDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        swapTokenTitle.text = NSLocalizedString("tx_coin_swap", comment: "")
        txTypeTitle.text = NSLocalizedString("str_type", comment: "")
        txSenderTitle.text = NSLocalizedString("str_sender", comment: "")
        swapInTitle.text = NSLocalizedString("str_swap_in", comment: "")
        swapOutTitle.text = NSLocalizedString("str_swap_out", comment: "")
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Swap_V1beta1_MsgSwapExactForTokens.init(serializedData: response.tx.body.messages[position].value) {
            txTypeLabel.text = "SwapExactForTokens"
            txSenderLabel.text = msg.requester

            let coin0 = Coin.init(msg.exactTokenA.denom, msg.exactTokenA.amount)
            let coin1 = Coin.init(msg.tokenB.denom, msg.tokenB.amount)
            WDP.dpCoin(chainConfig, coin0, txPoolInDenomLabel, txPoolInAmountLabel)
            WDP.dpCoin(chainConfig, coin1, txPoolOutDenomLabel, txPoolOutAmountLabel)
        }
        
        if let msg = try? Kava_Swap_V1beta1_MsgSwapForExactTokens.init(serializedData: response.tx.body.messages[position].value) {
            txTypeLabel.text = "SwapForExactTokens"
            txSenderLabel.text = msg.requester

            let coin0 = Coin.init(msg.tokenA.denom, msg.tokenA.amount)
            let coin1 = Coin.init(msg.exactTokenB.denom, msg.exactTokenB.amount)
            WDP.dpCoin(chainConfig, coin0, txPoolInDenomLabel, txPoolInAmountLabel)
            WDP.dpCoin(chainConfig, coin1, txPoolOutDenomLabel, txPoolOutAmountLabel)
        }
    }
}
