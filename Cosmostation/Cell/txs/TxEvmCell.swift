//
//  TxEvmCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/19.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import web3swift

class TxEvmCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var msgTitleLabel: UILabel!
    @IBOutlet weak var resultImg: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindEvm(_ chainConfig: ChainConfig, _ txDetail: TransactionDetails?, _ txReceipt: TransactionReceipt?) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chainConfig.chainColor
        if (txDetail == nil || txReceipt == nil) { return }
        
        if (txReceipt?.status == .ok) {
            resultImg.image = UIImage(named: "successIc")
            resultLabel.text = NSLocalizedString("tx_success", comment: "")
        } else {
            resultImg.image = UIImage(named: "failIc")
            resultLabel.text = NSLocalizedString("tx_fail", comment: "")
        }
        blockLabel.text = String(txDetail!.blockNumber ?? "0")
        gasLabel.text = String(txReceipt!.gasUsed) + " / " + String(txDetail!.transaction.gasLimit)
//        typeLabel.text = txDetail?.transaction.type.description
        contactLabel.text = txDetail?.transaction.to.address
        dataLabel.text = txDetail?.transaction.data.toHexString()
    }
    
}
