//
//  TxAuthzRevokeCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class TxAuthzRevokeCell: TxCell {

    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var granterLabel: UILabel!
    @IBOutlet weak var granteeLabel: UILabel!
    @IBOutlet weak var grantTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Cosmos_Authz_V1beta1_MsgRevoke.init(serializedData: response.tx.body.messages[position].value) {
            granterLabel.text = msg.granter
            granteeLabel.text = msg.grantee
            granterLabel.adjustsFontSizeToFitWidth = true
            granteeLabel.adjustsFontSizeToFitWidth = true
            
            var msgTitle = ""
            let typeUrl = msg.msgTypeURL
            if typeUrl.contains(Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.protoMessageName) { msgTitle = "Claim Reward" }
            else if typeUrl.contains(Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission.protoMessageName) { msgTitle = "Claim Commission" }
            else if typeUrl == Cosmos_Gov_V1beta1_MsgVote.protoMessageName { msgTitle = "Vote" }
            else if typeUrl == Cosmos_Gov_V1beta1_MsgVoteWeighted.protoMessageName { msgTitle = "Vote Weighted" }
            else if typeUrl.contains(Cosmos_Staking_V1beta1_MsgDelegate.protoMessageName) { msgTitle = "Delegate" }
            else if typeUrl.contains(Cosmos_Staking_V1beta1_MsgUndelegate.protoMessageName) { msgTitle = "Undelegate" }
            else if typeUrl.contains(Cosmos_Staking_V1beta1_MsgBeginRedelegate.protoMessageName) { msgTitle = "Redelegate" }
            else if typeUrl.contains(Cosmos_Bank_V1beta1_MsgSend.protoMessageName) { msgTitle = "Send" }
            else { msgTitle = "Etc" }
                        
            grantTypeLabel.text = msgTitle
        }
    }
}
