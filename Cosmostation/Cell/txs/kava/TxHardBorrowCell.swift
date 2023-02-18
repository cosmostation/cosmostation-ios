//
//  TxHardBorrowCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxHardBorrowCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var hardBorrowTitle: UILabel!
    @IBOutlet weak var borrower: UILabel!
    @IBOutlet weak var borrowerTitle: UILabel!
    @IBOutlet weak var borrowAmount: UILabel!
    @IBOutlet weak var borrowAmountTitle: UILabel!
    @IBOutlet weak var borrowDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        hardBorrowTitle.text = NSLocalizedString("tx_kava_hard_borrow2", comment: "")
        borrowerTitle.text = NSLocalizedString("str_borrower", comment: "")
        borrowAmountTitle.text = NSLocalizedString("str_borrow_amount", comment: "")
        borrowAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Hard_V1beta1_MsgBorrow.init(serializedData: response.tx.body.messages[position].value) {
            borrower.text = msg.borrower
            
            let coin = Coin.init(msg.amount[0].denom, msg.amount[0].amount)
            WDP.dpCoin(chainConfig, coin, borrowDenom, borrowAmount)
        }
    }
}
