//
//  AllChainVoteStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/14/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import AlamofireImage
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class AllChainVoteStartVC: BaseVC, PinDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var filterMsgLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var lodingView: UIView!
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var isShowAll = false
    var allLiveInfo = [VoteAllModel]()
    var toDisplayInfos = [VoteAllModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        titleLabel.isHidden = true
        filterMsgLabel.isHidden = true
        voteBtn.isHidden = true
        
        lottieView.isHidden = false
        lottieView.animation = LottieAnimation.named("loading")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.3
        lottieView.play()
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "VoteAllChainCell", bundle: nil), forCellReuseIdentifier: "VoteAllChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        voteBtn.isEnabled = false
        onInitView()
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_hide_done_proposal", comment: "")
        filterMsgLabel.text = NSLocalizedString("msg_vote_all_detail", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_vote_all", comment: ""), for: .normal)
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
    
    @IBAction func onClickFilter(_ sender: UIButton) {
        if (toDisplayInfos.filter { $0.isBusy == true }.count > 0) { return }
        if (toDisplayInfos.filter { $0.txResponse != nil }.count > 0) { return }
        isShowAll = !isShowAll
        if (isShowAll) {
            filterBtn.setImage(UIImage(named: "iconVoteAllShowAll"), for: .normal)
            titleLabel.text = NSLocalizedString("str_show_all_proposal", comment: "")
        }  else {
            filterBtn.setImage(UIImage(named: "iconVoteAllFiltered"), for: .normal)
            titleLabel.text = NSLocalizedString("str_hide_done_proposal", comment: "")
        }
        onUpdateView()
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        onInitView()
    }
    
    func onInitView() {
        if (baseAccount.getDpChains().filter { $0.fetchState == .Busy }.count == 0) {
            var stakedChains = [BaseChain]()
            baseAccount.getDpChains().filter { $0.isTestnet == false && $0.isDefault == true && $0.tag != "finschia438" }.forEach { chain in
                if let cosmosFetcher = chain.getCosmosfetcher() {
                    let delegated = cosmosFetcher.delegationAmountSum()
                    let voteThreshold = chain.voteThreshold()
                    let txFee = chain.getInitPayableFee()
                    if (delegated.compare(voteThreshold).rawValue > 0 && txFee != nil) {
                        stakedChains.append(chain)
                    }
                }
            }
            allLiveInfo.removeAll()
            toDisplayInfos.removeAll()
            onFetchProposalInfos(stakedChains)
        }
    }
    
    func onUpdateView() {
        titleLabel.isHidden = false
        filterMsgLabel.isHidden = false
        voteBtn.isEnabled = false
        emptyView.isHidden = true
        filterBtn.isHidden = false
        lodingView.isHidden = true
        
        self.allLiveInfo.sort {
            if ($0.basechain.tag == "cosmos118") { return true }
            if ($1.basechain.tag == "cosmos118") { return false }
            if ($0.basechain.tag == "govgen118") { return true }
            if ($1.basechain.tag == "govgen118") { return false }
            return false
        }
        
        toDisplayInfos.removeAll()
        if (isShowAll) {
            toDisplayInfos = allLiveInfo.map { $0 }
        } else {
            allLiveInfo.forEach { info in
                var filteredProposal = [MintscanProposal]()
                let proposals = info.msProposals
                let myVotes = info.msMyVotes
                proposals.forEach { proposal in
                    if (myVotes.filter({ $0.proposal_id == proposal.id }).count ==  0) {
                        filteredProposal.append(proposal)
                    }
                }
                if (filteredProposal.count > 0) {
                    toDisplayInfos.append(VoteAllModel.init(info.basechain, filteredProposal, myVotes))
                }
            }
        }
        
        if (toDisplayInfos.count == 0) {
            emptyView.isHidden = false
        } else {
            voteBtn.isHidden = false
        }
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func onUpdateProgress(_ progress: Int, _ allCnt: Int) {
        DispatchQueue.main.async(execute: {
            self.progressLabel.text = "Checked " + String(progress) +  "/" +  String(allCnt)
        })
    }
    
    func onSimul(_ section: Int) {
        if (toDisplayInfos[section].msProposals.filter { $0.toVoteOption == nil }.count > 0) {
            return
        }
        
        Task {
            toDisplayInfos[section].onClear()
            let chain = toDisplayInfos[section].basechain!
            var txFee = chain.getInitPayableFee()!
            var tempToVotes = [Cosmos_Gov_V1beta1_MsgVote]()
            toDisplayInfos[section].msProposals.forEach { proposal in
                let voteMsg = Cosmos_Gov_V1beta1_MsgVote.with {
                    $0.voter = chain.bechAddress!
                    $0.proposalID = proposal.id!
                    $0.option = proposal.toVoteOption!
                }
                tempToVotes.append(voteMsg)
            }
            
            toDisplayInfos[section].isBusy = true
            onSectionReload(section)
        
            if let toGas = try await simulateVoteTx(chain, tempToVotes) {
                txFee.gasLimit = UInt64(Double(toGas) * chain.gasMultiply())
                if let gasRate = chain.getBaseFeeInfo().FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee.amount[0].amount = feeCoinAmount!.stringValue
                }
                toDisplayInfos[section].isBusy = false
                toDisplayInfos[section].toVotes = tempToVotes
                toDisplayInfos[section].txFee = txFee
            }
            
            onSectionReload(section)
            DispatchQueue.main.async {
                if (self.toDisplayInfos.filter { $0.toVotes == [] || $0.txFee == nil }.count == 0) {
                    self.voteBtn.isEnabled = true
                }
            }
        }
    }
    
    func onSectionReload(_ section: Int) {
        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.reloadSections([section], with: .none)
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    @IBAction func onClickVote(_ sender: BaseButton) {
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
            voteBtn.isEnabled = false
            confirmBtn.isEnabled = false
            voteBtn.isHidden = true
            confirmBtn.isHidden = false
            for i in toDisplayInfos.indices {
                toDisplayInfos[i].isBusy = true
            }
            tableView.reloadData()
            
            for i in 0..<toDisplayInfos.count {
                Task {
                    let chain = toDisplayInfos[i].basechain!
                    let toVotes = toDisplayInfos[i].toVotes
                    let txFee = toDisplayInfos[i].txFee!
                    if let response = try await broadcastVoteTx(chain, toVotes, txFee) {
                        self.checkTx(chain, i, response)
                    }
                }
            }
        }
    }
    
    func checkTx(_ chain: BaseChain, _ position: Int, _ txResponse: Cosmos_Base_Abci_V1beta1_TxResponse) {
        Task {
            do {
                let result = try await chain.getCosmosfetcher()!.fetchCosmosTx(txResponse.txhash)
                toDisplayInfos[position].isBusy = false
                toDisplayInfos[position].txResponse = result
                DispatchQueue.main.async {
                    self.onSectionReload(position)
                    DispatchQueue.main.async {
                        if (self.toDisplayInfos.filter { $0.txResponse == nil }.count == 0) {
                            self.confirmBtn.isEnabled = true
                        }
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

extension AllChainVoteStartVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return toDisplayInfos.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = VoteAllChainHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let model = toDisplayInfos[section]
        let chain = model.basechain!
        view.chainImg.image = UIImage.init(named: chain.logo1)
        view.titleLabel.text = chain.name.uppercased()
        view.cntLabel.text = String(model.msProposals.count)
        
        
        if (model.isBusy) {
            view.pendingView.isHidden = false
            
        } else {
            if (model.txResponse != nil) {
                view.stateImg.isHidden = false
                
            } else if let txFee = model.txFee,
               let msAsset = BaseData.instance.getAsset(chain.apiName, txFee.amount[0].denom) {
                WDP.dpCoin(msAsset, txFee.amount[0], nil, view.feeDenomLabel, view.feeAmountLabel, msAsset.decimals)
                view.feeTitle.isHidden = false
                view.feeAmountLabel.isHidden = false
                view.feeDenomLabel.isHidden = false
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDisplayInfos[section].msProposals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"VoteAllChainCell") as! VoteAllChainCell
        let liveProposal = toDisplayInfos[indexPath.section].msProposals[indexPath.row]
        let myVotedList = toDisplayInfos[indexPath.section].msMyVotes
        cell.onBindVote(liveProposal, myVotedList)
        cell.actionToggle = { tag in
            let voteOption = Cosmos_Gov_V1beta1_VoteOption.init(rawValue: tag)
            if (voteOption == self.toDisplayInfos[indexPath.section].msProposals[indexPath.row].toVoteOption) { return }
            if (self.toDisplayInfos[indexPath.section].isBusy) { return }
            if (self.toDisplayInfos[indexPath.section].txResponse != nil) { return }
            self.toDisplayInfos[indexPath.section].msProposals[indexPath.row].toVoteOption = voteOption
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                self.onSimul(indexPath.section)
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (toDisplayInfos[indexPath.section].isBusy) { return }
        if (toDisplayInfos[indexPath.section].txResponse != nil) { return }
        if let chain = toDisplayInfos[indexPath.section].basechain,
           let proposalId = toDisplayInfos[indexPath.section].msProposals[indexPath.row].id {
            guard let url = chain.getExplorerProposal(proposalId) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Skip") { action, view, completion in
            if (self.toDisplayInfos[indexPath.section].isBusy == true) { return }
            if (self.toDisplayInfos[indexPath.section].txResponse != nil) { return }
            if (self.toDisplayInfos[indexPath.section].msProposals.count > 1) {
                self.toDisplayInfos[indexPath.section].msProposals.remove(at: indexPath.row)
                self.onSectionReload(indexPath.section)
                self.onSimul(indexPath.section)
                
            } else {
                self.toDisplayInfos.remove(at: indexPath.section)
                if (self.toDisplayInfos.count == 0) {
                    self.emptyView.isHidden = false
                    self.voteBtn.isEnabled = false
                    self.voteBtn.isHidden = true
                } else {
                    DispatchQueue.main.async {
                        if (self.toDisplayInfos.filter { $0.toVotes == [] || $0.txFee == nil }.count == 0) {
                            self.voteBtn.isEnabled = true
                        }
                    }
                }
                self.tableView.reloadData()
            }
            completion(true)
        }
        deleteAction.backgroundColor = .colorBg
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension AllChainVoteStartVC {
    
    func onFetchProposalInfos(_ stakedChains : [BaseChain]) {
        Task(priority: .high) {
            var progress = 0
            await stakedChains.concurrentForEach { chain in
                var toShowProposals = [MintscanProposal]()
                if let proposals = try? await AF.request(BaseNetWork.msProposals(chain), method: .get).serializingDecodable([JSON].self).value {
                    proposals.forEach { proposal in
                        let msProposal = MintscanProposal(proposal)
                        if (msProposal.isVotingPeriod() && !msProposal.isScam()) {
                            toShowProposals.append(msProposal)
                        }
                    }
                }
                
                if (!toShowProposals.isEmpty) {
                    let address = chain.bechAddress!
                    var myVotes = [MintscanMyVotes]()
                    if let votes = try? await AF.request(BaseNetWork.msMyVoteHistory(chain, address), method: .get).serializingDecodable(JSON.self).value {
                        votes["votes"].arrayValue.forEach { vote in
                            myVotes.append(MintscanMyVotes(vote))
                        }
                    }
                    self.allLiveInfo.append(VoteAllModel.init(chain, toShowProposals,myVotes))
                }
                progress = progress + 1
                self.onUpdateProgress(progress, stakedChains.count)
            }
            
            DispatchQueue.main.async(execute: {
                self.onUpdateView()
            })
        }
    }
}

extension AllChainVoteStartVC {
    
    func simulateVoteTx(_ chain: BaseChain, _ msgVotes: [Cosmos_Gov_V1beta1_MsgVote]) async throws -> UInt64? {
        let msgs = Signer.genVoteMsg(msgVotes)
        if let cosmosFetcher = chain.getCosmosfetcher(),
           let simulReq = try await Signer.genSimul(chain, msgs, "", chain.getInitPayableFee()!, nil) {
            return try await cosmosFetcher.simulCosmosTx(simulReq)
        }
        return nil
    }
    
    func broadcastVoteTx(_ chain: BaseChain, _ msgVotes: [Cosmos_Gov_V1beta1_MsgVote], _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip? = nil) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let msgs = Signer.genVoteMsg(msgVotes)
        if let cosmosFetcher = chain.getCosmosfetcher(),
           let broadReq = try await Signer.genTx(chain, msgs, "", fee, tip) {
            return try await cosmosFetcher.broadCastCosmosTx(broadReq)
        }
        return nil
    }
}

struct VoteAllModel {
    
    var basechain: BaseChain!
    var msProposals = [MintscanProposal]()
    var msMyVotes = [MintscanMyVotes]()
    var toVotes = [Cosmos_Gov_V1beta1_MsgVote]()
    var txFee: Cosmos_Tx_V1beta1_Fee?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var isBusy = false
    
    init(_ basechain: BaseChain!,  _ msProposals: [MintscanProposal], _ msMyVotes: [MintscanMyVotes]) {
        self.basechain = basechain
        self.msProposals = msProposals
        self.msMyVotes = msMyVotes
    }
    
    mutating func onClear() {
        self.toVotes = []
        self.txFee = nil
        self.txResponse = nil
        self.isBusy = true
    }
}
