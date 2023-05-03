//
//  MultiVote0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class MultiVote0ViewController: BaseViewController {
    
    @IBOutlet weak var proposalsTableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var proposalModule: NeutronProposalModule?
    var proposal: JSON?
    var opinion: Int?

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
        self.proposalsTableView.register(UINib(nibName: "NeuMultiVoteCell", bundle: nil), forCellReuseIdentifier: "NeuMultiVoteCell")
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
        
        if let proposal = proposal {
            let id = proposal["id"].int64Value
            let contents = proposal["proposal"]
            
            titleLabel.text = "# ".appending(String(id)).appending("  ").appending(contents["title"].stringValue)
            descriptionLabel.text = contents["description"].stringValue
            
            let expirationTime = contents["expiration"]["at_time"].int64Value
            if (expirationTime > 0) {
                let time = expirationTime / 1000000
                timeLabel.text = WDP.dpTime(time).appending(" ").appending(WDP.dpTimeGap(time))
            }
            let expirationHeight = contents["expiration"]["at_height"].int64Value
            if (expirationHeight > 0) {
                timeLabel.text = "Expiration at : " + String(expirationHeight) + " Block"
            }
        }
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
        pageHolderVC.neutronVoteMultiOpinion = opinion
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
}

extension MultiVote0ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proposal?["proposal"]["choices"].arrayValue.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NeuMultiVoteCell") as? NeuMultiVoteCell
        cell?.onBindView(chainConfig, proposal, indexPath.row, opinion)
        cell?.actionSelect = {
            self.opinion = indexPath.row
            self.proposalsTableView.reloadData()
        }
        return cell!
    }
    
}
