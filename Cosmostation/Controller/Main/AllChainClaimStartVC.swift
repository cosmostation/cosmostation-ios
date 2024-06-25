//
//  AllChainClaimStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class AllChainClaimStartVC: BaseVC, PinDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!
    @IBOutlet weak var claimMsgLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var claimBtn: BaseButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var lodingView: UIView!
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var valueableRewards = [ClaimAllModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        lottieView.animation = LottieAnimation.named("loading")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.3
        lottieView.play()
        
        cntLabel.isHidden = true
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClaimAllChainCell", bundle: nil), forCellReuseIdentifier: "ClaimAllChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        claimBtn.isEnabled = false
        confirmBtn.isEnabled = false
        confirmBtn.isHidden = true
        onInitView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("title_claimable_chains", comment: "")
        claimMsgLabel.text = NSLocalizedString("msg_claim_all_detail", comment: "")
        claimBtn.setTitle(NSLocalizedString("str_claim_all", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        valueableRewards.removeAll()
        onInitView()
    }
    
    func onInitView() {
        if (baseAccount.getDpChains().filter { $0.fetchState == .Busy }.count == 0) {
            baseAccount.getDpChains().filter { $0.isTestnet == false && $0.supportCosmosGrpc }.forEach { chain in
                if let grpcFetcher = chain.grpcFetcher,
                   let txFee = chain.getInitPayableFee() {
                    let valueableReward = grpcFetcher.valueableRewards()
                    if (valueableReward.count > 0) {
                        valueableRewards.append(ClaimAllModel.init(chain, valueableReward))
                    }
                }
            }
            onUpdateView()
            onSimul()
            
        } else {
            DispatchQueue.main.async(execute: {
                let totalCnt = self.baseAccount.getDpChains().count
                let checkedCnt = self.baseAccount.getDpChains().filter { $0.fetchState != .Busy }.count
                self.progressLabel.text = "Checked " + String(checkedCnt) +  "/" +  String(totalCnt)
            })
        }
    }
    
    func onUpdateView() {
        cntLabel.text = String(valueableRewards.count)
        lodingView.isHidden = true
        if (valueableRewards.count == 0) {
            emptyView.isHidden = false
            claimBtn.isHidden = true
            
        } else {
            cntLabel.isHidden = false
        }
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func onSimul() {
        for i in 0..<valueableRewards.count {
            Task {
                if (valueableRewards[i].cosmosChain.isGasSimulable() == false) {
                    valueableRewards[i].txFee = valueableRewards[i].cosmosChain.getInitPayableFee()
                    
                } else {
                    let chain = valueableRewards[i].cosmosChain!
                    let rewards = valueableRewards[i].rewards
                    var txFee = chain.getInitPayableFee()!
                    if let simul = try await simulateClaimTx(chain, rewards) {
                        let toGas = simul.gasInfo.gasUsed
                        txFee.gasLimit = UInt64(Double(toGas) * chain.gasMultiply())
                        if let gasRate = chain.getBaseFeeInfo().FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                            let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                            let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                            txFee.amount[0].amount = feeCoinAmount!.stringValue
                        }
                    }
                    valueableRewards[i].txFee = txFee
                }
                valueableRewards[i].isBusy = false
                
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                    if (self.valueableRewards.filter { $0.txFee == nil }.count == 0) {
                        self.claimBtn.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func onClickClaim(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        self.baseAccount.getDpChains().forEach { $0.fetchState = .Idle }
        self.baseAccount.fetchDpChains()
        self.dismiss(animated: true)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (request == .ForDataCheck && result == .success) {
            for i in 0..<valueableRewards.count {
                valueableRewards[i].isBusy = true
            }
            tableView.reloadData()
            claimBtn.isHidden = true
            confirmBtn.isHidden = false
            
            for i in 0..<valueableRewards.count {
                Task {
                    let chain = valueableRewards[i].cosmosChain!
                    let rewards = valueableRewards[i].rewards
                    let txFee = (valueableRewards[i].txFee == nil) ? chain.getInitPayableFee() : valueableRewards[i].txFee
                    if let response = try await broadcastClaimTx(chain, rewards, txFee!) {
                        self.checkTx(chain, i, response)
                    }
                }
            }
        }
    }
    
    func checkTx(_ chain: BaseChain, _ position: Int, _ txResponse: Cosmos_Base_Abci_V1beta1_TxResponse) {
        Task {
            do {
                let result = try await chain.getGrpcfetcher()!.fetchTx(txResponse.txhash)
                valueableRewards[position].txResponse = result
                valueableRewards[position].isBusy = false
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .none)
                    self.tableView.endUpdates()
                    
                    if (self.valueableRewards.filter { $0.txResponse == nil }.count == 0) {
                        self.confirmBtn.isEnabled = true
                    }
                }
                
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
                    self.checkTx(chain, position, txResponse)
                });
            }
        }
    }
}

extension AllChainClaimStartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueableRewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ClaimAllChainCell") as! ClaimAllChainCell
        cell.onBindRewards(valueableRewards[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (valueableRewards[indexPath.row].isBusy == true) { return nil }
        if (valueableRewards[indexPath.row].txResponse != nil) { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Skip") { action, view, completion in
            self.valueableRewards.remove(at: indexPath.row)
            self.onUpdateView()
            completion(true)
        }
        deleteAction.backgroundColor = .colorBg
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}


extension AllChainClaimStartVC {
    
    func simulateClaimTx(_ chain: BaseChain, _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        if let grpcFetcher = chain.getGrpcfetcher(),
           let account = try await grpcFetcher.fetchAuth() {
            let simulReq = Signer.genClaimRewardsSimul(account, claimableRewards, chain.getInitPayableFee()!, "", chain)
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: grpcFetcher.getClient()).simulate(simulReq, callOptions: grpcFetcher.getCallOptions()).response.get()
        }
        return nil
    }
    
    func broadcastClaimTx(_ chain: BaseChain, _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward], _ fee: Cosmos_Tx_V1beta1_Fee) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        if let grpcFetcher = chain.getGrpcfetcher(),
           let account = try await grpcFetcher.fetchAuth() {
            let broadReq = Signer.genClaimRewardsTx(account, claimableRewards, fee, "", chain)
            return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: grpcFetcher.getClient()).broadcastTx(broadReq, callOptions: grpcFetcher.getCallOptions()).response.get().txResponse
        }
        return nil
    }
}

struct ClaimAllModel {
    
    var cosmosChain: BaseChain!
    var rewards = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
    var txFee: Cosmos_Tx_V1beta1_Fee?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var isBusy = true
    
    init(_ cosmosChain: BaseChain!, _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) {
        self.cosmosChain = cosmosChain
        self.rewards = rewards
    }
}
