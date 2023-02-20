//
//  TxEditRewardAddressCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/02/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxEditRewardAddressCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var delegatorLabel: UILabel!
    @IBOutlet weak var editAddressTitle: UILabel!
    @IBOutlet weak var delegatorTitle: UILabel!
    @IBOutlet weak var widthrawAddressLabel: UILabel!
    @IBOutlet weak var widthrawAddressTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        editAddressTitle.text = NSLocalizedString("tx_change_reward_address", comment: "")
        delegatorTitle.text = NSLocalizedString("str_delegator", comment: "")
        widthrawAddressTitle.text = NSLocalizedString("str_withdraw_address", comment: "")
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Cosmos_Distribution_V1beta1_MsgSetWithdrawAddress.init(serializedData: response.tx.body.messages[position].value) {
            delegatorLabel.text = msg.delegatorAddress
            widthrawAddressLabel.text = msg.withdrawAddress
        }
    }
}
