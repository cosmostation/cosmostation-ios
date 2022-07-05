//
//  TxExitPoolCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/07/04.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxExitPoolCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txSenderLabel: UILabel!
    @IBOutlet weak var txPoolIdLabel: UILabel!
    @IBOutlet weak var txPoolShareInAmountLabel: UILabel!
    @IBOutlet weak var txPoolInAmountLabel: UILabel!
    @IBOutlet weak var txPoolInDenomLabel: UILabel!
    @IBOutlet weak var txPoolAsset1AmountLabel: UILabel!
    @IBOutlet weak var txPoolAsset1DenomLabel: UILabel!
    @IBOutlet weak var txPoolAsset2AmountLabel: UILabel!
    @IBOutlet weak var txPoolAsset2DenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txPoolAsset1AmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txPoolAsset2AmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        let msg = try! Osmosis_Gamm_V1beta1_MsgExitPool.init(serializedData: response.tx.body.messages[position].value)
        txSenderLabel.text = msg.sender
        txSenderLabel.adjustsFontSizeToFitWidth = true
        
        txPoolIdLabel.text = String(msg.poolID)
        
        txPoolShareInAmountLabel.text = NSDecimalNumber.init(string: msg.shareInAmount).multiplying(byPowerOf10: -18).rounding(accordingToBehavior: WUtils.handler18).stringValue
        
        var inCoin: Coin?
        if response.txResponse.logs.count > position {
            response.txResponse.logs[position].events.forEach { event in
                if (event.type == "transfer") {
                    if (event.attributes.count >= 6) {
                        for rawCoin in event.attributes[5].value.split(separator: ",") {
                            let coin = String(rawCoin)
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
        }
        print("inCoin ", inCoin)
        if (inCoin != nil) {
            WDP.dpCoin(chainConfig, inCoin!, txPoolInDenomLabel, txPoolInAmountLabel)
        } else {
            txPoolInAmountLabel.text = ""
            txPoolInDenomLabel.text = ""
        }
        
        var outCoins: Array<Coin> = Array<Coin>()
        if response.txResponse.logs.count > position {
            response.txResponse.logs[position].events.forEach { event in
                if (event.type == "transfer") {
                    if (event.attributes.count >= 6) {
                        for rawInCoin in event.attributes[2].value.split(separator: ",") {
                            let outCoin = String(rawInCoin)
                            if let range = outCoin.range(of: "[0-9]*", options: .regularExpression) {
                                let amount = String(outCoin[range])
                                let denomIndex = outCoin.index(outCoin.startIndex, offsetBy: amount.count)
                                let denom = String(outCoin[denomIndex...])
                                outCoins.append(Coin.init(denom, amount))
                            }
                        }
                    }
                }
            }
        }
        print("outCoins ", outCoins)
        if (outCoins.count == 2) {
            WDP.dpCoin(chainConfig, outCoins[0], txPoolAsset1DenomLabel, txPoolAsset1AmountLabel)
            WDP.dpCoin(chainConfig, outCoins[1], txPoolAsset2DenomLabel, txPoolAsset2AmountLabel)
        } else {
            txPoolAsset1AmountLabel.text = ""
            txPoolAsset1DenomLabel.text = ""
            txPoolAsset2AmountLabel.text = ""
            txPoolAsset2DenomLabel.text = ""
        }
    }
    
}
