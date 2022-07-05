//
//  TxInstantContractCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/02/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxInstantContractCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var executorLabel: UILabel!
    @IBOutlet weak var codeIdLabel: UILabel!
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var fundAmountLabel: UILabel!
    @IBOutlet weak var fundAmountDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        fundAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Cosmwasm_Wasm_V1_MsgInstantiateContract.init(serializedData: response.tx.body.messages[position].value) {
            adminLabel.text = msg.admin
            executorLabel.text = msg.sender
            codeIdLabel.text = String(msg.codeID)
            labelLabel.text = msg.label
            
            if let msgDetail = try? JSONSerialization.jsonObject(with: msg.msg, options: .allowFragments) as? [String : Any]  {
                messageLabel.text = String(describing: msgDetail!)
            }
            
            if (msg.funds.count > 0) {
                WDP.dpCoin(chainConfig, msg.funds[0].denom, msg.funds[0].amount, fundAmountDenom, fundAmountLabel)
            } else {
                fundAmountLabel.text = ""
                fundAmountDenom.text = ""
            }
        }
            
    }
}
