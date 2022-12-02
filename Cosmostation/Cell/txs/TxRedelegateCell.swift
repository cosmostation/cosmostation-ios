//
//  TxRedelegateCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/02/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxRedelegateCell: TxCell {

    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var redelegatorLabel: UILabel!
    @IBOutlet weak var fromValidatorLabel: UILabel!
    @IBOutlet weak var fromMonikerLabel: UILabel!
    @IBOutlet weak var toValidatorLabel: UILabel!
    @IBOutlet weak var toMonikerLabel: UILabel!
    @IBOutlet weak var redelegateAmountLabel: UILabel!
    @IBOutlet weak var redelegateDenomLabel: UILabel!
    
    @IBOutlet weak var autoRewardLabel: UILabel!
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
        
        redelegateAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen0Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen1Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen2Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen3Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Cosmos_Staking_V1beta1_MsgBeginRedelegate.init(serializedData: response.tx.body.messages[position].value) {
            
            redelegatorLabel.text = msg.delegatorAddress
            fromValidatorLabel.text = msg.validatorSrcAddress
            if let fValidator = BaseData.instance.searchValidator(withAddress: msg.validatorSrcAddress) {
                fromMonikerLabel.text = "(" + fValidator.description_p.moniker + ")"
            }
            toValidatorLabel.text = msg.validatorDstAddress
            if let dValidator = BaseData.instance.searchValidator(withAddress: msg.validatorDstAddress) {
                toMonikerLabel.text = "(" + dValidator.description_p.moniker + ")"
            }
            WDP.dpCoin(chainConfig, msg.amount.denom, msg.amount.amount, redelegateDenomLabel, redelegateAmountLabel)
            
            let autoRewardCoins = WUtils.onParseAutoRewardGrpc(response, position)
            if (autoRewardCoins.count > 0) {
                autoRewardLabel.isHidden = false
                incen0Layer.isHidden = false
                WDP.dpCoin(chainConfig, autoRewardCoins[0], incen0Denom, incen0Amount)
            }
            if (autoRewardCoins.count > 1) {
                incen1Layer.isHidden = false
                WDP.dpCoin(chainConfig, autoRewardCoins[1], incen1Denom, incen1Amount)
            }
            if (autoRewardCoins.count > 2) {
                incen2Layer.isHidden = false
                WDP.dpCoin(chainConfig, autoRewardCoins[2], incen2Denom, incen2Amount)
            }
            if (autoRewardCoins.count > 3) {
                incen3Layer.isHidden = false
                WDP.dpCoin(chainConfig, autoRewardCoins[3], incen3Denom, incen3Amount)
            }
            
        }
    }
}
