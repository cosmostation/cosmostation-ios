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
        
        if let msg = try? Pstake_Lscosmos_V1beta1_MsgLiquidStake.init(serializedData: msgPoint.value) {
            txTitleLabel.text = NSLocalizedString("tx_stride_liquid_stake", comment: "")
            delegatorLabel.text = msg.delegatorAddress
            delegatorLabel.adjustsFontSizeToFitWidth = true
            WDP.dpCoin(chainConfig, msg.amount.denom, msg.amount.amount, denomLabel, amountLabel)
        }
    }
}
