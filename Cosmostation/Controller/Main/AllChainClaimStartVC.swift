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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var claimBtn: BaseButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    
    var valueableRewards = [(CosmosClass, [Cosmos_Distribution_V1beta1_DelegationDelegatorReward], 
                             Cosmos_Tx_V1beta1_Fee?, Bool, Cosmos_Tx_V1beta1_GetTxResponse?)] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        cntLabel.isHidden = true
        tableView.isHidden = true
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
        claimBtn.setTitle(NSLocalizedString("str_claim_all", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        valueableRewards.removeAll()
        onInitView()
    }
    
    func onInitView() {
        if (baseAccount.getDisplayCosmosChains().filter { $0.fetched == false }.count == 0) {
            baseAccount.getDisplayCosmosChains().forEach { chain in
                let valueableReward = chain.valueableRewards()
                if (valueableReward.count > 0) {
                    valueableRewards.append((chain, valueableReward, nil, false, nil))
                }
            }
            
            cntLabel.text = String(valueableRewards.count)
            loadingView.isHidden = true
            
            if (valueableRewards.count == 0) {
                emptyView.isHidden = false
                claimBtn.isHidden = true
                
            } else {
                cntLabel.isHidden = false
                tableView.isHidden = false
                tableView.reloadData()
                
                onSimul()
            }
        }
    }
    
    func onSimul() {
        for i in 0..<valueableRewards.count {
            Task {
                if (valueableRewards[i].0.isGasSimulable() == false) {
                    valueableRewards[i].2 = valueableRewards[i].0.getInitPayableFee()
                    
                } else {
                    let chain = valueableRewards[i].0
                    let rewards = valueableRewards[i].1
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
                    valueableRewards[i].2 = txFee
                }
                
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                    
                    
                    if (self.valueableRewards.filter { $0.2 == nil }.count == 0) {
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
        self.dismiss(animated: true) {
            self.baseAccount.getDisplayCosmosChains().forEach { chain in
                chain.fetched = false
            }
            self.baseAccount.fetchDisplayCosmosChains()
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (request == .ForDataCheck && result == .success) {
            for i in 0..<valueableRewards.count {
                valueableRewards[i].3 = true
            }
            tableView.reloadData()
            claimBtn.isHidden = true
            confirmBtn.isHidden = false
            
            for i in 0..<valueableRewards.count {
                Task {
                    let chain = valueableRewards[i].0
                    let rewards = valueableRewards[i].1
                    let txFee = valueableRewards[i].2
                    
                    let channel = getConnection(chain)
                    if let auth = try await fetchAuth(channel, chain),
                       let response = try await broadcastClaimTx(chain, channel, auth, rewards, txFee!) {
                        self.checkTx(i, channel, response)
                    }
                }
            }
        }
    }
    
    func checkTx(_ position: Int, _ channel: ClientConnection, _ txResponse: Cosmos_Base_Abci_V1beta1_TxResponse) {
        Task {
            do {
                let result = try await fetchTx(channel, txResponse)
                valueableRewards[position].4 = result
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .none)
                    self.tableView.endUpdates()
                    
                    if (self.valueableRewards.filter { $0.4 == nil }.count == 0) {
                        self.confirmBtn.isEnabled = true
                    }
                }
                
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
                    self.checkTx(position, channel, txResponse)
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
        cell.onBindRewards(valueableRewards[indexPath.row].0, valueableRewards[indexPath.row].1,
                           valueableRewards[indexPath.row].2, valueableRewards[indexPath.row].3,
                           valueableRewards[indexPath.row].4)
        return cell
    }
    
}


extension AllChainClaimStartVC {
    
    func simulateClaimTx(_ chain: CosmosClass, _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let channel = getConnection(chain)
        if let auth = try await fetchAuth(channel, chain) {
            let simulTx = Signer.genClaimRewardsSimul(auth, claimableRewards, chain.getInitPayableFee()!, "", chain)
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } else {
            return nil
        }
    }
    
    func broadcastClaimTx(_ chain: CosmosClass, _ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                           _ claimableRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward], _ fee: Cosmos_Tx_V1beta1_Fee) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genClaimRewardsTx(auth, claimableRewards, fee, "", chain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
        
    }
    
    func fetchAuth(_ channel: ClientConnection, _ chain: CosmosClass) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = chain.bechAddress }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchTx(_ channel: ClientConnection, _ response: Cosmos_Base_Abci_V1beta1_TxResponse) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? {
        let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = response.txhash }
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).getTx(req, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.getGrpc().0, port: chain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}
