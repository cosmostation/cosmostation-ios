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
    @IBOutlet weak var cdpLiquidateTitle: UILabel!
    @IBOutlet weak var keeper: UILabel!
    @IBOutlet weak var keeperTitle: UILabel!
    @IBOutlet weak var owener: UILabel!
    @IBOutlet weak var owenerTitle: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var typeTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        cdpLiquidateTitle.text = NSLocalizedString("tx_kava_liquidate_cdp2", comment: "")
        keeperTitle.text = NSLocalizedString("str_keeper", comment: "")
        owenerTitle.text = NSLocalizedString("str_borrower", comment: "")
        typeTitle.text = NSLocalizedString("str_type", comment: "")
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
