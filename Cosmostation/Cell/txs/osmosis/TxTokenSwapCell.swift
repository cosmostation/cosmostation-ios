//
//  TxTokenSwapCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/07/04.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxTokenSwapCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var swapTokenTitle: UILabel!
    @IBOutlet weak var txTypeLabel: UILabel!
    @IBOutlet weak var txTypeTitle: UILabel!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txSenderTitle: UILabel!
    @IBOutlet weak var txPoolIdLabel: UILabel!
    @IBOutlet weak var txPoolIdTitle: UILabel!
    @IBOutlet weak var txSwapInAmountLabel: UILabel!
    @IBOutlet weak var txSwapInAmountTitle: UILabel!
    @IBOutlet weak var txSwapInDenomLabel: UILabel!
    @IBOutlet weak var txSwapOutAmountLabel: UILabel!
    @IBOutlet weak var txSwapOutAmountTitle: UILabel!
    @IBOutlet weak var txSwapOutDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        swapTokenTitle.text = NSLocalizedString("tx_coin_swap", comment: "")
        txTypeTitle.text = NSLocalizedString("str_swap_coin_type", comment: "")
        txSenderTitle.text = NSLocalizedString("str_sender", comment: "")
        txPoolIdTitle.text = NSLocalizedString("str_pool_id", comment: "")
        txSwapInAmountTitle.text = NSLocalizedString("str_swap_in", comment: "")
        txSwapInAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txSwapOutAmountTitle.text = NSLocalizedString("str_swap_out", comment: "")
        txSwapOutAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        if let msg = try? Osmosis_Gamm_V1beta1_MsgSwapExactAmountIn.init(serializedData: response.tx.body.messages[position].value) {
            txTypeLabel.text = String(Osmosis_Gamm_V1beta1_MsgSwapExactAmountIn.protoMessageName.split(separator: ".").last!)
            
            txSenderLabel.text = msg.sender
            txSenderLabel.adjustsFontSizeToFitWidth = true
            
            txPoolIdLabel.text = String(msg.routes[0].poolID)
            
            var inCoin: Coin = Coin.init(msg.tokenIn.denom, msg.tokenIn.amount)
            WDP.dpCoin(chainConfig, inCoin, txSwapInDenomLabel, txSwapInAmountLabel)
            
            var outCoin: Coin?
            if response.txResponse.logs.count > position {
                response.txResponse.logs[position].events.forEach { event in
                    if (event.type == "transfer") {
                        event.attributes.forEach { attribute in
                            if (event.attributes.count >= 6) {
                                let coin = String(event.attributes[event.attributes.count - 1].value)
                                if let range = coin.range(of: "[0-9]*", options: .regularExpression){
                                    let amount = String(coin[range])
                                    let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                    let denom = String(coin[denomIndex...])
                                    outCoin = Coin.init(denom, amount)
                                }
                            }
                        }
                    }
                }
            }
            if (outCoin != nil) {
                WDP.dpCoin(chainConfig, outCoin!, txSwapOutDenomLabel, txSwapOutAmountLabel)
            } else {
                txSwapOutAmountLabel.text = ""
                txSwapOutDenomLabel.text = ""
            }
            return
        }
        
        if let msg = try? Osmosis_Gamm_V1beta1_MsgSwapExactAmountOut.init(serializedData: response.tx.body.messages[position].value) {
            txTypeLabel.text = String(Osmosis_Gamm_V1beta1_MsgSwapExactAmountOut.protoMessageName.split(separator: ".").last!)
            
            txSenderLabel.text = msg.sender
            txSenderLabel.adjustsFontSizeToFitWidth = true
            
            txPoolIdLabel.text = String(msg.routes[0].poolID)
            
            var inCoin: Coin?
            if response.txResponse.logs.count > position {
                response.txResponse.logs[position].events.forEach { event in
                    if (event.type == "transfer") {
                        if (event.attributes.count >= 6) {
                            let coin = String(event.attributes[2].value)
                            if let range = coin.range(of: "[0-9]*", options: .regularExpression){
                                let amount = String(coin[range])
                                let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                let denom = String(coin[denomIndex...])
                                inCoin = Coin.init(denom, amount)
                            }
                        }
                    }
                }
            }
            if (inCoin != nil) {
                WDP.dpCoin(chainConfig, inCoin!, txSwapInDenomLabel, txSwapInAmountLabel)
            } else {
                txSwapInAmountLabel.text = ""
                txSwapInDenomLabel.text = ""
            }
            
            var outCoin: Coin?
            if response.txResponse.logs.count > position {
                response.txResponse.logs[position].events.forEach { event in
                    if (event.type == "transfer") {
                        event.attributes.forEach { attribute in
                            if (event.attributes.count >= 6) {
                                let coin = String(event.attributes[event.attributes.count - 1].value)
                                if let range = coin.range(of: "[0-9]*", options: .regularExpression){
                                    let amount = String(coin[range])
                                    let denomIndex = coin.index(coin.startIndex, offsetBy: amount.count)
                                    let denom = String(coin[denomIndex...])
                                    outCoin = Coin.init(denom, amount)
                                }
                            }
                        }
                    }
                }
            }
            if (outCoin != nil) {
                WDP.dpCoin(chainConfig, outCoin!, txSwapOutDenomLabel, txSwapOutAmountLabel)
            } else {
                txSwapOutAmountLabel.text = ""
                txSwapOutDenomLabel.text = ""
            }
        }
    }
}
