//
//  AuthzVote1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class AuthzVote1ViewController: BaseViewController {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var proposalTableView: UITableView!
    
    var pageHolderVC: StepGenTxViewController!
    var mVotingPeriods = Array<MintscanProposalDetail>()
    var myVotes = Array<MintscanMyVotes>()
    var mFetchCnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        onFetchVoteData()
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        cancelBtn.isUserInteractionEnabled = true
        nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        print("mVotingPeriods ", mVotingPeriods.count)
        print("myVotes ", myVotes.count)
        
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
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
        }
    }
    
    func onFetchMintscanMyVotes() {
        let url = BaseNetWork.mintscanMyVotes(self.chainConfig!, self.pageHolderVC.mGranterAddress!)
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
        }
    }

}
