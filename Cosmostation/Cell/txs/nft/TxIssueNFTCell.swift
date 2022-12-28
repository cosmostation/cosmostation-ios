//
//  TxIssueNFTCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/27.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxIssueNFTCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txNFTTokenIdLabel: UILabel!
    @IBOutlet weak var txNFTDenomIdLabel: UILabel!
    @IBOutlet weak var txNFTNameLabel: UILabel!
    @IBOutlet weak var txNFTDescriptionLabel: UILabel!
    @IBOutlet weak var txNFTUrlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txNFTTokenIdLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txNFTDenomIdLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txNFTNameLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txNFTDescriptionLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txNFTUrlLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if chain.chainType == .IRIS_MAIN, let msg = try? Irismod_Nft_MsgMintNFT.init(serializedData: response.tx.body.messages[position].value) {
            txNFTTokenIdLabel.text = msg.id
            txNFTDenomIdLabel.text = msg.denomID
            txNFTNameLabel.text = msg.name
            txNFTDescriptionLabel.text = WUtils.getNftDescription(msg.data)
            txNFTUrlLabel.text = msg.uri
            
        } else if chain.chainType == .CRYPTO_MAIN, let msg = try? Chainmain_Nft_V1_MsgMintNFT.init(serializedData: response.tx.body.messages[position].value) {            
            txNFTTokenIdLabel.text = msg.id
            txNFTDenomIdLabel.text = msg.denomID
            txNFTNameLabel.text = msg.name
            txNFTDescriptionLabel.text = WUtils.getNftDescription(msg.data)
            txNFTUrlLabel.text = msg.uri
        }
    }
    
}
