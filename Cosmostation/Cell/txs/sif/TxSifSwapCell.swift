//
//  TxSifSwapCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/10/06.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxSifSwapCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txSingerLabel: UILabel!
    @IBOutlet weak var txSwapInAmountLabel: UILabel!
    @IBOutlet weak var txSwapInDenomLabel: UILabel!
    @IBOutlet weak var txSwapOutAmountLabel: UILabel!
    @IBOutlet weak var txSwapOutDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txSwapInAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txSwapOutAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chainConfig: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        
        let msg = try! Sifnode_Clp_V1_MsgSwap.init(serializedData: response.tx.body.messages[position].value)
        txSingerLabel.text = msg.signer
        txSingerLabel.adjustsFontSizeToFitWidth = true
        
        let inCoin = Coin.init(msg.sentAsset.symbol, msg.sentAmount)
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
    }
}
