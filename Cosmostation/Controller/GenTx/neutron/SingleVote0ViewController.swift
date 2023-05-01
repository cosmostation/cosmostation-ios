//
//  SingleVote0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class SingleVote0ViewController: BaseViewController {
    
    @IBOutlet weak var proposalsTableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var proposalModule: NeutronProposalModule?
    var proposal: JSON?
    var opinion: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.proposalModule = pageHolderVC.neutronProposalModule
        self.proposal = pageHolderVC.neutronProposal
        
        self.proposalsTableView.delegate = self
        self.proposalsTableView.dataSource = self
        self.proposalsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.proposalsTableView.register(UINib(nibName: "NeuSingleVoteCell", bundle: nil), forCellReuseIdentifier: "NeuSingleVoteCell")
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (opinion == nil) {
            onShowToast(NSLocalizedString("error_no_opinion", comment: ""))
            return
        }
        pageHolderVC.neutronVoteSingleOpinion = opinion
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }

}

extension SingleVote0ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NeuSingleVoteCell") as? NeuSingleVoteCell
        cell?.onBindView(chainConfig, proposalModule, proposal, opinion)
        cell?.actionYes = {
            self.opinion = "yes"
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        cell?.actionNo =   {
            self.opinion = "no"
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        cell?.actionAbstain = {
            self.opinion = "abstain"
            self.proposalsTableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell!
    }
}
