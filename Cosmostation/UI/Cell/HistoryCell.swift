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
        msgsTitleLabel.text = ""
        hashLabel.text = ""
        timeLabel.text = ""
        blockLabel.text = ""
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
    
    
    func bindSuiHistory(_ suiChain: ChainSui, _ history: JSON) {
        // status check
        if (history["effects"]["status"]["status"].stringValue != "success") {
            successImg.image = UIImage(named: "iconFail")
        } else {
            successImg.image = UIImage(named: "iconSuccess")
        }
        
        // title check
        var title = ""
        var description = ""
        let txs = history["transaction"]["data"]["transaction"]["transactions"].arrayValue
        
        let sender = history["transaction"]["data"]["sender"].stringValue
        if (sender == suiChain.mainAddress) {
            title = NSLocalizedString("tx_send", comment: "")
        } else {
            title = NSLocalizedString("tx_receive", comment: "")
        }
        
        if (((txs.first?.isEmpty) == false)) {
            description = txs.last?.dictionaryValue.keys.first ?? "Unknown"
            if (txs.count > 1) {
                description = description +  " + " + String(txs.count)
            }

            txs.forEach { tx in
                if (tx["MoveCall"]["function"].stringValue == "request_withdraw_stake") {
                    title = NSLocalizedString("str_unstake", comment: "")
                    
                } else if (tx["MoveCall"]["function"].stringValue == "request_add_stake") {
                    title = NSLocalizedString("str_stake", comment: "")
                    
                } else if (tx["MoveCall"]["function"].stringValue == "swap") || tx["MoveCall"]["function"].stringValue == "swap_a_b" {
                    title = NSLocalizedString("title_swap_token", comment: "")
                    
                } else if (tx["MoveCall"]["function"].stringValue == "mint") {
                    title = "Supply"
                    
                } else if (tx["MoveCall"]["function"].stringValue == "redeem") {
                    title = "Redeem"
                    
                } else if tx["MoveCall"]["function"].stringValue == "unwrap"{
                    title = "Contract Interaction"
                }
            }
        }
        
        if title.isEmpty == true {
            msgsTitleLabel.text = description
        } else {
            msgsTitleLabel.text = title
        }
        
        
        // denom, amount check
        var symbol = ""
        var amount = "0"
        
        if let suiFetcher = suiChain.getSuiFetcher(),
           let inputs = history["transaction"]["data"]["transaction"]["inputs"].array {
                        
            amountLabel.isHidden = false
            denomLabel.isHidden = false
                        
            if title == NSLocalizedString("tx_send", comment: "") {
                if let sendSymbol = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue != suiChain.mainAddress }).first?["coinType"].string,
                      let sendAmount = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue != suiChain.mainAddress }).first?["amount"].string {
                    symbol = sendSymbol
                    amount = sendAmount
                } else {
                    amountLabel.isHidden = true
                    denomLabel.isHidden = true
                }

            } else if title == NSLocalizedString("tx_receive", comment: "") {
                if let receiveSymbol = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue == suiChain.mainAddress }).first?["coinType"].string,
                      let receiveAmount = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue == suiChain.mainAddress }).first?["amount"].string {
                    symbol = receiveSymbol
                    amount = receiveAmount
                } else {
                    amountLabel.isHidden = true
                    denomLabel.isHidden = true
                }
                
            } else if title == NSLocalizedString("str_stake", comment: "") {
                symbol = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue == suiChain.mainAddress }).first?["coinType"].string ?? ""
                amount = inputs.filter({ Int($0["value"].stringValue) != nil }).map({ $0["value"].stringValue }).first ?? "0"
                
            } else if title == NSLocalizedString("str_unstake", comment: "") {
                let computationCost = NSDecimalNumber(string: history["effects"]["gasUsed"]["computationCost"].stringValue)
                let storageCost = NSDecimalNumber(string: history["effects"]["gasUsed"]["storageCost"].stringValue)
                let storageRebate = NSDecimalNumber(string: history["effects"]["gasUsed"]["storageRebate"].stringValue)
                
                var gasCost: UInt64 = 0
                if (storageCost.compare(storageRebate).rawValue > 0) {
                    gasCost = UInt64(truncating: computationCost.adding(storageCost).subtracting(storageRebate))
                    if let unstakeAmount = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue == suiChain.mainAddress }).first?["amount"].string {
                        amount = String(UInt64(unstakeAmount)! + gasCost)
                        symbol = history["balanceChanges"].arrayValue.filter({ $0["owner"]["AddressOwner"].stringValue == suiChain.mainAddress }).first?["coinType"].string ?? ""
                    }
                } else {
                    amountLabel.isHidden = true
                    denomLabel.isHidden = true
                }
                
            } else {
                amountLabel.isHidden = true
                denomLabel.isHidden = true
            }
            
            let intAmount = abs(Int(amount)!)
            if let msAsset = BaseData.instance.getAsset(suiChain.apiName, symbol) {
                WDP.dpCoin(msAsset, NSDecimalNumber(value: intAmount), nil, denomLabel, amountLabel, msAsset.decimals)
                
            } else if let metaData = suiFetcher.suiCoinMeta[symbol] {
                denomLabel.text = metaData["symbol"].stringValue
                let dpAmount = NSDecimalNumber(value: intAmount).multiplying(byPowerOf10: -metaData["decimals"].int16Value, withBehavior: handler18Down)
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 9)
                
            } else {
                denomLabel.text = symbol.suiCoinSymbol()
                let dpAmount = NSDecimalNumber(value: intAmount).multiplying(byPowerOf10: -9, withBehavior: handler18Down)
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 9)
            }
        }
        

        //hash, time, block
        hashLabel.text = history["digest"].stringValue
        timeLabel.text = WDP.dpTime(history["timestampMs"].intValue)
        blockLabel.text = "(" +  history["checkpoint"].stringValue + ")"
    }
    
    func bindBtcHistory(_ btcChain: ChainBitCoin86, _ history: JSON) {
        if (history["status"]["confirmed"].boolValue == true) {
            successImg.image = UIImage(named: "iconSuccess")
            timeLabel.text = WDP.dpTime(history["status"]["block_time"].intValue * 1000)
            if let blockHeight = btcChain.getBtcFetcher()?.btcBlockHeight,
               let txHeight = history["status"]["block_height"].uInt64 {
                blockLabel.text = "(" + String(blockHeight - txHeight) + " Confirmed)"
            } else {
                blockLabel.text = String(history["status"]["block_height"].uInt64Value)
            }
            
        } else {
            successImg.image = UIImage(named: "iconTxPending")
            timeLabel.text = ""
            blockLabel.text = ""
        }
        
        var title = ""
        var inputAmounts = NSDecimalNumber.zero
        var outputAmount = NSDecimalNumber.zero
        var displayAmount = NSDecimalNumber.zero
        let inputs = history["vin"].arrayValue.filter { $0["prevout"]["scriptpubkey_address"].stringValue  == btcChain.mainAddress }
        inputs.forEach { input in
            inputAmounts = inputAmounts.adding(NSDecimalNumber(value: input["prevout"]["value"].uInt64Value))
        }
        let outputs = history["vout"].arrayValue.filter { $0["scriptpubkey_address"].stringValue  == btcChain.mainAddress }
        outputs.forEach { output in
            outputAmount = outputAmount.adding(NSDecimalNumber(value: output["value"].uInt64Value))
        }
        
        if (inputs.count > 0) {
            title = NSLocalizedString("tx_send", comment: "")
            displayAmount = inputAmounts.subtracting(outputAmount).subtracting(NSDecimalNumber(value: history["fee"].intValue)).multiplying(byPowerOf10: -8, withBehavior: handler8Down)
        } else {
            title = NSLocalizedString("tx_receive", comment: "")
            displayAmount = outputAmount.multiplying(byPowerOf10: -8, withBehavior: handler8Down)
        }
        
        denomLabel.text = btcChain.coinSymbol
        amountLabel.attributedText = WDP.dpAmount(displayAmount.stringValue, amountLabel!.font, 8)
        amountLabel.isHidden = false
        denomLabel.isHidden = false
        
        msgsTitleLabel.text = title
        hashLabel.text = history["txid"].stringValue
    }

    func bindEvmClassHistory(_ account: BaseAccount, _ chain: BaseChain, _ history: JSON) {
        if history["txStatus"].stringValue == "success" {
            successImg.image = UIImage(named: "iconSuccess")
        } else {
            successImg.image = UIImage(named: "iconFail")
        }
        
        var title = ""
        if (!history.isEmpty) {
            let sender = history["from"].first?.1["address"].stringValue
            if (sender == chain.evmAddress || sender == chain.bechAddress) {
                title = NSLocalizedString("tx_send", comment: "")
            } else {
                title = NSLocalizedString("tx_receive", comment: "")
            }
        }
        
        msgsTitleLabel.text = title
        msgsTitleLabel.adjustsFontSizeToFitWidth = true
        
        hashLabel.text = history["txHash"].stringValue
        timeLabel.text = WDP.dpTime(history["txTime"].intValue)
        blockLabel.isHidden = true
        
        let contractAddress = history["tokenAddress"].stringValue
        
        if history["amount"].stringValue != "0" && !history["amount"].stringValue.isEmpty {
            if contractAddress.isEmpty {
                amountLabel.isHidden = false
                denomLabel.isHidden = false

                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(history["amount"].stringValue, amountLabel!.font)
                
            } else if let _ = chain.getEvmfetcher()?.mintscanErc20Tokens.first(where: { $0.contract?.lowercased() == contractAddress.lowercased() }) {
                amountLabel.isHidden = false
                denomLabel.isHidden = false

                denomLabel.text = history["symbol"].stringValue
                amountLabel.attributedText = WDP.dpAmount(history["amount"].stringValue, amountLabel!.font)
                denomLabel.textColor = .color01
                
            }
        }
    }

}
