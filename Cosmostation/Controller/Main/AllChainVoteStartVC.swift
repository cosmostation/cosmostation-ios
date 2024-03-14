//
//  AllChainVoteStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/14/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import AlamofireImage
import SwiftyJSON

class AllChainVoteStartVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var votableInfo = [(BaseChain, [MintscanProposal])]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        voteBtn.isEnabled = false
        onInitView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_voting_period", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_vote_all", comment: ""), for: .normal)
//        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        votableInfo.removeAll()
        onInitView()
    }
    
    func onInitView() {
        if (baseAccount.getDisplayCosmosChains().filter { $0.fetched == false && $0.isDefault == true }.count == 0 &&
            baseAccount.getDisplayEvmChains().filter { $0.fetched == false && $0.isDefault == true }.count == 0) {
            
            var stakedChains = [BaseChain]()
            baseAccount.getDisplayCosmosChains().forEach { chain in
                let delegated = chain.delegationAmountSum()
                let voteThreshold = chain.voteThreshold()
                let txFee = chain.getInitPayableFee()
                if (delegated.compare(voteThreshold).rawValue > 0 && txFee != nil) {
                    stakedChains.append(chain)
                }
            }
            
            baseAccount.getDisplayEvmChains().filter { $0.supportCosmos == true }.forEach { chain in
                let delegated = chain.delegationAmountSum()
                let voteThreshold = chain.voteThreshold()
                let txFee = chain.getInitPayableFee()
                if (delegated.compare(voteThreshold).rawValue > 0 && txFee != nil) {
                    stakedChains.append(chain)
                }
            }
            
            print("stakedChains ", stakedChains.count)
            onFetchProposalInfos(stakedChains)
        }
    }

    @IBAction func onClickVote(_ sender: BaseButton) {
        
    }
}

extension AllChainVoteStartVC {
    
    func onFetchProposalInfos(_ stakedChains : [BaseChain]) {
        Task(priority: .high) {
            await stakedChains.concurrentForEach { chain in
                do {
                    var toShowProposals = [MintscanProposal]()
                    if let proposals = try? await AF.request(BaseNetWork.msProposals(chain), method: .get).serializingDecodable([JSON].self).value {
                        proposals.forEach { proposal in
                            let msProposal = MintscanProposal(proposal)
                            if (msProposal.isVotingPeriod() && !msProposal.isScam()) {
                                toShowProposals.append(msProposal)
                            }
                        }
                    }
                    if (!toShowProposals.isEmpty) {
                        self.votableInfo.append((chain, toShowProposals))
                    }
                    
                    
                } catch {}
            }
        }
    }
}
