//
//  TxHtlcRefundCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/04/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxHtlcRefundCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var refundAmount: UILabel!
    @IBOutlet weak var refundDenom: UILabel!
    @IBOutlet weak var fromAddress: UILabel!
    @IBOutlet weak var swapIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Bep3_V1beta1_MsgRefundAtomicSwap.init(serializedData: response.tx.body.messages[position].value) {
            fromAddress.text = msg.from
            swapIdLabel.text = msg.swapID
            refundAmount.isHidden = true
            refundDenom.isHidden = true
        }
    }
    
}
