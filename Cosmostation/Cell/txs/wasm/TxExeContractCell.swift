//
//  TxExeContractCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/02/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxExeContractCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var executorLabel: UILabel!
    @IBOutlet weak var contractAddressLabel: UILabel!
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
        
        if let msg = try? Cosmwasm_Wasm_V1_MsgExecuteContract.init(serializedData: response.tx.body.messages[position].value) {
            executorLabel.text = msg.sender
            contractAddressLabel.text = msg.contract
            
            if let msgDetail = try? JSONSerialization.jsonObject(with: msg.msg, options: .allowFragments) as? [String : Any]  {
                let msgKey = msgDetail!.map{String($0.key) }.first
                let msgVlaue = msgDetail![msgKey!]
                typeLabel.text = msgKey
                messageLabel.text = String(describing: msgVlaue!)
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
