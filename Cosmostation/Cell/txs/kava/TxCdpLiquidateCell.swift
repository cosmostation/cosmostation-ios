//
//  TxCdpLiquidateCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxCdpLiquidateCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var keeper: UILabel!
    @IBOutlet weak var owener: UILabel!
    @IBOutlet weak var type: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBind(_ chaintype: ChainType, _ msg: Msg) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chaintype)
        keeper.text = msg.value.keeper
        owener.text = msg.value.borrower
        type.text = msg.value.collateral_type?.uppercased()
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Kava_Cdp_V1beta1_MsgLiquidate.init(serializedData: response.tx.body.messages[position].value) {
            keeper.text = msg.keeper
            owener.text = msg.borrower
            type.text = msg.collateralType
        }
    }
    
}
