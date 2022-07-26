//
//  AuthzDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var authzTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!

    var refresher: UIRefreshControl!
    var granterAddress: String!
    var grant = Array<Cosmos_Authz_V1beta1_Grant>()
    
    var granterDelegation: Coin?
    var granterUnbonding: Coin?
    var granterAvaiable: Coin?
    var granterReward: Coin?
    var granterCommission: Coin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.authzTableView.delegate = self
        self.authzTableView.dataSource = self
        self.authzTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.authzTableView.register(UINib(nibName: "AuthzGranteeCell", bundle: nil), forCellReuseIdentifier: "AuthzGranteeCell")
        self.authzTableView.register(UINib(nibName: "AuthzGranterCell", bundle: nil), forCellReuseIdentifier: "AuthzGranterCell")
        self.authzTableView.rowHeight = UITableView.automaticDimension
        self.authzTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchAuthz), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.authzTableView.addSubview(refresher)
        
        self.loadingImg.onStartAnimation()
        self.onFetchAuthz()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_authz_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_authz_detail", comment: "")
    }
    
    
    var mFetchCnt = 0
    @objc func onFetchAuthz() {
        if (self.mFetchCnt > 0)  { return }
        self.mFetchCnt = 6
        self.grant.removeAll()
        self.onFetchGrant_gRPC(account!.account_address, granterAddress)
        self.onFetchBalance_gRPC(granterAddress)
        self.onFetchDelegations_gRPC(granterAddress)
        self.onFetchUndelegations_gRPC(granterAddress)
        self.onFetchStakingRewards_gRPC(granterAddress)
        self.onFetchCommission_gRPC(granterAddress)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
    }
    
    func onUpdateViews() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        print("grant ", self.grant.count)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzGranteeCell") as? AuthzGranteeCell
                return cell!
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzGranterCell") as? AuthzGranterCell
                return cell!
                
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzGranteeCell") as? AuthzGranteeCell
        return cell!
    }
    
    func onFetchGrant_gRPC(_ granteeAddress: String, _ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                defer { try! channel.close().wait() }
                let req = Cosmos_Authz_V1beta1_QueryGrantsRequest.with { $0.grantee = granteeAddress; $0.granter = granterAddress }
                if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).grants(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    response.grants.forEach { grant in
                        self.grant.append(grant)
                    }
                }
                try channel.close().wait()

            } catch {
                print("onFetchGrant_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    
    
    func onFetchBalance_gRPC(_ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
                let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = granterAddress; $0.pagination = page }
                if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    response.balances.forEach { balance in
//                        if (NSDecimalNumber.init(string: balance.amount) != NSDecimalNumber.zero) {
//                            BaseData.instance.mMyBalances_gRPC.append(Coin.init(balance.denom, balance.amount))
//                        }
//                    }
//                    let chainConfig = ChainFactory.getChainConfig(self.mChainType)
//                    if (BaseData.instance.getAvailableAmount_gRPC(WUtils.getMainDenom(chainConfig)).compare(NSDecimalNumber.zero).rawValue <= 0) {
//                        BaseData.instance.mMyBalances_gRPC.append(Coin.init(WUtils.getMainDenom(chainConfig), "0"))
//                    }
                    print("Balance ", response)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchBalance_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    
    func onFetchDelegations_gRPC(_ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = granterAddress }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorDelegations(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    response.delegationResponses.forEach { delegationResponse in
//                        BaseData.instance.mMyDelegations_gRPC.append(delegationResponse)
//                    }
                    print("Delegations ", response)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchDelegations_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    
    
    func onFetchUndelegations_gRPC(_ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = granterAddress }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorUnbondingDelegations(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    response.unbondingResponses.forEach { unbondingResponse in
//                        BaseData.instance.mMyUnbondings_gRPC.append(unbondingResponse)
//                    }
                    print("Undelegation ", response)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchUndelegations_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchStakingRewards_gRPC(_ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = granterAddress }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegationTotalRewards(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    response.rewards.forEach { reward in
//                        BaseData.instance.mMyReward_gRPC.append(reward)
//                    }
                    print("Reward ", response)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchStakingRewards_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchCommission_gRPC(_ granterAddress: String) {
        let valOpAddress = granterAddress
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Distribution_V1beta1_QueryValidatorCommissionRequest.with { $0.validatorAddress = valOpAddress }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).validatorCommission(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    print("Commission ", response)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchCommission_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
