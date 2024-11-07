//
//  NeutronVote.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import SwiftProtobuf

class NeutronVote: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: ChainNeutron!
    var neutronFetcher: NeutronFetcher!
    var feeInfos = [FeeInfo]()
    var txFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var txTip: Cosmos_Tx_V1beta1_Tip?
    var selectedFeePosition = 0
    var txMemo = ""
    
    var toSingleProposals = [JSON]()
    var toMultiProposals = [JSON]()
    var toOverrruleProposals = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        neutronFetcher = selectedChain.getNeutronFetcher()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "NeutronSingleVoteCell", bundle: nil), forCellReuseIdentifier: "NeutronSingleVoteCell")
        tableView.register(UINib(nibName: "NeutronMultiVoteCell", bundle: nil), forCellReuseIdentifier: "NeutronMultiVoteCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        
        Task {
            await neutronFetcher.updateBaseFee()
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.oninitFeeView()
            }
        }
    }
    
    override func setLocalizedString() {
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_vote", comment: ""), for: .normal)
    }
    
    func oninitFeeView() {
        if (neutronFetcher.cosmosBaseFees.count > 0) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
            feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
            feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
            feeSegments.selectedSegmentIndex = selectedFeePosition
            
            let baseFee = neutronFetcher.cosmosBaseFees[0]
            let gasAmount: NSDecimalNumber = selectedChain.getInitGasLimit()
            let feeDenom = baseFee.denom
            let feeAmount = baseFee.getdAmount().multiplying(by: gasAmount, withBehavior: handler0Down)
            txFee.gasLimit = gasAmount.uint64Value
            txFee.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount)]
            
        } else {
            feeInfos = selectedChain.getFeeInfos()
            feeSegments.removeAllSegments()
            for i in 0..<feeInfos.count {
                feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
            }
            selectedFeePosition = selectedChain.getBaseFeePosition()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            txFee = selectedChain.getInitPayableFee()!
        }
        onUpdateFeeView()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.sheetDelegate = self
        if (neutronFetcher.cosmosBaseFees.count > 0) {
            baseSheet.baseFeesDatas = neutronFetcher.cosmosBaseFees
            baseSheet.sheetType = .SelectBaseFeeDenom
        } else {
            baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetType = .SelectFeeDenom
        }
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (neutronFetcher.cosmosBaseFees.count > 0) {
            if let baseFee = neutronFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeAmount.stringValue
                txFee = Signer.setFee(selectedFeePosition, txFee)
            }

        } else {
            txFee = selectedChain.getUserSelectedFee(selectedFeePosition, txFee.amount[0].denom)
        }
        onUpdateFeeView()
        onSimul()
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            
            let totalFeeAmount = NSDecimalNumber(string: txFee.amount[0].amount)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        onStartSheet(memoSheet, 260, 0.6)
    }
    
    func onUpdateMemoView(_ memo: String) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.isHidden = true
            memoHintLabel.isHidden = false
        } else {
            memoLabel.text = txMemo
            memoLabel.isHidden = false
            memoHintLabel.isHidden = true
        }
        onSimul()
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        if let toGas = gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.getSimulatedGasMultiply())
            if (neutronFetcher.cosmosBaseFees.count > 0) {
                if let baseFee = neutronFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                    let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee.amount[0].amount = feeAmount.stringValue
                    txFee = Signer.setFee(selectedFeePosition, txFee)
                }
                
            } else {
                if let gasRate = feeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                    let feeAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee.amount[0].amount = feeAmount!.stringValue
                }
            }
        }
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        voteBtn.isEnabled = true
    }
    
    @IBAction func onClickVote(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toSingleProposals.filter { $0["myVote"].string == nil }.count > 0) { return }
        if (toMultiProposals.filter { $0["myVote"].int == nil }.count > 0) { return }
        if (toOverrruleProposals.filter { $0["myVote"].string == nil }.count > 0) { return }
        view.isUserInteractionEnabled = false
        voteBtn.isEnabled = false
        loadingView.isHidden = false
        
        Task {
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindWasmMsg(), txMemo, txFee, nil),
                   let simulRes = try await neutronFetcher.simulateTx(simulReq) {
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(simulRes)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.loadingView.isHidden = true
                    self.onShowToast("Error : " + "\n" + "\(error)")
                    return
                }
            }
        }
    }
    
    func onBindWasmMsg() -> [Google_Protobuf_Any] {
        var wasmMsgs = [Cosmwasm_Wasm_V1_MsgExecuteContract]()
        toSingleProposals.forEach { single in
            let jsonMsg: JSON = ["vote" : ["proposal_id" : single["id"].int64Value, "vote" : single["myVote"].stringValue]]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let msg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress!
                $0.contract = neutronFetcher.daosList?[0]["proposal_modules"].arrayValue[0]["address"].stringValue ?? ""
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
            }
            wasmMsgs.append(msg)
        }
        toMultiProposals.forEach { multi in
            let jsonMsg: JSON = ["vote" : ["proposal_id" : multi["id"].int64Value, "vote" : ["option_id" : multi["myVote"].intValue ]]]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let msg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress!
                $0.contract = neutronFetcher.daosList?[0]["proposal_modules"].arrayValue[1]["address"].stringValue ?? ""
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
            }
            wasmMsgs.append(msg)
        }
        toOverrruleProposals.forEach { overrule in
            let jsonMsg: JSON = ["vote" : ["proposal_id" : overrule["id"].int64Value, "vote" : overrule["myVote"].stringValue]]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let msg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress!
                $0.contract = neutronFetcher.daosList?[0]["proposal_modules"].arrayValue[2]["address"].stringValue ?? ""
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
            }
            wasmMsgs.append(msg)
        }
        return Signer.genWasmMsg(wasmMsgs)
    }
}


extension NeutronVote: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return toSingleProposals.count
        } else if (section == 1) {
            return toMultiProposals.count
        }
        return toOverrruleProposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NeutronSingleVoteCell") as! NeutronSingleVoteCell
            cell.onBindsingleVote(toSingleProposals[indexPath.row])
            cell.actionToggle = { tag in
                if (tag == 0) {
                    self.toSingleProposals[indexPath.row]["myVote"] = "yes"
                } else if (tag == 1) {
                    self.toSingleProposals[indexPath.row]["myVote"] = "no"
                } else if (tag == 2) {
                    self.toSingleProposals[indexPath.row]["myVote"] = "abstain"
                } else {
                    self.toSingleProposals[indexPath.row].dictionaryObject?.removeValue(forKey: "myVote")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.onSimul()
                })
            }
            return cell
            
        } else if (indexPath.section == 1)  {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NeutronMultiVoteCell") as! NeutronMultiVoteCell
            cell.onBindmultiVote(toMultiProposals[indexPath.row])
            cell.actionToggle = { tag in
                if (tag == 0) {
                    self.toMultiProposals[indexPath.row]["myVote"] = 0
                } else if (tag == 1) {
                    self.toMultiProposals[indexPath.row]["myVote"] = 1
                } else if (tag == 2) {
                    self.toMultiProposals[indexPath.row]["myVote"] = 2
                } else if (tag == 3) {
                    self.toMultiProposals[indexPath.row]["myVote"] = 3
                } else {
                    self.toMultiProposals[indexPath.row].dictionaryObject?.removeValue(forKey: "myVote")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.onSimul()
                })
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NeutronSingleVoteCell") as! NeutronSingleVoteCell
            cell.onBindsingleVote(toOverrruleProposals[indexPath.row])
            cell.actionToggle = { tag in
                if (tag == 0) {
                    self.toOverrruleProposals[indexPath.row]["myVote"] = "yes"
                } else if (tag == 1) {
                    self.toOverrruleProposals[indexPath.row]["myVote"] = "no"
                } else if (tag == 2) {
                    self.toOverrruleProposals[indexPath.row]["myVote"] = "abstain"
                } else {
                    self.toOverrruleProposals[indexPath.row].dictionaryObject?.removeValue(forKey: "myVote")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.onSimul()
                })
            }
            return cell
        }
    }
    
}


extension NeutronVote: MemoDelegate, BaseSheetDelegate, PinDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeePosition].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        } else if (sheetType == .SelectBaseFeeDenom) {
            if let index = result["index"] as? Int {
               let selectedDenom = neutronFetcher.cosmosBaseFees[index].denom
                txFee.amount[0].denom = selectedDenom
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            voteBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                do {
                    if let broadReq = try await Signer.genTx(selectedChain, onBindWasmMsg(), txMemo, txFee, nil),
                       let broadRes = try await neutronFetcher.broadcastTx(broadReq) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.broadcastTxResponse = broadRes
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }
                    
                } catch {
                    //TODO handle Error
                }
            }
        }
    }
    
}
