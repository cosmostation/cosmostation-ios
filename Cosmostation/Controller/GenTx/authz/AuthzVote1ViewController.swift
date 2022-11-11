//
//  AuthzVote1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class AuthzVote1ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var proposalTableView: UITableView!
    
    var pageHolderVC: StepGenTxViewController!
    var mVotingPeriods = Array<MintscanProposalDetail>()
    var myVotes = Array<MintscanMyVotes>()
    var mSelectedProposalIds = Array<String>()
    var mFetchCnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.proposalTableView.delegate = self
        self.proposalTableView.dataSource = self
        self.proposalTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.proposalTableView.register(UINib(nibName: "ProposalVotingPeriodCell", bundle: nil), forCellReuseIdentifier: "ProposalVotingPeriodCell")
        self.proposalTableView.rowHeight = UITableView.automaticDimension
        self.proposalTableView.estimatedRowHeight = UITableView.automaticDimension
        
        loadingImg.onStartAnimation()
        onFetchVoteData()
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        cancelBtn.isUserInteractionEnabled = true
        nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        if (mVotingPeriods.count > 0) {
            self.sortProposals()
            self.proposalTableView.reloadData()
            self.emptyView.isHidden = true
        } else{
            self.emptyView.isHidden = false
        }
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mVotingPeriods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ProposalVotingPeriodCell") as? ProposalVotingPeriodCell
        let proposal = mVotingPeriods[indexPath.row]
        cell?.onBindView(chainConfig, proposal, myVotes, true, mSelectedProposalIds)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let proposal = mVotingPeriods[indexPath.row]
        if (self.mSelectedProposalIds.contains(proposal.id!)) {
            if let index = self.mSelectedProposalIds.firstIndex(of: proposal.id!) {
                self.mSelectedProposalIds.remove(at: index)
            }
        } else {
            self.mSelectedProposalIds.append(proposal.id!)
        }
        self.proposalTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (mSelectedProposalIds.count <= 0) {
            self.onShowToast(NSLocalizedString("error_no_selected_proposal", comment: ""))
            return
        }
        
        var proposal = Array<MintscanProposalDetail>()
        mSelectedProposalIds.forEach { selectedId in
            if let filtered = mVotingPeriods.filter({ $0.id == selectedId }).first {
                proposal.append(filtered)
            }
        }
        pageHolderVC.mProposals = proposal
        sender.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    func onFetchVoteData() {
        mFetchCnt = 2
        self.onFetchMintscanProposals()
        self.onFetchMintscanMyVotes()
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            onUpdateView()
        }
    }
    
    func onFetchMintscanProposals() {
        let url = BaseNetWork.mintscanProposals(self.chainConfig!)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseDatas = res as? Array<NSDictionary> {
                    responseDatas.forEach { rawProposal in
                        let tempProposal = MintscanProposalDetail.init(rawProposal)
                        if (tempProposal.proposal_status!.localizedCaseInsensitiveContains("VOTING")) {
                            self.mVotingPeriods.append(tempProposal)
                        }
                    }
                }
            case .failure(let error):
                print("onFetchMintscanProposal ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func sortProposals() {
        self.mVotingPeriods.sort {
            return Int($0.id!)! < Int($1.id!)! ? false : true
        }
    }
    
    func onFetchMintscanMyVotes() {
        let url = BaseNetWork.mintscanMyVotes(self.chainConfig!, self.pageHolderVC.mGranterData.address)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseDatas = res as? NSDictionary,
                    let rawVotes = responseDatas.object(forKey: "votes") as? Array<NSDictionary> {
                    rawVotes.forEach { rawVote in
                        self.myVotes.append(MintscanMyVotes.init(rawVote))
                    }
                }
                
            case .failure(let error):
                print("onFetchMintscanMyVotes ", error)
            }
            self.onFetchFinished()
        }
    }

}
