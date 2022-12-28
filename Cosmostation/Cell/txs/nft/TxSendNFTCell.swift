//
//  TxSendNFTCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/27.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxSendNFTCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txTitleLabel: UILabel!
    @IBOutlet weak var txNFTSenderLabel: UILabel!
    @IBOutlet weak var txNFTRecipientLabel: UILabel!
    @IBOutlet weak var txNFTTokenIdLabel: UILabel!
    @IBOutlet weak var txNFTDenomIdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int, _ myAddress: String) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if chain.chainType == .IRIS_MAIN, let msg = try? Irismod_Nft_MsgTransferNFT.init(serializedData: response.tx.body.messages[position].value) {
            txTitleLabel.text = NSLocalizedString("tx_nft_transfer", comment: "")
            if (myAddress == msg.sender) {
                txTitleLabel.text = NSLocalizedString("tx_nft_send", comment: "")
            }
            if (myAddress == msg.recipient) {
                txTitleLabel.text = NSLocalizedString("tx_nft_receive", comment: "")
            }
            txNFTSenderLabel.text = msg.sender
            txNFTRecipientLabel.text = msg.recipient
            txNFTTokenIdLabel.text = msg.id
            txNFTDenomIdLabel.text = msg.denomID
            
        } else if chain.chainType == .CRYPTO_MAIN, let msg = try? Chainmain_Nft_V1_MsgTransferNFT.init(serializedData: response.tx.body.messages[position].value) {            
            txTitleLabel.text = NSLocalizedString("tx_nft_transfer", comment: "")
            if (myAddress == msg.sender) {
                txTitleLabel.text = NSLocalizedString("tx_nft_send", comment: "")
            }
            if (myAddress == msg.recipient) {
                txTitleLabel.text = NSLocalizedString("tx_nft_receive", comment: "")
            }
            txNFTSenderLabel.text = msg.sender
            txNFTRecipientLabel.text = msg.recipient
            txNFTTokenIdLabel.text = msg.id
            txNFTDenomIdLabel.text = msg.denomID
            
        }
    }
    
}
