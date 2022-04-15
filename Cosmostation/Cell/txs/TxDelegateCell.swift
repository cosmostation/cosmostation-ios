//
//  TxDelegateCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/02/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxDelegateCell: TxCell {

    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var delegatorLabel: UILabel!
    @IBOutlet weak var validatorLabel: UILabel!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var delegateAmountLabel: UILabel!
    @IBOutlet weak var delegateDenomLabel: UILabel!
    
    @IBOutlet weak var autoReward: UILabel!
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
        
        delegateAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen0Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen1Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen2Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        incen3Amount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Cosmos_Staking_V1beta1_MsgDelegate.init(serializedData: response.tx.body.messages[position].value) {
            delegatorLabel.text = msg.delegatorAddress
            validatorLabel.text = msg.validatorAddress
            if let validator = BaseData.instance.mAllValidators_gRPC.filter({ $0.operatorAddress == msg.validatorAddress}).first {
                monikerLabel.text = "(" + validator.description_p.moniker + ")"
            }
            WUtils.showCoinDp(msg.amount.denom, msg.amount.amount, delegateDenomLabel, delegateAmountLabel, chain)
            
            let autoRewardCoins = WUtils.onParseAutoRewardGrpc(response, position)
            if (autoRewardCoins.count > 0) {
                autoReward.isHidden = false
                incen0Layer.isHidden = false
                WUtils.showCoinDp(autoRewardCoins[0], incen0Denom, incen0Amount, chain)
            }
            if (autoRewardCoins.count > 1) {
                incen1Layer.isHidden = false
                WUtils.showCoinDp(autoRewardCoins[1], incen1Denom, incen1Amount, chain)
            }
            if (autoRewardCoins.count > 2) {
                incen2Layer.isHidden = false
                WUtils.showCoinDp(autoRewardCoins[2], incen2Denom, incen2Amount, chain)
            }
            if (autoRewardCoins.count > 3) {
                incen3Layer.isHidden = false
                WUtils.showCoinDp(autoRewardCoins[3], incen3Denom, incen3Amount, chain)
            }
            
        }
    }
    
//    func onBindHistoryMsg(_ chain: ChainType, _ history: ApiHistoryNewCustom, _ position: Int) {
//        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
//        txIcon.tintColor = WUtils.getChainColor(chain)
//        
//        if let msg = history.getMsgs()?[position] {
//            delegatorLabel.text = msg.object(forKey: "delegator_address") as? String
//            validatorLabel.text = msg.object(forKey: "validator_address") as? String
//            if let validator = BaseData.instance.mAllValidators_gRPC.filter({ $0.operatorAddress == msg.object(forKey: "validator_address") as? String}).first {
//                monikerLabel.text = "(" + validator.description_p.moniker + ")"
//            }
//            
//            if let rawCoin = msg.object(forKey: "amount") as? NSDictionary {
//                let coin = Coin.init(rawCoin)
//                WUtils.showCoinDp(coin, delegateDenomLabel, delegateAmountLabel, chain)
//            }
//        }
//        
//        //parisng auto reward coins
//        var autoRewardCoins = Array<Coin>()
//        if let events = history.data?.logs?[position].object(forKey: "events") as? Array<NSDictionary> {
//            events.forEach { event in
//                if (event.object(forKey: "type") as? String == "transfer") {
//                    if let attributes = event.object(forKey: "attributes") as? Array<NSDictionary>{
//                        attributes.forEach { attribute in
//                            if (attribute.object(forKey: "key") as? String == "amount") {
//                                let rawReward = attribute.object(forKey: "value") as? String ?? ""
//                                for rawCoin in rawReward.split(separator: ","){
//                                    let coin = String(rawCoin)
//                                    if let range = coin.range(of: "[0-9]*", options: .regularExpression) {
//                                        let amount = String(coin[range])
//                                        let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
//                                        let denom = String(coin[denomIndex...])
//                                        autoRewardCoins.append(Coin.init(denom, amount))
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        autoRewardCoins.sort {
//            if ($0.denom == WUtils.getMainDenom(chain)) { return true }
//            if ($1.denom == WUtils.getMainDenom(chain)) { return false }
//            return false
//        }
//        
//        
//        if (autoRewardCoins.count > 0) {
//            autoReward.isHidden = false
//            incen0Layer.isHidden = false
//            WUtils.showCoinDp(autoRewardCoins[0], incen0Denom, incen0Amount, chain)
//        }
//        if (autoRewardCoins.count > 1) {
//            incen1Layer.isHidden = false
//            WUtils.showCoinDp(autoRewardCoins[1], incen1Denom, incen1Amount, chain)
//        }
//        if (autoRewardCoins.count > 2) {
//            incen2Layer.isHidden = false
//            WUtils.showCoinDp(autoRewardCoins[2], incen2Denom, incen2Amount, chain)
//        }
//        if (autoRewardCoins.count > 3) {
//            incen3Layer.isHidden = false
//            WUtils.showCoinDp(autoRewardCoins[3], incen3Denom, incen3Amount, chain)
//        }
//        
//    }
}
