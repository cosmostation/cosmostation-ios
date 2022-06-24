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
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var coinTypeLabel: UILabel!
    @IBOutlet weak var principalAmount: UILabel!
    @IBOutlet weak var principalDenom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        principalAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Kava_Cdp_V1beta1_MsgDrawDebt.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.sender
            coinTypeLabel.text = msg.collateralType
            
            let principalCoin = Coin.init(msg.principal.denom, msg.principal.amount)
            WUtils.showCoinDp(principalCoin, principalDenom, principalAmount, chain.chainType)
        }
    }
    
}
