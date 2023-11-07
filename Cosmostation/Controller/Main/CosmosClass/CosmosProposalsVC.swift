//
//  CosmosProposalsVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import AlamofireImage
import SwiftyJSON

class CosmosProposalsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: CosmosClass!
    
    var votingPeriods = Array<MintscanProposal>()
    var etcPeriods = Array<MintscanProposal>()
    var filteredVotingPeriods = Array<MintscanProposal>()
    var filteredEtcPeriods = Array<MintscanProposal>()
    var myVotes = Array<MintscanMyVotes>()
    var toVoteList = Array<UInt64>()
    var isShowAll = false
    
    var showAll: UIBarButtonItem?
    var filtered: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CosmosProposalCell", bundle: nil), forCellReuseIdentifier: "CosmosProposalCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        showAll = UIBarButtonItem(image: UIImage(named: "iconFilterOn"), style: .plain, target: self, action: #selector(onClickFilterOn))
        filtered = UIBarButtonItem(image: UIImage(named: "iconFilterOff"), style: .plain, target: self, action: #selector(onClickFilterOff))
        navigationItem.setRightBarButton(showAll, animated: true)
        
        onFetchData()
    }
    
    @objc func onClickFilterOn() {
        navigationItem.setRightBarButton(filtered, animated: true)
        isShowAll = !isShowAll
        tableView.reloadData()
        
    }
    
    @objc func onClickFilterOff() {
        navigationItem.setRightBarButton(showAll, animated: true)
        isShowAll = !isShowAll
        tableView.reloadData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_vote_list", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_start_vote", comment: ""), for: .normal)
    }
    
    func onFetchData() {
        votingPeriods.removeAll()
        etcPeriods.removeAll()
        filteredVotingPeriods.removeAll()
        filteredEtcPeriods.removeAll()
        myVotes.removeAll()
        
        Task {
            if let proposals = try? await fetchProposals(selectedChain),
               let votes = try? await fetchMyVotes(selectedChain, selectedChain.bechAddress) {
                proposals.forEach { proposal in
                    let msProposal = MintscanProposal(proposal)
                    if (msProposal.isVotingPeriod()) {
                        votingPeriods.append(msProposal)
                        if (!msProposal.isScam()) {
                            filteredVotingPeriods.append(msProposal)
                        }
                        
                    } else {
                        etcPeriods.append(msProposal)
                        if (!msProposal.isScam()) {
                            filteredEtcPeriods.append(msProposal)
                        }
                    }
                }
                votes["votes"].arrayValue.forEach { vote in
                    myVotes.append(MintscanMyVotes(vote))
                }
            }
            
            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onUpdateView() {
        loadingView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    @IBAction func onClickVote(_ sender: BaseButton) {
        var toVoteProposals = [MintscanProposal]()
        votingPeriods.forEach { proposal in
            if (toVoteList.contains(proposal.id!)) {
                toVoteProposals.append(proposal)
            }
        }
        
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let vote = CosmosVote(nibName: "CosmosVote", bundle: nil)
        vote.selectedChain = selectedChain
        vote.toVoteProposals = toVoteProposals
        vote.modalTransitionStyle = .coverVertical
        self.present(vote, animated: true)
        
    }
}

extension CosmosProposalsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("str_voting_period", comment: "")
            if (isShowAll) { view.cntLabel.text = String(votingPeriods.count) }
            else { view.cntLabel.text = String(filteredVotingPeriods.count) }
            
        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("str_vote_proposals", comment: "")
            if (isShowAll) { view.cntLabel.text = String(etcPeriods.count) }
            else { view.cntLabel.text = String(filteredEtcPeriods.count) }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            if (isShowAll) { return votingPeriods.count > 0 ? 40 : 0 }
            else { return filteredVotingPeriods.count > 0 ? 40 : 0}
            
        } else if (section == 1) {
            if (isShowAll) { return etcPeriods.count > 0 ? 40 : 0 }
            else { return filteredEtcPeriods.count > 0 ? 40 : 0}
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if (isShowAll) { return votingPeriods.count }
            else { return filteredVotingPeriods.count }
            
        } else if (section == 1) {
            if (isShowAll) { return etcPeriods.count }
            else { return filteredEtcPeriods.count }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CosmosProposalCell") as! CosmosProposalCell
        if (indexPath.section == 0) {
            var proposal: MintscanProposal!
            if (isShowAll) {
                proposal = votingPeriods[indexPath.row]
            } else {
                proposal = filteredVotingPeriods[indexPath.row]
            }
            cell.onBindProposal(proposal, myVotes, toVoteList)
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
            if (isShowAll) {
                cell.onBindProposal(etcPeriods[indexPath.row], myVotes, toVoteList)
            } else {
                cell.onBindProposal(filteredEtcPeriods[indexPath.row], myVotes, toVoteList)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var proposalId: UInt64 = 0
        if (indexPath.section == 0) {
            if (isShowAll) {
                proposalId = votingPeriods[indexPath.row].id!
            } else {
                proposalId = filteredVotingPeriods[indexPath.row].id!
            }
            
        } else if (indexPath.section == 1) {
            if (isShowAll) {
                proposalId = etcPeriods[indexPath.row].id!
            } else {
                proposalId = filteredEtcPeriods[indexPath.row].id!
            }
        }
        guard let url = BaseNetWork.getProposalDetailUrl(selectedChain, proposalId) else { return }
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


extension CosmosProposalsVC {
    
    func fetchProposals(_ chain: BaseChain) async throws -> [JSON] {
        return try await AF.request(BaseNetWork.msProposals(chain), method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchMyVotes(_ chain: BaseChain, _ address: String) async throws -> JSON {
        return try await AF.request(BaseNetWork.msMyVoteHistory(chain, address), method: .get).serializingDecodable(JSON.self).value
    }
    
}
