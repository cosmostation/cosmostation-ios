//
//  AllChainCompoundingStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class AllChainCompoundingStartVC: BaseVC, PinDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!
    @IBOutlet weak var compoundingMsgLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var compoundingBtn: BaseButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var lodingView: UIView!
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var compoundableRewards = [ClaimAllModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        lottieView.isHidden = false
        lottieView.animation = LottieAnimation.named("loading")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.3
        lottieView.play()
        
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClaimAllChainCell", bundle: nil), forCellReuseIdentifier: "ClaimAllChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onInitView()
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_compoundable_chains", comment: "")
        compoundingMsgLabel.text = NSLocalizedString("msg_compoundable_detail", comment: "")
        compoundingBtn.setTitle(NSLocalizedString("str_compounding_all", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        compoundableRewards.removeAll()
        onInitView()
    }
    
    func onInitView() {
        if (baseAccount.getDpChains().filter { $0.fetchState == .Busy }.count == 0) {
            baseAccount.getDpChains().filter { $0.isTestnet == false && $0.supportCosmos && !($0 is ChainNeutron) }.forEach { chain in
                if let cosmosFetcher = chain.getCosmosfetcher(),
                   let txFee = chain.getInitPayableFee(),
                   cosmosFetcher.rewardAddress == chain.bechAddress {
                    let compoundable = cosmosFetcher.compoundableRewards()
                    if (compoundable.count > 0) {
                        compoundableRewards.append(ClaimAllModel.init(chain, compoundable))
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
        cntLabel.text = String(compoundableRewards.count)
        lodingView.isHidden = true
        if (compoundableRewards.count == 0) {
            compoundingMsgLabel.isHidden = true
            emptyView.isHidden = false
            compoundingBtn.isHidden = true
            cntLabel.isHidden = true
        } else {
            compoundingMsgLabel.isHidden = false
            emptyView.isHidden = true
            compoundingBtn.isHidden = false
            cntLabel.isHidden = false
        }
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func onSimul() {
        for i in 0..<compoundableRewards.count {
            Task {
                if (compoundableRewards[i].cosmosChain.isSimulable() == false) {
                    compoundableRewards[i].txFee = compoundableRewards[i].cosmosChain.getInitPayableFee()
                    
                } else {
                    let chain = compoundableRewards[i].cosmosChain!
                    let rewards = compoundableRewards[i].rewards
                    var txFee = chain.getInitPayableFee()!
                    if let toGas = try await simulateCompoundingTx(chain, rewards) {
                        txFee.gasLimit = UInt64(Double(toGas) * chain.getSimulatedGasMultiply())
                        if let gasRate = chain.getBaseFeeInfo().FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                            let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                            let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                            txFee.amount[0].amount = feeCoinAmount!.stringValue
                        }
                    }
                    compoundableRewards[i].txFee = txFee
                }
                compoundableRewards[i].isBusy = false
                
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                    if (self.compoundableRewards.filter { $0.txFee == nil }.count == 0) {
                        self.compoundingBtn.isEnabled = true
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
            for i in 0..<compoundableRewards.count {
                compoundableRewards[i].isBusy = true
            }
            tableView.reloadData()
            compoundingBtn.isHidden = true
            confirmBtn.isHidden = false
            
            for i in 0..<compoundableRewards.count {
                Task {
                    let chain = compoundableRewards[i].cosmosChain!
                    let rewards = compoundableRewards[i].rewards
                    let txFee = (compoundableRewards[i].txFee == nil) ? chain.getInitPayableFee() : compoundableRewards[i].txFee
                    if let response = try await broadcastCompoundingTx(chain, rewards, txFee!) {
                        self.checkTx(chain, i, response)
                    }
                }
            }
        }
    }
    
    func checkTx(_ chain: BaseChain, _ position: Int, _ txResponse: Cosmos_Base_Abci_V1beta1_TxResponse) {
        Task {
            do {
                let result = try await chain.getCosmosfetcher()!.fetchTx(txResponse.txhash)
                compoundableRewards[position].txResponse = result
                compoundableRewards[position].isBusy = false
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .none)
                    self.tableView.endUpdates()
                    
                    if (self.compoundableRewards.filter { $0.txResponse == nil }.count == 0) {
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


extension AllChainCompoundingStartVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return compoundableRewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ClaimAllChainCell") as! ClaimAllChainCell
        cell.onBindCompounding(compoundableRewards[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (compoundableRewards[indexPath.row].isBusy == true) { return nil }
        if (compoundableRewards[indexPath.row].txResponse != nil) { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Skip") { action, view, completion in
            self.compoundableRewards.remove(at: indexPath.row)
            self.onUpdateView()
            completion(true)
        }
        deleteAction.backgroundColor = .colorBg
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}


extension AllChainCompoundingStartVC {
    
    func simulateCompoundingTx(_ chain: BaseChain, _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) async throws -> UInt64? {
        let msgs = onBindCompoundingMsg(chain, claimableRewards)
        if let cosmosFetcher = chain.getCosmosfetcher(),
           let simulReq = try await Signer.genSimul(chain, msgs, "", chain.getInitPayableFee()!, nil) {
            return try await cosmosFetcher.simulateTx(simulReq)
        }
        return nil
    }
    
    func onBindCompoundingMsg(_ selectedChain: BaseChain, _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) -> [Google_Protobuf_Any] {
        if selectedChain is ChainInitia {
            return Signer.genInitiaCompoundingMsg(selectedChain.bechAddress!, claimableRewards, selectedChain.stakingAssetDenom())
            
        } else if selectedChain is ChainZenrock {
            return Signer.genZenrockCompoundingMsg(selectedChain.bechAddress!, claimableRewards, selectedChain.stakingAssetDenom())
            
        } else if selectedChain is ChainBabylon {
            return Signer.genBabylonCompoundingMsg(selectedChain.bechAddress!, claimableRewards, selectedChain.stakingAssetDenom())
            
        } else {
            return Signer.genCompoundingMsg(selectedChain.bechAddress!, claimableRewards, selectedChain.stakingAssetDenom())
        }
    }

    
    func broadcastCompoundingTx(_ chain: BaseChain, _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward],
                                _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip? = nil) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let msgs = Signer.genCompoundingMsg(chain.bechAddress!, claimableRewards, chain.stakingAssetDenom())
        if let cosmosFetcher = chain.getCosmosfetcher(),
           let broadReq = try await Signer.genTx(chain, msgs, "", fee, tip) {
            return try await cosmosFetcher.broadcastTx(broadReq)
        }
        return nil
    }
}
