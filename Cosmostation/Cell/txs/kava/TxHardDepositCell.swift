//
//  TxHardDepositCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxHardDepositCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var depositor: UILabel!
    @IBOutlet weak var depositAmount: UILabel!
    @IBOutlet weak var depositDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        depositAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Hard_V1beta1_MsgDeposit.init(serializedData: response.tx.body.messages[position].value) {
            depositor.text = msg.depositor
            
            let coin = Coin.init(msg.amount[0].denom, msg.amount[0].amount)
            WUtils.showCoinDp(coin, depositDenom, depositAmount, chain)
        }
    }
    
    func onBind(_ chaintype: ChainType, _ msg: Msg) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chaintype)
        depositor.text = msg.value.depositor
        if let depostAmounts = msg.value.getAmounts() {
            WUtils.showCoinDp(depostAmounts[0], depositDenom, depositAmount, chaintype)
        }
        
        //support old version
        if let depostAmount = msg.value.getAmount() {
            WUtils.showCoinDp(depostAmount, depositDenom, depositAmount, chaintype)
        }
    }
    
}
