//
//  TxAuthzExecCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxAuthzExecCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var granteeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Cosmos_Authz_V1beta1_MsgExec.init(serializedData: response.tx.body.messages[position].value) {
            granteeLabel.text = msg.grantee
            granteeLabel.adjustsFontSizeToFitWidth = true
            
            var msgTitle = ""
            let typeUrl = msg.msgs[0].typeURL
            if (typeUrl.contains(Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.protoMessageName)) {
                msgTitle = "Claim Reward"
                
            } else if (typeUrl.contains(Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission.protoMessageName)) {
                msgTitle = "Claim Commission"
                
            } else if (typeUrl.contains(Cosmos_Gov_V1beta1_MsgVote.protoMessageName)) {
                msgTitle = "Vote"
                
            } else if (typeUrl.contains(Cosmos_Staking_V1beta1_MsgDelegate.protoMessageName)) {
                msgTitle = "Delegate"
                
            } else if (typeUrl.contains(Cosmos_Staking_V1beta1_MsgUndelegate.protoMessageName)) {
                msgTitle = "Undelegate"
                
            } else if (typeUrl.contains(Cosmos_Staking_V1beta1_MsgBeginRedelegate.protoMessageName)) {
                msgTitle = "Redelegate"
                
            } else if (typeUrl.contains(Cosmos_Bank_V1beta1_MsgSend.protoMessageName)) {
                msgTitle = "Send"
                
            } else {
                msgTitle = "Etc"
            }
            
            if (msg.msgs.count > 1) {
                msgTitle = msgTitle +  " + " + String(msg.msgs.count - 1)
            }
            messageLabel.text = msgTitle
        }
    }
    
}
