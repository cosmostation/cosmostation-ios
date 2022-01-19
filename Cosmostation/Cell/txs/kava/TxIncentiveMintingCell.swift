//
//  TxIncentiveMintingCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxIncentiveMintingCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var multiplier: UILabel!
    @IBOutlet weak var kavaAmount: UILabel!
    @IBOutlet weak var kavaDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        kavaAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        //temp
        kavaAmount.isHidden = true
        kavaDenom.isHidden = true
        
        if let msg = try? Kava_Incentive_V1beta1_MsgClaimUSDXMintingReward.init(serializedData: response.tx.body.messages[position].value) {
            sender.text = msg.sender
            multiplier.text = msg.multiplierName
        }
    }
    
    
    func onBind(_ chaintype: ChainType, _ msg: Msg, _ tx: TxInfo, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chaintype)
        
        sender.text = msg.value.sender
        multiplier.text = msg.value.multiplier_name
        
        if let coin = tx.simpleIncentive(position) {
            WUtils.showCoinDp(coin, kavaDenom, kavaAmount, chaintype)
        }
    }
}
