//
//  TxWithDrawCdpCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/12.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxCdpWithdrawCell: TxCell {

    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var depositorLabel: UILabel!
    @IBOutlet weak var collateralAmount: UILabel!
    @IBOutlet weak var collateralDenom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        collateralAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Cdp_V1beta1_MsgWithdraw.init(serializedData: response.tx.body.messages[position].value) {
            ownerLabel.text = msg.owner
            depositorLabel.text = msg.depositor
            
            let collateralCoin = Coin.init(msg.collateral.denom, msg.collateral.amount)
            WUtils.showCoinDp(collateralCoin, collateralDenom, collateralAmount, chain)
        }
    }
    
}
