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
    
    @IBOutlet weak var vcTitleLabel: UILabel!
    @IBOutlet weak var voteDetailTableView: UITableView!
    @IBOutlet weak var btnVote: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    var refresher: UIRefreshControl!
    
    var mProposalId: UInt64?
    var mMintscanProposalDetail: MintscanProposalDetail?
    var mMintscanMyVote: MintscanMyVotes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.voteDetailTableView.delegate = self
        self.voteDetailTableView.dataSource = self
        self.voteDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.voteDetailTableView.register(UINib(nibName: "VoteDetailTitleCell", bundle: nil), forCellReuseIdentifier: "VoteDetailTitleCell")
        self.voteDetailTableView.register(UINib(nibName: "VoteInfoCell", bundle: nil), forCellReuseIdentifier: "VoteInfoCell")
        self.voteDetailTableView.register(UINib(nibName: "VoteDetailStatusCell", bundle: nil), forCellReuseIdentifier: "VoteDetailStatusCell")
        self.voteDetailTableView.rowHeight = UITableView.automaticDimension
        self.voteDetailTableView.estimatedRowHeight = UITableView.automaticDimension
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onFetch), for: .valueChanged)
        refresher.tintColor = UIColor.font05
        voteDetailTableView.addSubview(refresher)
        
        self.vcTitleLabel.text = NSLocalizedString("title_vote_detail", comment: "")
        self.btnVote.setTitle(NSLocalizedString("str_vote", comment: ""), for: .normal)
        
        self.loadingImg.onStartAnimation()
        self.onFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
    }
    
    func onUpdateView() {
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
        self.voteDetailTableView.reloadData()
        self.voteDetailTableView.isHidden = false
        self.btnVote.isHidden = false
        self.refresher.endRefreshing()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickLink() {
        let link = WUtils.getProposalExplorer(chainConfig, mProposalId!)
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
        let cell:VoteInfoCell? = tableView.dequeueReusableCell(withIdentifier:"VoteInfoCell") as? VoteInfoCell
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
//        cell?.actionLink = {
//            self.onClickLink()
//        }
        cell?.actionToggle = {
            cell?.voteDescription.isScrollEnabled = !(cell?.voteDescription.isScrollEnabled)!
            self.voteDetailTableView.reloadData()
        }
        return cell!
    }
    
    func onBindTally(_ tableView: UITableView) -> UITableViewCell {
        let cell:VoteDetailStatusCell? = tableView.dequeueReusableCell(withIdentifier:"VoteDetailStatusCell") as? VoteDetailStatusCell
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
        onFetchMintscanProposl(mProposalId!)
        onFetchMintscanMyVotes()
    }
    
    var mFetchCnt = 0
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        
        self.onUpdateView()
    }
    
    func onFetchMintscanProposl(_ id: UInt64) {
        let url = BaseNetWork.mintscanProposalDetail(chainConfig!, id)
        print("url ", url)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseData = res as? NSDictionary {
                    self.mMintscanProposalDetail = MintscanProposalDetail.init(responseData)
                }
                
            case .failure(let error):
                print("onFetchMintscanProposl ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchMintscanMyVotes() {
        let url = BaseNetWork.mintscanMyVotes(self.chainConfig!, self.account!.account_address)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseDatas = res as? NSDictionary,
                    let rawVotes = responseDatas.object(forKey: "votes") as? Array<NSDictionary> {
                    rawVotes.forEach { rawVote in
                        
                    }
                }
                
            case .failure(let error):
                print("onFetchMintscanMyVotes ", error)
            }
            self.onFetchFinished()
        }
    }
}
