//
//  VoteDetailsViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/05/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import GRPC
import NIO

class VoteDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var voteDetailTableView: UITableView!
    @IBOutlet weak var btnVote: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    var refresher: UIRefreshControl!
    
    var proposalId: UInt64?
    var mMintscanProposalDetail: MintscanProposalDetail?
    var mMyVote_gRPC: Cosmos_Gov_V1beta1_Vote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.voteDetailTableView.delegate = self
        self.voteDetailTableView.dataSource = self
        self.voteDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.voteDetailTableView.register(UINib(nibName: "VoteInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "VoteInfoTableViewCell")
        self.voteDetailTableView.register(UINib(nibName: "VoteTallyTableViewCell", bundle: nil), forCellReuseIdentifier: "VoteTallyTableViewCell")
        self.voteDetailTableView.rowHeight = UITableView.automaticDimension
        self.voteDetailTableView.estimatedRowHeight = UITableView.automaticDimension
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onFetch), for: .valueChanged)
        refresher.tintColor = UIColor.font05
        voteDetailTableView.addSubview(refresher)
        
        self.btnVote.setTitle(NSLocalizedString("str_vote", comment: ""), for: .normal)
        
        self.loadingImg.onStartAnimation()
        self.onFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_vote_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_vote_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func onUpdateView() {
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
        self.voteDetailTableView.reloadData()
        self.voteDetailTableView.isHidden = false
        self.btnVote.isHidden = false
        self.refresher.endRefreshing()
    }
    
    func onClickLink() {
        let link = WUtils.getProposalExplorer(chainConfig, proposalId!)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    
    @IBAction func onClickVote(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }

        if (mMintscanProposalDetail?.proposal_status?.localizedCaseInsensitiveContains("VOTING") == false) {
            self.onShowToast(NSLocalizedString("error_not_voting_period", comment: ""))
            return
        }
        if (BaseData.instance.mMyDelegations_gRPC.count <= 0) {
            self.onShowToast(NSLocalizedString("error_no_bonding_no_vote", comment: ""))
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mProposals = [mMintscanProposalDetail!]
        txVC.mType = TASK_TYPE_VOTE
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return onBindVoteInfo(tableView)
        } else {
            return onBindTally(tableView)
        }
    }
    
    func onBindVoteInfo(_ tableView: UITableView) -> UITableViewCell {
        let cell:VoteInfoTableViewCell? = tableView.dequeueReusableCell(withIdentifier:"VoteInfoTableViewCell") as? VoteInfoTableViewCell
        if (mMintscanProposalDetail != nil) {
            cell?.statusImg.image = WUtils.onProposalStatusImg(mMintscanProposalDetail)
            cell?.statusTitle.text = WUtils.onProposalStatusTxt(mMintscanProposalDetail)
            cell?.proposalTitle.text = "# ".appending(mMintscanProposalDetail!.id!).appending("  ").appending(mMintscanProposalDetail!.title!)
            cell?.proposerLabel.text = WUtils.onProposalProposer(mMintscanProposalDetail)
            cell?.proposalTypeLabel.text = mMintscanProposalDetail?.proposal_type
            cell?.voteStartTime.text = WDP.dpTime(mMintscanProposalDetail?.voting_start_time)
            cell?.voteEndTime.text = WDP.dpTime(mMintscanProposalDetail?.voting_end_time)
            cell?.voteDescription.text = mMintscanProposalDetail?.description
            if let requestCoin = mMintscanProposalDetail?.content?.amount?[0] {
                WDP.dpCoin(chainConfig, requestCoin, cell!.requestAmountDenom, cell!.requestAmount)
            } else {
                cell!.requestAmountDenom.text = "N/A"
            }
        }
        cell?.actionLink = {
            self.onClickLink()
        }
        cell?.actionToggle = {
            cell?.voteDescription.isScrollEnabled = !(cell?.voteDescription.isScrollEnabled)!
            self.voteDetailTableView.reloadData()
        }
        return cell!
    }
    
    func onBindTally(_ tableView: UITableView) -> UITableViewCell {
        let cell:VoteTallyTableViewCell? = tableView.dequeueReusableCell(withIdentifier:"VoteTallyTableViewCell") as? VoteTallyTableViewCell
//        if (mMintscanProposalDetail != nil) {
//            cell?.onUpdateCards(chainType, mMintscanProposalDetail!)
//        }
//        self.mMyVote_gRPC?.options.forEach { vote in
//            cell?.onCheckMyVote_gRPC(vote.option)
//        }
        return cell!
    }
    
    @objc func onFetch() {
        mFetchCnt = 2
        onFetchMintscanProposl(proposalId!)
        onFetchMyVote_gRPC(self.proposalId!, self.account!.account_address)
    }
    
    var mFetchCnt = 0
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        
        self.onUpdateView()
    }
    
    func onFetchMintscanProposl(_ id: UInt64) {
//        let url = BaseNetWork.mintscanProposalDetail(chainConfig!, id)
//        print("url ", url)
//        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
//        request.responseJSON { (response) in
//            switch response.result {
//            case .success(let res):
//                if let responseData = res as? NSDictionary {
//                    self.mMintscanProposalDetail = MintscanProposalDetail.init(responseData)
//                }
//                
//            case .failure(let error):
//                print("onFetchMintscanProposl ", error)
//            }
//            self.onFetchFinished()
//        }
    }
    
    func onFetchMyVote_gRPC(_ id: UInt64, _ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                defer { try? channel.close().wait() }

                let req = Cosmos_Gov_V1beta1_QueryVoteRequest.with { $0.voter = address; $0.proposalID = id }
                if let response = try? Cosmos_Gov_V1beta1_QueryClient(channel: channel).vote(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    self.mMyVote_gRPC = response.vote
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchProposalMyVote_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
