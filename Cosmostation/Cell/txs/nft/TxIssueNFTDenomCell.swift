//
//  TxIssueNFTDenomCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/29.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxIssueNFTDenomCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txDenomIdLabel: UILabel!
    @IBOutlet weak var txDenomNameLabel: UILabel!
    @IBOutlet weak var txSchemaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txDenomIdLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txDenomNameLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txSchemaLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        if (chain == ChainType.IRIS_MAIN) {
            let msg = try! Irismod_Nft_MsgIssueDenom.init(serializedData: response.tx.body.messages[position].value)
            txDenomIdLabel.text = msg.id
            txDenomNameLabel.text = msg.name
            txSchemaLabel.text = msg.schema
            
            
        } else if (chain == ChainType.CRYPTO_MAIN) {
            let msg = try! Chainmain_Nft_V1_MsgIssueDenom.init(serializedData: response.tx.body.messages[position].value)
            txDenomIdLabel.text = msg.id
            txDenomNameLabel.text = msg.name
            txSchemaLabel.text = msg.schema
        }
    }
    
}
