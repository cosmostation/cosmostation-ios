//
//  HistoryCell.swift
//  Cosmostation
//
//  Created by yongjoo on 23/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var txRootCard: CardView!
    @IBOutlet weak var txTypeLabel: UILabel!
    @IBOutlet weak var txResultLabel: UILabel!
    @IBOutlet weak var txTimeLabel: UILabel!
    @IBOutlet weak var txTimeGapLabel: UILabel!
    @IBOutlet weak var txBlockLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func bindHistoryCustomView(_ history: ApiHistoryCustom, _ address: String) {
        txTimeLabel.text = WUtils.txTimetoString(input: history.timestamp)
        txTimeGapLabel.text = WUtils.txTimeGap(input: history.timestamp)
        txBlockLabel.text = String(history.height!) + " block"
        txTypeLabel.text = history.getMsgType(address)
        if (history.isSuccess()) { txResultLabel.isHidden = true }
        else { txResultLabel.isHidden = false }
    }
    
    func bindHistoryBnbView(_ history: BnbHistory, _ address: String) {
        txTimeLabel.text = WUtils.nodeTimetoString(input: history.timeStamp)
        txTimeGapLabel.text = WUtils.timeGap(input: history.timeStamp)
        txBlockLabel.text = String(history.blockHeight) + " block"
        txTypeLabel.text = history.getTitle(address)
        txResultLabel.isHidden = true
    }
    
    func bindHistoryOkView(_ history: OKHistoryHit, _ address: String) {
        txTypeLabel.text = history.transactionDataType
        txTimeLabel.text = WUtils.longTimetoString(history.blocktime!)
        txTimeGapLabel.text = WUtils.timeGap2(input: history.blocktime!)
        txBlockLabel.text = history.hash
    }
    
}
