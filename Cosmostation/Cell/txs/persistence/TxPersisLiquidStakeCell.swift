//
//  TxPersisLiquidStakeCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class TxPersisLiquidStakeCell: TxCell {

    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txTitleLabel: UILabel!
    @IBOutlet weak var delegatorLabel: UILabel!
    @IBOutlet weak var amountInLabel: UILabel!
    @IBOutlet weak var denomInLabel: UILabel!
    @IBOutlet weak var amountOutLabel: UILabel!
    @IBOutlet weak var denomOutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        let msgPoint = response.tx.body.messages[position]
        
        if (msgPoint.typeURL.contains(Pstake_Liquidstakeibc_V1beta1_MsgLiquidStake.protoMessageName)) {
            if let msg = try? Pstake_Liquidstakeibc_V1beta1_MsgLiquidStake.init(serializedData: msgPoint.value) {
                txTitleLabel.text = NSLocalizedString("tx_stride_liquid_stake", comment: "")
                delegatorLabel.text = msg.delegatorAddress
                delegatorLabel.adjustsFontSizeToFitWidth = true
                
                WDP.dpCoin(chainConfig, msg.amount.denom, msg.amount.amount, denomInLabel, amountInLabel)
                let liquidCoin = WUtils.onParseLiquidAmountGrpc(response, position).filter{ $0.denom.starts(with: "stk/") }.first
                WDP.dpCoin(chainConfig, liquidCoin, denomOutLabel, amountOutLabel)
            }
            
        } else if (msgPoint.typeURL.contains(Pstake_Liquidstakeibc_V1beta1_MsgRedeem.protoMessageName)) {
            if let msg = try? Pstake_Liquidstakeibc_V1beta1_MsgLiquidStake.init(serializedData: msgPoint.value) {
                txTitleLabel.text = NSLocalizedString("tx_persis_liquid_redeem", comment: "")
                delegatorLabel.text = msg.delegatorAddress
                delegatorLabel.adjustsFontSizeToFitWidth = true
                
                WDP.dpCoin(chainConfig, msg.amount.denom, msg.amount.amount, denomInLabel, amountInLabel)
                let liquidCoin = WUtils.onParseLiquidAmountGrpc(response, position).filter{ $0.denom.starts(with: "ibc/") }.first
                WDP.dpCoin(chainConfig, liquidCoin, denomOutLabel, amountOutLabel)
            }
        }
    }
}
