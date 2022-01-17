//
//  TxSwapDepositCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/30.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxSwapDepositCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txPoolAsset1AmountLabel: UILabel!
    @IBOutlet weak var txPoolAsset1DenomLabel: UILabel!
    @IBOutlet weak var txPoolAsset2AmountLabel: UILabel!
    @IBOutlet weak var txPoolAsset2DenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Swap_V1beta1_MsgDeposit.init(serializedData: response.tx.body.messages[position].value) {
            txSenderLabel.text = msg.depositor

            let coin0 = Coin.init(msg.tokenA.denom, msg.tokenA.amount)
            let coin1 = Coin.init(msg.tokenB.denom, msg.tokenB.amount)
            WUtils.showCoinDp(coin0, txPoolAsset1DenomLabel, txPoolAsset1AmountLabel, chain)
            WUtils.showCoinDp(coin1, txPoolAsset2DenomLabel, txPoolAsset2AmountLabel, chain)
        }
    }
    
    func onBind(_ chaintype: ChainType, _ msg: Msg, _ tx: TxInfo) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chaintype)
        
        txSenderLabel.text = msg.value.depositor
        let depositCoins = tx.simpleDeposits()
        if (depositCoins.count > 0) {
            WUtils.showCoinDp(depositCoins[0], txPoolAsset1DenomLabel, txPoolAsset1AmountLabel, chaintype)
        }
        if (depositCoins.count > 1) {
            WUtils.showCoinDp(depositCoins[1], txPoolAsset2DenomLabel, txPoolAsset2AmountLabel, chaintype)
        }
    }
    
}
