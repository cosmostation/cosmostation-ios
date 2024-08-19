//
//  HistoryCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    }
    
    override func prepareForReuse() {
        sendtxImg.isHidden = true
        amountLabel.isHidden = true
        denomLabel.isHidden = true
        coinCntLabel.isHidden = true
    }
    
    
    func bindCosmosClassHistory(_ account: BaseAccount, _ chain: BaseChain, _ history: MintscanHistory) {
        if (history.isSuccess()) {
            successImg.image = UIImage(named: "iconSuccess")
        } else {
            successImg.image = UIImage(named: "iconFail")
        }
        let dpMsgType = history.getMsgType(chain)
        
        msgsTitleLabel.text = dpMsgType
        msgsTitleLabel.adjustsFontSizeToFitWidth = true
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
            denomLabel.textColor = .color01
        }
    }
    
    func bindOktHistory(_ account: BaseAccount, _ chain: BaseChain, _ history: OktHistory) {
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
    
    func bindSuiHistory(_ suiChain: ChainSui, _ history: JSON) {
        if (history["effects"]["status"]["status"].stringValue != "success") {
            successImg.image = UIImage(named: "iconFail")
        } else {
            successImg.image = UIImage(named: "iconSuccess")
        }
        
        var title = ""
        var description = ""
        let txs = history["transaction"]["data"]["transaction"]["transactions"].arrayValue
        if (!txs[0].isEmpty) {
            description = txs.last?.dictionaryValue.keys.first ?? "Unknown"
            if (txs.count > 1) {
                description = description +  " + " + String(txs.count)
            }
            
            let sender = history["transaction"]["data"]["sender"].stringValue
            if (sender == suiChain.mainAddress) {
                title = NSLocalizedString("tx_send", comment: "")
            } else {
                title = NSLocalizedString("tx_receive", comment: "")
            }
            txs.forEach { tx in
                if (tx["MoveCall"]["function"].stringValue == "request_withdraw_stake") {
                    title = NSLocalizedString("str_unstake", comment: "")
                }
            }
            txs.forEach { tx in
                if (tx["MoveCall"]["function"].stringValue == "request_add_stake") {
                    title = NSLocalizedString("str_stake", comment: "")
                }
            }
        }
        
        if title.isEmpty == true {
            msgsTitleLabel.text = description
        } else {
            msgsTitleLabel.text = title
        }
        hashLabel.text = history["digest"].stringValue
        timeLabel.text = WDP.dpTime(history["timestampMs"].intValue)
        blockLabel.text = "(" +  history["checkpoint"].stringValue + ")"
        
        if let change = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue == suiChain.mainAddress }).first {
            
            if let symbol = change["coinType"].string,
               let amount = change["amount"].string,
               let suiFetcher = suiChain.getSuiFetcher(),
               var intAmount = Int64(amount) {
                
                intAmount = abs(intAmount)
                if let msAsset = BaseData.instance.getAsset(suiChain.apiName, symbol) {
                    WDP.dpCoin(msAsset, NSDecimalNumber(value: intAmount), nil, denomLabel, amountLabel, msAsset.decimals)
                    
                } else if let metaData = suiFetcher.suiCoinMeta[symbol] {
                    denomLabel.text = metaData["symbol"].stringValue
                    let dpAmount = NSDecimalNumber(value: intAmount).multiplying(byPowerOf10: -metaData["decimals"].int16Value, withBehavior: handler18Down)
                    amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 9)
                    
                } else {
                    denomLabel.text = symbol
                    let dpAmount = NSDecimalNumber(value: intAmount).multiplying(byPowerOf10: -9, withBehavior: handler18Down)
                    amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 9)
                }
                amountLabel.isHidden = false
                denomLabel.isHidden = false
            }
        }
        
    }
}
