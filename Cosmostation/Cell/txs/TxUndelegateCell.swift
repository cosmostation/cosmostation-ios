//
//  TxUndelegateCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/02/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxUndelegateCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var undelegateTitle: UILabel!
    @IBOutlet weak var undelegatorLabel: UILabel!
    @IBOutlet weak var undelegatorTitle: UILabel!
    @IBOutlet weak var validatorLabel: UILabel!
    @IBOutlet weak var validatorTitle: UILabel!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var undelegateAmountLabel: UILabel!
    @IBOutlet weak var undelegateAmountTitle: UILabel!
    @IBOutlet weak var undelegateDenomLabel: UILabel!
    
    @IBOutlet weak var autoRewardLabel: UILabel!
    @IBOutlet weak var autoRewardTitle: UILabel!
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
        
        undelegateTitle.text = NSLocalizedString("tx_undelegate", comment: "")
        undelegatorTitle.text = NSLocalizedString("str_undelegator", comment: "")
        validatorTitle.text = NSLocalizedString("str_validator", comment: "")
        autoRewardTitle.text = NSLocalizedString("str_auto_claimed_reward", comment: "")
        undelegateAmountTitle.text = NSLocalizedString("str_amount", comment: "")
        undelegateAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen0Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen1Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen2Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen3Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Cosmos_Staking_V1beta1_MsgUndelegate.init(serializedData: response.tx.body.messages[position].value) {
            undelegatorLabel.text = msg.delegatorAddress
            validatorLabel.text = msg.validatorAddress
            if let validator = BaseData.instance.searchValidator(withAddress: msg.validatorAddress) {
                monikerLabel.text = "(" + validator.description_p.moniker + ")"
            }
            WDP.dpCoin(chainConfig, msg.amount.denom, msg.amount.amount, undelegateDenomLabel, undelegateAmountLabel)
            
            let autoRewardCoins = WUtils.onParseAutoRewardGrpc(response, position, msg.amount.amount)
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
