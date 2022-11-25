//
//  TxLiquidStakeCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxLiquidStakeCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txTitleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        let msgPoint = response.tx.body.messages[position]
        
        if (msgPoint.typeURL.contains(Stride_Stakeibc_MsgLiquidStake.protoMessageName)) {
            if let msg = try? Stride_Stakeibc_MsgLiquidStake.init(serializedData: msgPoint.value) {
                txTitleLabel.text = NSLocalizedString("tx_stride_liquid_stake", comment: "")
                creatorLabel.text = msg.creator
                creatorLabel.adjustsFontSizeToFitWidth = true
                recipientLabel.text = ""
                if let recipientChain = ChainFactory.SUPPRT_CONFIG().filter({ $0.stakeDenom == msg.hostDenom }).first {
                    WDP.dpCoin(recipientChain, recipientChain.stakeDenom, String(msg.amount), denomLabel, amountLabel)
                }
            }
        }
        
        if (msgPoint.typeURL.contains(Stride_Stakeibc_MsgRedeemStake.protoMessageName)) {
            if let msg = try? Stride_Stakeibc_MsgRedeemStake.init(serializedData: msgPoint.value) {
                txTitleLabel.text = NSLocalizedString("tx_stride_liquid_unstake", comment: "")
                creatorLabel.text = msg.creator
                creatorLabel.adjustsFontSizeToFitWidth = true
                recipientLabel.text = msg.receiver
                recipientLabel.adjustsFontSizeToFitWidth = true
                
                if let recipientChain = ChainFactory.SUPPRT_CONFIG().filter({ msg.hostZone.starts(with: $0.chainIdPrefix) == true }).first {
                    WDP.dpCoin(recipientChain, recipientChain.stakeDenom, String(msg.amount), denomLabel, amountLabel)
                }
            }
        }
    }
}
