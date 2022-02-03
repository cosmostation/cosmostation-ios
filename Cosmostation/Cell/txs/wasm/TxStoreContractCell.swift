//
//  TxStoreContractCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/02/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxStoreContractCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Cosmwasm_Wasm_V1_MsgStoreCode.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.sender
        }
    }
    
}
