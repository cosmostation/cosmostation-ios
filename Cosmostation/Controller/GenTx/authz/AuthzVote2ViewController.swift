//
//  AuthzVote2ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzVote2ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var proposalsTableView: UITableView!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var toVoteProposals = Array<MintscanProposalDetail>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.proposalsTableView.delegate = self
        self.proposalsTableView.dataSource = self
        self.proposalsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.proposalsTableView.register(UINib(nibName: "VoteCell", bundle: nil), forCellReuseIdentifier: "VoteCell")
        self.proposalsTableView.rowHeight = UITableView.automaticDimension
        self.proposalsTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.toVoteProposals = pageHolderVC.mProposals
        
        beforeBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        beforeBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toVoteProposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"VoteCell") as? VoteCell
        let proposal = toVoteProposals[indexPath.row]
        cell?.onBindView(chainConfig, proposal)
        cell?.actionYes = {
            self.toVoteProposals[indexPath.row].setMyVote("Yes")
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        cell?.actionNo =   {
            self.toVoteProposals[indexPath.row].setMyVote("No")
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        cell?.actionVeto = {
            self.toVoteProposals[indexPath.row].setMyVote("NoWithVeto")
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        cell?.actionAbstain = {
            self.toVoteProposals[indexPath.row].setMyVote("Abstain")
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell!
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    
    @IBAction func onClickNext(_ sender: UIButton) {
        var allVoted = true
        toVoteProposals.forEach { proposal in
            if (proposal.getMyVote() == nil) {
                allVoted = false
            }
        }
        if (!allVoted) {
            self.onShowToast(NSLocalizedString("error_no_opinion", comment: ""))
            return
        }
        self.pageHolderVC.mProposals = self.toVoteProposals
        self.beforeBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    override func enableUserInteraction() {
        self.beforeBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }

}
