//
//  TxHtlcClaimCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/04/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TxHtlcClaimCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var claimAmount: UILabel!
    @IBOutlet weak var claimDenom: UILabel!
    @IBOutlet weak var claimerAddress: UILabel!
    @IBOutlet weak var randomNumberLabel: UILabel!
    @IBOutlet weak var swapIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        claimAmount.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if let msg = try? Kava_Bep3_V1beta1_MsgClaimAtomicSwap.init(serializedData: response.tx.body.messages[position].value) {
            claimerAddress.text = msg.from
            swapIdLabel.text = msg.swapID
            randomNumberLabel.text = msg.randomNumber
            
            let claimedCoins = WUtils.onParseBep3ClaimAmountGrpc(response, position)
            if (claimedCoins.count > 0) {
                WUtils.showCoinDp(claimedCoins[0], claimDenom, claimAmount, chain)
            }
        }
    }
    
}
