//
//  TxHardWithdrawCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxHardWithdrawCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var hardWithdrawTitle: UILabel!
    @IBOutlet weak var depositor: UILabel!
    @IBOutlet weak var depositorTitle: UILabel!
    @IBOutlet weak var depositAmount: UILabel!
    @IBOutlet weak var depositAmountTitle: UILabel!
    @IBOutlet weak var depositDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        hardWithdrawTitle.text = NSLocalizedString("tx_kava_hard_withdraw2", comment: "")
        depositorTitle.text = NSLocalizedString("str_depositor_cdp", comment: "")
        depositAmountTitle.text = NSLocalizedString("str_withdraw_amount", comment: "")
        depositAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Hard_V1beta1_MsgWithdraw.init(serializedData: response.tx.body.messages[position].value) {
            depositor.text = msg.depositor
            
            let coin = Coin.init(msg.amount[0].denom, msg.amount[0].amount)
            WDP.dpCoin(chainConfig, coin, depositDenom, depositAmount)
        }
    }
    
}
