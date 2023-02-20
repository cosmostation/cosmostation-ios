//
//  TxdrawDebtCdpCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/12.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxCdpBorrowCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var cdpBorrowTitle: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var senderTitle: UILabel!
    @IBOutlet weak var coinTypeLabel: UILabel!
    @IBOutlet weak var coinTypeTitle: UILabel!
    @IBOutlet weak var principalAmount: UILabel!
    @IBOutlet weak var principalAmountTitle: UILabel!
    @IBOutlet weak var principalDenom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        cdpBorrowTitle.text = NSLocalizedString("tx_kava_drawdebt_cdp2", comment: "")
        senderTitle.text = NSLocalizedString("str_sender_cdp", comment: "")
        coinTypeTitle.text = NSLocalizedString("str_denom_cdp", comment: "")
        principalAmountTitle.text = NSLocalizedString("str_principal_cdp", comment: "")
        principalAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Cdp_V1beta1_MsgDrawDebt.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.sender
            coinTypeLabel.text = msg.collateralType
            
            let principalCoin = Coin.init(msg.principal.denom, msg.principal.amount)
            WDP.dpCoin(chainConfig, principalCoin, principalDenom, principalAmount)
        }
    }
    
}
