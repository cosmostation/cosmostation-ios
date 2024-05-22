//
//  HistoryCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var msgsTitleLabel: UILabel!
    @IBOutlet weak var sendtxImg: UIImageView!
    @IBOutlet weak var successImg: UIImageView!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var coinCntLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        sendtxImg.isHidden = true
        amountLabel.isHidden = true
        denomLabel.isHidden = true
        coinCntLabel.isHidden = true
    }
    
    
    func bindCosmosClassHistory(_ account: BaseAccount, _ chain: CosmosClass, _ history: MintscanHistory) {
        if (history.isSuccess()) {
            successImg.image = UIImage(named: "iconSuccess")
        } else {
            successImg.image = UIImage(named: "iconFail")
        }
        let dpMsgType = history.getMsgType(chain)
        
        msgsTitleLabel.text = dpMsgType
        sendtxImg.isHidden = (dpMsgType == NSLocalizedString("tx_send", comment: "")) ? false : true
        
        hashLabel.text = history.data?.txhash
        timeLabel.text = WDP.dpTime(history.header?.timestamp)
        if let height = history.data?.height {
            blockLabel.text = "(" + String(height) + ")"
            blockLabel.isHidden = false
        } else {
            blockLabel.isHidden = true
        }
        
        if (NSLocalizedString("tx_vote", comment: "") == dpMsgType) {
            denomLabel.text = history.getVoteOption()
            denomLabel.isHidden = false
            denomLabel.textColor = .color01
            return
        }
        
        if let dpCoins = history.getDpCoin(chain) {
            if (dpCoins.count > 0) {
                if let msAsset = BaseData.instance.getAsset(chain.apiName, dpCoins[0].denom) {
                    WDP.dpCoin(msAsset, dpCoins[0], nil, denomLabel, amountLabel, msAsset.decimals)
                    amountLabel.isHidden = false
                    denomLabel.isHidden = false
                }
            }
            if (dpCoins.count > 1) {
                coinCntLabel.text = "+" + String(dpCoins.count - 1)
                coinCntLabel.isHidden = false
            }
        }
        
        if let dpToken = history.getDpToken(chain) {
            WDP.dpToken(dpToken.erc20, dpToken.amount, nil, denomLabel, amountLabel, nil)
            amountLabel.isHidden = false
            denomLabel.isHidden = false
        }
    }
    
    func bindOktHistory(_ account: BaseAccount, _ chain: CosmosClass, _ history: OktHistory) {
        if (history.state != "success") {
            successImg.image = UIImage(named: "iconFail")
        } else {
            successImg.image = UIImage(named: "iconSuccess")
        }
        
        msgsTitleLabel.text = history.height
        hashLabel.text = history.txId
        timeLabel.text = WDP.okcDpTime(Int64(history.transactionTime!))
        blockLabel.isHidden = true
        
        denomLabel.text = WDP.okcDpTimeGap(Int64(history.transactionTime!))
        denomLabel.isHidden = false
        
    }
}
