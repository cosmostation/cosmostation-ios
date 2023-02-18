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
    @IBOutlet weak var cdpWithdrawTitle: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var ownerTitle: UILabel!
    @IBOutlet weak var depositorLabel: UILabel!
    @IBOutlet weak var depositorTitle: UILabel!
    @IBOutlet weak var collateralAmount: UILabel!
    @IBOutlet weak var collateralAmountTitle: UILabel!
    @IBOutlet weak var collateralDenom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        cdpWithdrawTitle.text = NSLocalizedString("tx_kava_withdraw_cdp2", comment: "")
        ownerTitle.text = NSLocalizedString("str_owner_cdp", comment: "")
        depositorTitle.text = NSLocalizedString("str_depositor_cdp", comment: "")
        collateralAmountTitle.text = NSLocalizedString("str_collateral_cdp", comment: "")
        collateralAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Cdp_V1beta1_MsgWithdraw.init(serializedData: response.tx.body.messages[position].value) {
            ownerLabel.text = msg.owner
            depositorLabel.text = msg.depositor
            
            let collateralCoin = Coin.init(msg.collateral.denom, msg.collateral.amount)
            WDP.dpCoin(chainConfig, collateralCoin, collateralDenom, collateralAmount)
        }
    }
    
}
