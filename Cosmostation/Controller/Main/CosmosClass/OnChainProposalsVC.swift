//
//  OnChainProposalsVC.swift
//  Cosmostation
//
//  Created by 차소민 on 11/6/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import SwiftyJSON

class OnChainProposalsVC: BaseVC {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    
    var selectedChain: BaseChain!

    var proposals: [MintscanProposal] = []
    var votingPeriods: [MintscanProposal] = []
    var etcPeriods: [MintscanProposal] = []
    var toVoteList = Array<UInt64>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.isHidden = false
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "OnChainProposalCell", bundle: nil), forCellReuseIdentifier: "OnChainProposalCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0

        onFetchVoteInfos()
    }
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_vote_list", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_start_vote", comment: ""), for: .normal)
    }
    
    func onFetchVoteInfos() {
        votingPeriods.removeAll()
        etcPeriods.removeAll()

        Task {
            try await fetchProposals(selectedChain)
            
            proposals.forEach { proposal in
                if proposal.isVotingPeriod() {
                    votingPeriods.append(proposal)
                } else {
                    etcPeriods.append(proposal)
                }
            }
                        
            onUpdateView()
        }
    }
    
    func onUpdateView() {
        if proposals.isEmpty {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
        
        loadingView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    @IBAction func onClickVote(_ sender: BaseButton) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        if let initiaFetcher = (selectedChain as? ChainInitia)?.getInitiaFetcher() {
            let delegated = initiaFetcher.initiaDelegationAmountSum()
            let voteThreshold = selectedChain.voteThreshold()
            if (delegated.compare(voteThreshold).rawValue <= 0) {
                onShowToast(NSLocalizedString("error_no_bonding_no_vote", comment: ""))
                return
            }
        } else {
            if let delegated = selectedChain.getCosmosfetcher()?.delegationAmountSum() {
                let voteThreshold = selectedChain.voteThreshold()
                if (delegated.compare(voteThreshold).rawValue <= 0) {
                    onShowToast(NSLocalizedString("error_no_bonding_no_vote", comment: ""))
                    return
                }
            }
        }
        
        var toVoteProposals = [MintscanProposal]()
        votingPeriods.forEach { proposal in
            if (toVoteList.contains(proposal.id!)) {
                toVoteProposals.append(proposal)
            }
        }
        
        if (selectedChain is ChainBeraEVM_T) {
            if (toVoteProposals.count > 1) {
                onShowToast(NSLocalizedString("error_bera_vote_one_proposal", comment: ""))
                return
            }
        } else {
            let vote = CosmosVote(nibName: "CosmosVote", bundle: nil)
            vote.selectedChain = selectedChain
            vote.toVoteProposals = toVoteProposals
            vote.modalTransitionStyle = .coverVertical
            self.present(vote, animated: true)
        }
        
    }

}


extension OnChainProposalsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("str_voting_period", comment: "")
            view.cntLabel.text = String(votingPeriods.count)
            
        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("str_voting_finished", comment: "")
            view.cntLabel.text = String(etcPeriods.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return votingPeriods.count > 0 ? 40 : 0
            
        } else if (section == 1) {
            return etcPeriods.count > 0 ? 40 : 0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return votingPeriods.count
            
        } else if (section == 1) {
            return etcPeriods.count
        }
        return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"OnChainProposalCell") as! OnChainProposalCell
        if (indexPath.section == 0) {
            var proposal: MintscanProposal!
            proposal = votingPeriods[indexPath.row]
            cell.onBindProposal(proposal, toVoteList)
            cell.actionToggle = { request in
                if (request && !self.toVoteList.contains(proposal.id!)) {
                    self.toVoteList.append(proposal.id!)
                } else if (!request && self.toVoteList.contains(proposal.id!)) {
                    if let index = self.toVoteList.firstIndex(of: proposal.id!) {
                        self.toVoteList.remove(at: index)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.voteBtn.isEnabled = !self.toVoteList.isEmpty
                })
            }

        } else {
            cell.onBindProposal(etcPeriods[indexPath.row], toVoteList)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var proposalId: UInt64 = 0
        if (indexPath.section == 0) {
            proposalId = votingPeriods[indexPath.row].id!
            
        } else if (indexPath.section == 1) {
            proposalId = etcPeriods[indexPath.row].id!
        }
        guard let url = selectedChain.getExplorerProposal(proposalId) else { return }
        self.onShowSafariWeb(url)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }

}


extension OnChainProposalsVC {
    func fetchProposals(_ chain: BaseChain) async throws {
        guard let cosmosFetcher = chain.getCosmosfetcher() else { return }
        if (cosmosFetcher.getEndpointType() == .UseGRPC) {
            let req = Cosmos_Gov_V1_QueryProposalsRequest()
            if var proposals = try? await Cosmos_Gov_V1_QueryNIOClient(channel: cosmosFetcher.getClient()).proposals(req, callOptions: cosmosFetcher.getCallOptions()).response.get().proposals {
                proposals.sort {
                    $0.id > $1.id
                }
                proposals.forEach({
                    self.proposals.append(MintscanProposal($0))
                })
            }

        } else {
            let url = cosmosFetcher.getLcd() + "cosmos/gov/v1/proposals"
            if let response = try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value {
                
                let proposals = response["proposals"].arrayValue.sorted {
                    $0["id"].uInt64Value > $1["id"].uInt64Value
                }
                proposals.forEach { proposal in
                    self.proposals.append(MintscanProposal(proposal))
                }
            }
        }
    }
    
}

