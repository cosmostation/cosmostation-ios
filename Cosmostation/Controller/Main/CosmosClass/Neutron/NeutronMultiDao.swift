//
//  NeutronMultiDao.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON

class NeutronMultiDao: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    
    var selectedChain: ChainNeutron!
    var neutronFetcher: NeutronFetcher!
    var neutronMyVotes: [JSON]?
    
    var votingPeriods = [JSON]()
    var etcPeriods = [JSON]()
    var filteredVotingPeriods = [JSON]()
    var filteredEtcPeriods = [JSON]()
    var toVoteMulti = [Int64]()
    var isShowAll = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        neutronFetcher = selectedChain.getNeutronFetcher()
        
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
        
        fetchProposals()
    }
    
    override func setLocalizedString() {
        voteBtn.setTitle(NSLocalizedString("str_start_vote", comment: ""), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        neutronMyVotes = (self.parent as? NeutronDaoVC)?.neutronMyVotes
        isShowAll = (self.parent as? NeutronDaoVC)?.isShowAll ?? false
        NotificationCenter.default.addObserver(self, selector: #selector(onToggleFilter), name: Notification.Name("ToggleFilter"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ToggleFilter"), object: nil)
    }
    
    @objc func onToggleFilter() {
        isShowAll = (self.parent as? NeutronDaoVC)?.isShowAll ?? false
        if (isShowAll) {
            onShowToast(NSLocalizedString("msg_show_all_proposals", comment: ""))
        } else {
            onShowToast(NSLocalizedString("msg_hide_scam_proposals", comment: ""))
        }
        updateView()
    }
    
    func updateView() {
        loadingView.isHidden = true
        if (votingPeriods.count == 0 && etcPeriods.count == 0) {
            emptyView.isHidden = false
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    @IBAction func onClickVote(_ sender: BaseButton) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let vote = NeutronVote(nibName: "NeutronVote", bundle: nil)
        vote.selectedChain = selectedChain
        vote.toMultiProposals = votingPeriods.filter { toVoteMulti.contains($0["id"].int64Value) }
        vote.modalTransitionStyle = .coverVertical
        self.present(vote, animated: true)
    }
    
    func fetchProposals() {
        self.votingPeriods.removeAll()
        self.etcPeriods.removeAll()
        self.filteredVotingPeriods.removeAll()
        self.filteredEtcPeriods.removeAll()
        
        Task {
            if let response = try await neutronFetcher.fetchNeutronProposals(1) {
                response["proposals"].arrayValue.forEach { proposal in
                    let title = proposal["proposal"]["title"].stringValue.lowercased()
                    if (proposal["proposal"]["status"].stringValue.lowercased() == "open") {
                        votingPeriods.append(proposal)
                        if (!title.contains("airdrop") && !title.containsEmoji()) {
                            filteredVotingPeriods.append(proposal)
                        }
                        
                    } else {
                        etcPeriods.append(proposal)
                        if (!title.contains("airdrop") && !title.containsEmoji()) {
                            filteredEtcPeriods.append(proposal)
                        }
                    }
                }
            }
            DispatchQueue.main.async { self.updateView() }
        }
    }
}

extension NeutronMultiDao: UITableViewDelegate, UITableViewDataSource {
    
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
            view.titleLabel.text = NSLocalizedString("str_voting_finished", comment: "")
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
        let module = neutronFetcher.daosList?[0]["proposal_modules"][1]
        var proposal: JSON!
        if (indexPath.section == 0) {
            if (isShowAll) {
                proposal = votingPeriods[indexPath.row]
            } else {
                proposal = filteredVotingPeriods[indexPath.row]
            }
            cell.actionToggle = { request in
                let id = proposal["id"].int64Value
                if (request && !self.toVoteMulti.contains(id)) {
                    self.toVoteMulti.append(id)
                } else if (!request && self.toVoteMulti.contains(id)) {
                    if let index = self.toVoteMulti.firstIndex(of: id) {
                        self.toVoteMulti.remove(at: index)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.voteBtn.isEnabled = !self.toVoteMulti.isEmpty
                })
            }
        } else {
            if (isShowAll) {
                proposal = etcPeriods[indexPath.row]
            } else {
                proposal = filteredEtcPeriods[indexPath.row]
            }
        }
        cell.onBindNeutronDao(module, proposal, neutronMyVotes, toVoteMulti)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contAddress = neutronFetcher.daosList?[0]["proposal_modules"][1]["address"].string ?? ""
        var proposal: JSON!
        if (indexPath.section == 0) {
            if (isShowAll) {
                proposal = votingPeriods[indexPath.row]
            } else {
                proposal = filteredVotingPeriods[indexPath.row]
            }
        } else {
            if (isShowAll) {
                proposal = etcPeriods[indexPath.row]
            } else {
                proposal = filteredEtcPeriods[indexPath.row]
            }
        }
        let explorer = MintscanUrl + "neutron/dao/proposals/" + proposal["id"].stringValue + "/multiple/" +  contAddress
        if let url = URL(string: explorer) {
            self.onShowSafariWeb(url)
        }
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
