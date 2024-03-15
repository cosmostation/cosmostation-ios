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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var isShowAll = false
    var votableInfo = [VoteAllModel]()
    var filteredInfo = [VoteAllModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
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
        titleLabel.text = NSLocalizedString("str_voting_period", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_vote_all", comment: ""), for: .normal)
//        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
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
        isShowAll = !isShowAll
        if (isShowAll) {
            filterBtn.setImage(UIImage(named: "iconVoteAllShowAll"), for: .normal)
            onShowToast(NSLocalizedString("msg_show_all_proposals", comment: ""))
        }  else {
            filterBtn.setImage(UIImage(named: "iconVoteAllFiltered"), for: .normal)
            onShowToast(NSLocalizedString("msg_hide_voted_proposals", comment: ""))
        }
        
        for i in votableInfo.indices {
            for j in votableInfo[i].msProposals.indices {
                votableInfo[i].msProposals[j].toVoteOption = nil
            }
            votableInfo[i].onClear()
        }
        
        for i in filteredInfo.indices {
            for j in filteredInfo[i].msProposals.indices {
                filteredInfo[i].msProposals[j].toVoteOption = nil
            }
            filteredInfo[i].onClear()
        }
        voteBtn.isEnabled = false
        tableView.reloadData()
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        onInitView()
    }
    
    func onInitView() {
        if (baseAccount.getDisplayCosmosChains().filter { $0.fetched == false }.count == 0 &&
            baseAccount.getDisplayEvmChains().filter { $0.fetched == false }.count == 0) {
            
            var stakedChains = [BaseChain]()
            baseAccount.getDisplayCosmosChains().filter { $0.isDefault == true }.forEach { chain in
                let delegated = chain.delegationAmountSum()
                let voteThreshold = chain.voteThreshold()
                let txFee = chain.getInitPayableFee()
                if (delegated.compare(voteThreshold).rawValue > 0 && txFee != nil) {
                    stakedChains.append(chain)
                }
            }
            
            baseAccount.getDisplayEvmChains().filter { $0.supportCosmos == true }.forEach { chain in
                let delegated = chain.delegationAmountSum()
                let voteThreshold = chain.voteThreshold()
                let txFee = chain.getInitPayableFee()
                if (delegated.compare(voteThreshold).rawValue > 0 && txFee != nil) {
                    stakedChains.append(chain)
                }
            }
            votableInfo.removeAll()
            filteredInfo.removeAll()
            onFetchProposalInfos(stakedChains)
        }
    }
    
    func onUpdateView() {
        emptyView.isHidden = true
        filterBtn.isHidden = false
        loadingView.isHidden = true
        if (isShowAll && votableInfo.count == 0) {
            emptyView.isHidden = false
        } else if (!isShowAll && filteredInfo.count == 0) {
            emptyView.isHidden = false
        }
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func onSimul(_ section: Int) {
        if (getVoteInfo()[section].msProposals.filter { $0.toVoteOption == nil }.count > 0) {
            return
        }
        
        Task {
            getVoteInfo()[section].onClear()
            
            let cosmosChain = getVoteInfo()[section].basechain as! CosmosClass
            var txFee = cosmosChain.getInitPayableFee()!
            var tempToVotes = [Cosmos_Gov_V1beta1_MsgVote]()
            getVoteInfo()[section].msProposals.forEach { proposal in
                let voteMsg = Cosmos_Gov_V1beta1_MsgVote.with {
                    $0.voter = cosmosChain.bechAddress
                    $0.proposalID = proposal.id!
                    $0.option = proposal.toVoteOption!
                }
                tempToVotes.append(voteMsg)
            }
            
            getVoteInfo()[section].gasChecking = true
            onSectionReload(section)
        
            if let simul = try await simulateVoteTx(cosmosChain, tempToVotes) {
                let toGas = simul.gasInfo.gasUsed
                txFee.gasLimit = UInt64(Double(toGas) * cosmosChain.gasMultiply())
                if let gasRate = cosmosChain.getBaseFeeInfo().FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee.amount[0].amount = feeCoinAmount!.stringValue
                }
                getVoteInfo()[section].gasChecking = false
                getVoteInfo()[section].toVotes = tempToVotes
                getVoteInfo()[section].txFee = txFee
            }
            
            onSectionReload(section)
            DispatchQueue.main.async {
                if (self.getVoteInfo().filter { $0.toVotes == [] || $0.txFee == nil }.count == 0) {
                    self.voteBtn.isEnabled = true
                }
            }
        }
    }
    
    func getVoteInfo() -> [VoteAllModel] {
        if (isShowAll) {
            return votableInfo
        } else {
            return filteredInfo
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
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (request == .ForDataCheck && result == .success) {
            for i in getVoteInfo().indices {
                votableInfo[i].broadcasting = true
            }
            tableView.reloadData()
        }
    }
}

extension AllChainVoteStartVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getVoteInfo().count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = VoteAllChainHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let cosmosChain = getVoteInfo()[section].basechain as! CosmosClass
        view.chainImg.image = UIImage.init(named: cosmosChain.logo1)
        view.titleLabel.text = cosmosChain.name.uppercased()
        view.cntLabel.text = String(getVoteInfo()[section].msProposals.count)
        
        if (getVoteInfo()[section].gasChecking) {
            view.pendingView.isHidden = false
        }
        
        if let txFee = getVoteInfo()[section].txFee,
           let msAsset = BaseData.instance.getAsset(cosmosChain.apiName, txFee.amount[0].denom) {
            WDP.dpCoin(msAsset, txFee.amount[0], nil, view.feeDenomLabel, view.feeAmountLabel, msAsset.decimals)
            view.feeTitle.isHidden = false
            view.feeAmountLabel.isHidden = false
            view.feeDenomLabel.isHidden = false
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getVoteInfo()[section].msProposals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"VoteAllChainCell") as! VoteAllChainCell
        let liveProposal = getVoteInfo()[indexPath.section].msProposals[indexPath.row]
        let myVotedList = getVoteInfo()[indexPath.section].msMyVotes
        cell.onBindVote(liveProposal, myVotedList)
        cell.actionToggle = { tag in
            let voteOption = Cosmos_Gov_V1beta1_VoteOption.init(rawValue: tag)
            if (voteOption == self.getVoteInfo()[indexPath.section].msProposals[indexPath.row].toVoteOption) { return }
            self.getVoteInfo()[indexPath.section].msProposals[indexPath.row].toVoteOption = voteOption
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                self.onSimul(indexPath.section)
            })
        }
        return cell
    }
}

extension AllChainVoteStartVC {
    
    func onFetchProposalInfos(_ stakedChains : [BaseChain]) {
        Task(priority: .high) {
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
                    let address = (chain as! CosmosClass).bechAddress
                    var myVotes = [MintscanMyVotes]()
                    if let votes = try? await AF.request(BaseNetWork.msMyVoteHistory(chain, address), method: .get).serializingDecodable(JSON.self).value {
                        votes["votes"].arrayValue.forEach { vote in
                            myVotes.append(MintscanMyVotes(vote))
                        }
                    }
                    self.votableInfo.append(VoteAllModel.init(chain, toShowProposals,myVotes))
                    
                    var filteredProposal = [MintscanProposal]()
                    for i in 0..<toShowProposals.count {
                        if (myVotes.filter({ $0.proposal_id == toShowProposals[i].id }).count ==  0) {
                            filteredProposal.append(toShowProposals[i])
                        }
                    }
                    if (filteredProposal.count > 0) {
                        self.filteredInfo.append(VoteAllModel.init(chain, filteredProposal, myVotes))
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
//                self.votableInfo.forEach({ info in
//                    print("votableInfo ", info.0.tag, "   ",info.1.count)
//                })
//                self.filteredInfo.forEach({ info in
//                    print("filteredInfo ", info.0.tag, "   ",info.1.count)
//                })
                
                self.votableInfo.sort {
                    if ($0.basechain.tag == "cosmos118") { return true }
                    if ($1.basechain.tag == "cosmos118") { return false }
                    if ($0.basechain.tag == "govgen118") { return true }
                    if ($1.basechain.tag == "govgen118") { return false }
                    return false
                }
                
                self.filteredInfo.sort {
                    if ($0.basechain.tag == "cosmos118") { return true }
                    if ($1.basechain.tag == "cosmos118") { return false }
                    if ($0.basechain.tag == "govgen118") { return true }
                    if ($1.basechain.tag == "govgen118") { return false }
                    return false
                }
                
                self.onUpdateView()
            })
        }
    }
}


extension AllChainVoteStartVC {
    
    func simulateVoteTx(_ chain: CosmosClass, _ msgVotes: [Cosmos_Gov_V1beta1_MsgVote]) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let channel = getConnection(chain)
        if let auth = try await fetchAuth(channel, chain) {
            let simulTx = Signer.genVotesSimul(auth, msgVotes, chain.getInitPayableFee()!, "", chain)
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } else {
            return nil
        }
    }
    
    
    
    func fetchAuth(_ channel: ClientConnection, _ chain: CosmosClass) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = chain.bechAddress }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
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


class VoteAllModel {
    var basechain: BaseChain!
    var msProposals = [MintscanProposal]()
    var msMyVotes = [MintscanMyVotes]()
    var toVotes = [Cosmos_Gov_V1beta1_MsgVote]()
    var txFee: Cosmos_Tx_V1beta1_Fee?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var gasChecking = false
    var broadcasting = false
    
    init(_ basechain: BaseChain!,  _ msProposals: [MintscanProposal], _ msMyVotes: [MintscanMyVotes]) {
        self.basechain = basechain
        self.msProposals = msProposals
        self.msMyVotes = msMyVotes
    }
    
    func onClear() {
        self.toVotes = []
        self.txFee = nil
        self.txResponse = nil
        self.gasChecking = false
        self.broadcasting = false
    }
}
