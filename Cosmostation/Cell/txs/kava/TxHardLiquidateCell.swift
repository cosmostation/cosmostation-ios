//
//  TxHardLiquidateCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxHardLiquidateCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var hardLiquidateTitle: UILabel!
    @IBOutlet weak var keeper: UILabel!
    @IBOutlet weak var keeperTitle: UILabel!
    @IBOutlet weak var owener: UILabel!
    @IBOutlet weak var owenerTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        hardLiquidateTitle.text = NSLocalizedString("tx_kava_hard_liquidate2", comment: "")
        keeperTitle.text = NSLocalizedString("str_keeper", comment: "")
        owenerTitle.text = NSLocalizedString("str_borrower", comment: "")
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Kava_Hard_V1beta1_MsgLiquidate.init(serializedData: response.tx.body.messages[position].value) {
            keeper.text = msg.keeper
            owener.text = msg.borrower
        }
    }
    
}
