//
//  TxCreateCdpCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/12.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxCdpCreateCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var cdpOpenTitle: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var senderTitle: UILabel!
    @IBOutlet weak var collateralAmount: UILabel!
    @IBOutlet weak var collateralAmountTitle: UILabel!
    @IBOutlet weak var collateralDenom: UILabel!
    @IBOutlet weak var principalAmount: UILabel!
    @IBOutlet weak var principalAmountTitle: UILabel!
    @IBOutlet weak var principalDenom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        cdpOpenTitle.text = NSLocalizedString("tx_kava_deposit_cdp2", comment: "")
        senderTitle.text = NSLocalizedString("str_sender_cdp", comment: "")
        collateralAmountTitle.text = NSLocalizedString("str_collateral_cdp", comment: "")
        principalAmountTitle.text = NSLocalizedString("str_principal_cdp", comment: "")
        collateralAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        principalAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Kava_Cdp_V1beta1_MsgCreateCDP.init(serializedData: response.tx.body.messages[position].value) {
            senderLabel.text = msg.sender
            
            let collateralCoin = Coin.init(msg.collateral.denom, msg.collateral.amount)
            WDP.dpCoin(chainConfig, collateralCoin, collateralDenom, collateralAmount)
            
            let principalCoin = Coin.init(msg.principal.denom, msg.principal.amount)
            WDP.dpCoin(chainConfig, principalCoin, principalDenom, principalAmount)
        }
    }
    
}
