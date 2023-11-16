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
import GRPC
import NIO
import SwiftProtobuf

class NeutronVote: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectView: DropDownView!
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
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var toSingleProposals = [JSON]()
    var toMultiProposals = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("toSingleProposals ", toSingleProposals.count)
//        print("toMultiProposals ", toMultiProposals.count)
//        print("toSingleProposals ", toSingleProposals)
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        feeInfos = selectedChain.getFeeInfos()
        feeSegments.removeAllSegments()
        for i in 0..<feeInfos.count {
            feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
        }
        selectedFeeInfo = selectedChain.getFeeBasePosition()
        feeSegments.selectedSegmentIndex = selectedFeeInfo
        txFee = selectedChain.getInitPayableFee()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "NeutronSingleVoteCell", bundle: nil), forCellReuseIdentifier: "NeutronSingleVoteCell")
        tableView.register(UINib(nibName: "NeutronMultiVoteCell", bundle: nil), forCellReuseIdentifier: "NeutronMultiVoteCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_vote", comment: ""), for: .normal)
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet, 260)
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
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeeInfo = sender.selectedSegmentIndex
        txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, txFee.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.feeDatas = feeInfos[selectedFeeInfo].FeeDatas
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectFeeCoin
        onStartSheet(baseSheet, 240)
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        if let toGas = simul?.gasInfo.gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.gasMultiply())
            if let gasRate = feeInfos[selectedFeeInfo].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeCoinAmount!.stringValue
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
        view.isUserInteractionEnabled = false
        voteBtn.isEnabled = false
        loadingView.isHidden = false
        
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                do {
                    let simul = try await simulateTx(channel, auth!)
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(simul)
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
    }
    
    func onBindWasmMsg() -> [Cosmwasm_Wasm_V1_MsgExecuteContract] {
        var result = [Cosmwasm_Wasm_V1_MsgExecuteContract]()
        toSingleProposals.forEach { single in
            let jsonMsg: JSON = ["vote" : ["proposal_id" : single["id"].int64Value, "vote" : single["myVote"].stringValue]]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let msg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress
                $0.contract = selectedChain.daosList[0]["proposal_modules"].arrayValue[0]["address"].stringValue
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
            }
            result.append(msg)
        }
        toMultiProposals.forEach { multi in
            let jsonMsg: JSON = ["vote" : ["proposal_id" : multi["id"].int64Value, "vote" : ["option_id" : multi["myVote"].intValue ]]]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let msg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress
                $0.contract = selectedChain.daosList[0]["proposal_modules"].arrayValue[1]["address"].stringValue
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
            }
            result.append(msg)
        }
        return result
    }
}


extension NeutronVote: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return toSingleProposals.count
        }
        return toMultiProposals.count
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
            
        } else {
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
        }
    }
    
}


extension NeutronVote: MemoDelegate, BaseSheetDelegate, PinDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeCoin) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, selectedDenom)
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
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
                   let response = try await broadcastTx(channel, auth!) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        
                        let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                        txResult.selectedChain = self.selectedChain
                        txResult.broadcastTxResponse = response
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
            }
        }
    }
    
}


extension NeutronVote {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func simulateTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genWasmSimul(auth, onBindWasmMsg(), txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, onBindWasmMsg(), txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}
