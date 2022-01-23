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
    
    @IBOutlet weak var incen0Layer: UIView!
    @IBOutlet weak var incen0Amount: UILabel!
    @IBOutlet weak var incen0Denom: UILabel!
    @IBOutlet weak var incen1Layer: UIView!
    @IBOutlet weak var incen1Amount: UILabel!
    @IBOutlet weak var incen1Denom: UILabel!
    @IBOutlet weak var incen2Layer: UIView!
    @IBOutlet weak var incen2Amount: UILabel!
    @IBOutlet weak var incen2Denom: UILabel!
    @IBOutlet weak var incen3Layer: UIView!
    @IBOutlet weak var incen3Amount: UILabel!
    @IBOutlet weak var incen3Denom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        incen0Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen1Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen2Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen3Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Incentive_V1beta1_MsgClaimUSDXMintingReward.init(serializedData: response.tx.body.messages[position].value) {
            sender.text = msg.sender
            multiplier.text = msg.multiplierName
            
            let incentiveCoins = WUtils.onParseKavaIncentiveGrpc(response, position)
            if (incentiveCoins.count > 0) {
                incen0Layer.isHidden = false
                WUtils.showCoinDp(incentiveCoins[0], incen0Denom, incen0Amount, chain)
            }
            if (incentiveCoins.count > 1) {
                incen1Layer.isHidden = false
                WUtils.showCoinDp(incentiveCoins[1], incen1Denom, incen1Amount, chain)
            }
            if (incentiveCoins.count > 2) {
                incen2Layer.isHidden = false
                WUtils.showCoinDp(incentiveCoins[2], incen2Denom, incen2Amount, chain)
            }
            if (incentiveCoins.count > 3) {
                incen3Layer.isHidden = false
                WUtils.showCoinDp(incentiveCoins[3], incen3Denom, incen3Amount, chain)
            }
        }
    }
    
    
    func onBind(_ chaintype: ChainType, _ msg: Msg, _ tx: TxInfo, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chaintype)
        
        sender.text = msg.value.sender
        multiplier.text = msg.value.multiplier_name
        
//        if let coin = tx.simpleIncentive(position) {
//            WUtils.showCoinDp(coin, kavaDenom, kavaAmount, chaintype)
//        }
    }
}
