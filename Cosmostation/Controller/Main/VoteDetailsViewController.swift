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
    
    var proposalId: UInt64?
    var mintscanProposalDetail: MintscanProposalDetail?
    var mintscanMyVotes: MintscanMyVotes?
    var selectedMsg = Array<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.voteDetailTableView.delegate = self
        self.voteDetailTableView.dataSource = self
        self.voteDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.voteDetailTableView.register(UINib(nibName: "VoteDetailTitleCell", bundle: nil), forCellReuseIdentifier: "VoteDetailTitleCell")
        self.voteDetailTableView.register(UINib(nibName: "VoteDetailStatusCell", bundle: nil), forCellReuseIdentifier: "VoteDetailStatusCell")
        self.voteDetailTableView.register(UINib(nibName: "VoteDetailMsgCell", bundle: nil), forCellReuseIdentifier: "VoteDetailMsgCell")
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
        let link = WUtils.getProposalExplorer(chainConfig, proposalId!)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    @IBAction func onClickVote(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }

        if (mintscanProposalDetail?.proposal_status?.localizedCaseInsensitiveContains("VOTING") == false) {
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
        txVC.mProposals = [mintscanProposalDetail!]
        txVC.mType = TASK_TYPE_VOTE
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        } else {
            return mintscanProposalDetail?.messages.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"VoteDetailTitleCell") as? VoteDetailTitleCell
                cell?.onBindView(mintscanProposalDetail)
                return cell!
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"VoteDetailStatusCell") as? VoteDetailStatusCell
                cell?.onBindView(mintscanProposalDetail, mintscanMyVotes)
                return cell!
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"VoteDetailMsgCell") as? VoteDetailMsgCell
            cell?.onBindView(mintscanProposalDetail?.messages[indexPath.row], indexPath.row, selectedMsg)
            cell?.actionToggle = {
                if let index = self.selectedMsg.firstIndex(of: indexPath.row) {
                    self.selectedMsg.remove(at: index)
                } else {
                    self.selectedMsg.append(indexPath.row)
                }
                self.voteDetailTableView.beginUpdates()
                self.voteDetailTableView.reloadRows(at: [indexPath], with: .automatic)
                self.voteDetailTableView.endUpdates()
            }
            return cell!
        }
    }
    
    /*
    func onBindVoteInfo(_ tableView: UITableView) -> UITableViewCell {
        let cell:VoteInfoCell? = tableView.dequeueReusableCell(withIdentifier:"VoteInfoCell") as? VoteInfoCell
        if (mintscanProposalDetail != nil) {
            cell?.statusImg.image = WUtils.onProposalStatusImg(mintscanProposalDetail)
            cell?.statusTitle.text = WUtils.onProposalStatusTxt(mintscanProposalDetail)
            cell?.proposalTitle.text = "# ".appending(mintscanProposalDetail!.id!).appending("  ").appending(mintscanProposalDetail!.title!)
            cell?.proposerLabel.text = WUtils.onProposalProposer(mintscanProposalDetail)
            cell?.proposalTypeLabel.text = mintscanProposalDetail?.proposal_type
            cell?.voteStartTime.text = WDP.dpTime(mintscanProposalDetail?.voting_start_time)
            cell?.voteEndTime.text = WDP.dpTime(mintscanProposalDetail?.voting_end_time)
            cell?.voteDescription.text = mintscanProposalDetail?.description
            if let requestCoin = mintscanProposalDetail?.content?.amount?[0] {
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
//        if (mintscanProposalDetail != nil) {
//            cell?.onUpdateCards(chainType, mintscanProposalDetail!)
//        }
//        self.mMyVote_gRPC?.options.forEach { vote in
//            cell?.onCheckMyVote_gRPC(vote.option)
//        }
        return cell!
    }
     */
    
    @objc func onFetch() {
        selectedMsg.removeAll()
        mFetchCnt = 2
        onFetchMintscanProposl(proposalId!)
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
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseData = res as? NSDictionary {
                    self.mintscanProposalDetail = MintscanProposalDetail.init(responseData)
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
                        let votes = MintscanMyVotes.init(rawVote)
                        if (votes.proposal_id == self.proposalId) {
                            self.mintscanMyVotes = votes
                            return
                        }
                    }
                }
                
            case .failure(let error):
                print("onFetchMintscanMyVotes ", error)
            }
            self.onFetchFinished()
        }
    }
}
