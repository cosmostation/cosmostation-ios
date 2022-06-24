//
//  VoteListViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import GRPC
import NIO

class VoteListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var voteTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    var mProposals_Mintscan = Array<MintscanProposalDetail>()
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory().getChainConfig(chainType)
        
        self.voteTableView.delegate = self
        self.voteTableView.dataSource = self
        self.voteTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.voteTableView.register(UINib(nibName: "ProposalCell", bundle: nil), forCellReuseIdentifier: "ProposalCell")
        self.voteTableView.rowHeight = UITableView.automaticDimension
        self.voteTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchProposals), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.voteTableView.addSubview(refresher)
        
        self.loadingImg.onStartAnimation()
        self.onFetchProposals()
    }
    
    @objc func onFetchProposals() {
        self.mProposals_Mintscan.removeAll()
        self.onFetchMintscanProposal()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_vote_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_vote_list", comment: "")
    }
    
    func onUpdateViews() {
        if (mProposals_Mintscan.count > 0) {
            self.emptyLabel.isHidden = true
            self.voteTableView.reloadData()
        } else {
            self.emptyLabel.isHidden = false
        }
        self.sortProposals()
        self.refresher.endRefreshing()
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mProposals_Mintscan.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return onBindProposal(tableView, indexPath)
    }
    
    func onBindProposal(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell  {
        let cell:ProposalCell? = tableView.dequeueReusableCell(withIdentifier:"ProposalCell") as? ProposalCell
        let proposal = mProposals_Mintscan[indexPath.row]
        cell?.proposalIdLabel.text = "# ".appending(proposal.id!)
        cell?.proposalTitleLabel.text = proposal.title
        cell?.proposalMsgLabel.text = proposal.description
        cell?.proposalStateLabel.text = WUtils.onProposalStatusTxt(proposal)
        cell?.proposalStateImg.image = WUtils.onProposalStatusImg(proposal)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let proposal = mProposals_Mintscan[indexPath.row]
        if (proposal.proposal_status!.localizedCaseInsensitiveContains("PASSED") || proposal.proposal_status!.localizedCaseInsensitiveContains("REJECTED")) {
            onExplorerLink(proposal.id!)
        } else {
            let voteDetailsVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VoteDetailsViewController") as! VoteDetailsViewController
            voteDetailsVC.proposalId = proposal.id!
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(voteDetailsVC, animated: true)
        }
    }
    
    func onExplorerLink(_ proposalId: String) {
        let link = WUtils.getProposalExplorer(chainConfig, proposalId)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    func onFetchMintscanProposal() {
        let url = BaseNetWork.mintscanProposals(self.chainConfig!)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseDatas = res as? Array<NSDictionary> {
                    responseDatas.forEach { rawProposal in
                        self.mProposals_Mintscan.append(MintscanProposalDetail.init(rawProposal))
                    }
                }
            case .failure(let error):
                print("onFetchMintscanProposal ", error)
            }
            self.onUpdateViews()
        }
    }
    
    func sortProposals() {
        self.mProposals_Mintscan.sort {
            return Int($0.id!)! < Int($1.id!)! ? false : true
        }
    }

}
