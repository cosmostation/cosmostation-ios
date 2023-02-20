//
//  TxEarnCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/31.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxEarnCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txMsgTitleLabel: UILabel!
    @IBOutlet weak var txSenderTitleLabel: UILabel!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txValidatorLabel: UILabel!
    @IBOutlet weak var txValidatorTitle: UILabel!
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var txAmountTitle: UILabel!
    @IBOutlet weak var txDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txValidatorTitle.text = NSLocalizedString("str_validator", comment: "")
        txAmountTitle.text = NSLocalizedString("str_amount", comment: "")
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Router_V1beta1_MsgDelegateMintDeposit.init(serializedData: response.tx.body.messages[position].value) {
            txMsgTitleLabel.text = NSLocalizedString("tx_kava_earn_delegateDeposit2", comment: "")
            txSenderTitleLabel.text = NSLocalizedString("str_depositor_cdp", comment: "")
            txSenderLabel.text = msg.depositor
            if let validator = BaseData.instance.searchValidator(withAddress: msg.validator) {
                txValidatorLabel.text = "(" + validator.description_p.moniker + ")"
            }
            let coin = Coin.init(msg.amount.denom, msg.amount.amount)
            WDP.dpCoin(chainConfig, coin, txDenomLabel, txAmountLabel)
            return
        }
        
        if let msg = try? Kava_Router_V1beta1_MsgWithdrawBurn.init(serializedData: response.tx.body.messages[position].value) {
            txMsgTitleLabel.text = NSLocalizedString("tx_kava_earn_withdraw2", comment: "")
            txSenderTitleLabel.text = NSLocalizedString("str_from", comment: "")
            txSenderLabel.text = msg.from
            if let validator = BaseData.instance.searchValidator(withAddress: msg.validator) {
                txValidatorLabel.text = "(" + validator.description_p.moniker + ")"
            }
            let coin = Coin.init(msg.amount.denom, msg.amount.amount)
            WDP.dpCoin(chainConfig, coin, txDenomLabel, txAmountLabel)
        }
        
        
    }
    
}
