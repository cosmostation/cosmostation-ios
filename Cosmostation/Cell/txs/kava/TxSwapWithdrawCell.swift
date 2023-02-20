//
//  TxSwapWithdrawCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/30.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxSwapWithdrawCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var swapWithdrawTitle: UILabel!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txSenderTitle: UILabel!
    @IBOutlet weak var tokenOutTitle: UILabel!
    @IBOutlet weak var txPoolAsset1AmountLabel: UILabel!
    @IBOutlet weak var txPoolAsset1DenomLabel: UILabel!
    @IBOutlet weak var txPoolAsset2AmountLabel: UILabel!
    @IBOutlet weak var txPoolAsset2DenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        swapWithdrawTitle.text = NSLocalizedString("tx_kava_swap_withdraw2", comment: "")
        txSenderTitle.text = NSLocalizedString("str_sender", comment: "")
        tokenOutTitle.text = NSLocalizedString("str_token_out", comment: "")
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Swap_V1beta1_MsgWithdraw.init(serializedData: response.tx.body.messages[position].value) {
            txSenderLabel.text = msg.from

            let coin0 = Coin.init(msg.minTokenA.denom, msg.minTokenA.amount)
            let coin1 = Coin.init(msg.minTokenB.denom, msg.minTokenB.amount)
            WDP.dpCoin(chainConfig, coin0, txPoolAsset1DenomLabel, txPoolAsset1AmountLabel)
            WDP.dpCoin(chainConfig, coin1, txPoolAsset2DenomLabel, txPoolAsset2AmountLabel)
        }
    }
    
}
