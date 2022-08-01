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
    var grants = Array<Cosmos_Authz_V1beta1_Grant>()
    
    var granterAuth: Google_Protobuf2_Any?
    var granterBalance: Coin?
    var granterAvailable: Coin?
    var granterVesting: Coin?
    var granterDelegation = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var granterUnbonding = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    var granterReward = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
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
        self.authzTableView.register(UINib(nibName: "AuthzExecuteCell", bundle: nil), forCellReuseIdentifier: "AuthzExecuteCell")
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
        self.mFetchCnt = 7
        self.grants.removeAll()
        self.granterAuth = nil
        self.granterBalance = Coin.init(chainConfig!.stakeDenom, "0")
        self.granterAvailable = Coin.init(chainConfig!.stakeDenom, "0")
        self.granterVesting = Coin.init(chainConfig!.stakeDenom, "0")
        self.granterDelegation.removeAll()
        self.granterUnbonding.removeAll()
        self.granterReward.removeAll()
        self.granterCommission = Coin.init(chainConfig!.stakeDenom, "0")
        
        self.onFetchGrant_gRPC(account!.account_address, granterAddress)
        self.onFetchAuth_gRPC(granterAddress)
        self.onFetchBalance_gRPC(granterAddress)
        self.onFetchDelegations_gRPC(granterAddress)
        self.onFetchUndelegations_gRPC(granterAddress)
        self.onFetchStakingRewards_gRPC(granterAddress)
        self.onFetchCommission_gRPC(granterAddress)
    }
    
    func onFetchFinished() {
//        print("onFetchFinished ", mFetchCnt)
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        
        self.checkAccountType()
        self.onUpdateViews()
    }
    
    func onUpdateViews() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        print("grants ", self.grants.count)
        self.authzTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        } else if (section == 1) {
            return 7
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzGranteeCell") as? AuthzGranteeCell
                cell?.onBindView(chainConfig, account!.account_address)
                return cell!
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzGranterCell") as? AuthzGranterCell
                cell?.onBindView(chainConfig, granterAddress, granterAvailable, granterVesting, getDelegatedSum(), getUnbondingSum(), getRewardSum(), granterCommission)
                return cell!
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzExecuteCell") as? AuthzExecuteCell
            if (indexPath.row == 0) {
                cell?.onBindSend(chainConfig, getSendAuth())
            } else if (indexPath.row == 1) {
                cell?.onBindDelegate(chainConfig, getDelegateAuth())
            } else if (indexPath.row == 2) {
                cell?.onBindUndelegate(chainConfig, getUndelegateAuth())
            } else if (indexPath.row == 3) {
                cell?.onBindRedelegate(chainConfig, getRedelegateAuth())
            } else if (indexPath.row == 4) {
                cell?.onBindReward(getRewardAuth())
            } else if (indexPath.row == 5) {
                cell?.onBindCommission(getCommissionAuth())
            } else if (indexPath.row == 6) {
                cell?.onBindVote(getVoteAuth())
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                guard let auth = getSendAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                
            } else if (indexPath.row == 1) {
                guard let auth = getDelegateAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                
            } else if (indexPath.row == 2) {
                guard let auth = getUndelegateAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                
            } else if (indexPath.row == 3) {
                guard let auth = getRedelegateAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                
            } else if (indexPath.row == 4) {
                guard let auth = getRewardAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
                txVC.mGrant = auth
                txVC.mGranterAddress = granterAddress
                txVC.mGranterReward = granterReward
                txVC.mType = TASK_TYPE_AUTHZ_CLAIM_REWARDS
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(txVC, animated: true)
                
            } else if (indexPath.row == 5) {
                guard let auth = getCommissionAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
                txVC.mGrant = auth
                txVC.mGranterAddress = granterAddress
                txVC.mGranterCommission = granterCommission
                txVC.mType = TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(txVC, animated: true)
                
            } else if (indexPath.row == 6) {
                guard let auth = getVoteAuth() else {
                    self.onShowToast(NSLocalizedString("error_no_authz_type", comment: ""))
                    return
                }
                let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
                txVC.mGrant = auth
                txVC.mGranterAddress = granterAddress
                txVC.mType = TASK_TYPE_AUTHZ_VOTE
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(txVC, animated: true)
                
            }
        }
    }
    
    
    func onFetchGrant_gRPC(_ granteeAddress: String, _ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                defer { try! channel.close().wait() }
                let req = Cosmos_Authz_V1beta1_QueryGrantsRequest.with { $0.grantee = granteeAddress; $0.granter = granterAddress }
                if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).grants(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    response.grants.forEach { grant in
                        self.grants.append(grant)
                    }
                }
                try channel.close().wait()

            } catch {
                print("onFetchGrant_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    
    func onFetchAuth_gRPC(_ granterAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = granterAddress }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.granterAuth = response.account
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchAuth_gRPC failed: \(error)")
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
//                    print("Balance ", response)
                    response.balances.forEach { balance in
                        if (balance.denom == self.chainConfig!.stakeDenom) {
                            self.granterBalance = Coin.init(balance.denom, balance.amount)
                        }
                    }
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
//                    print("Delegations ", response)
                    response.delegationResponses.forEach { delegationResponse in
                        self.granterDelegation.append(delegationResponse)
                    }
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
//                    print("Undelegation ", response)
                    response.unbondingResponses.forEach { unbondingResponse in
                        self.granterUnbonding.append(unbondingResponse)
                    }
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
//                    print("Reward ", response)
                    response.rewards.forEach { reward in
                        self.granterReward.append(reward)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchStakingRewards_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchCommission_gRPC(_ granterAddress: String) {
        let valOpAddress = WKey.getOpAddressFromAddress(granterAddress, chainConfig)
//        print("valOpAddress ", valOpAddress)
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Distribution_V1beta1_QueryValidatorCommissionRequest.with { $0.validatorAddress = valOpAddress }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).validatorCommission(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    print("Commission ", response)
                    response.commission.commission.forEach { commission in
                        if (commission.denom == self.chainConfig!.stakeDenom) {
                            let commissionAmount = WUtils.plainStringToDecimal(commission.amount).multiplying(byPowerOf10: -18)
                            self.granterCommission = Coin.init(commission.denom, commissionAmount.stringValue)
                        }
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchCommission_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func checkAccountType() {
        guard let rawAccount = granterAuth else { return }
        if (chainConfig?.chainType == .DESMOS_MAIN && rawAccount.typeURL.contains(Desmos_Profiles_V1beta1_Profile.protoMessageName)) {
            if let profileAccount = try? Desmos_Profiles_V1beta1_Profile.init(serializedData: rawAccount.value) {
                checkVesting(chainConfig?.chainType, profileAccount.account)
            } else {
                checkVesting(chainConfig?.chainType, rawAccount)
            }
        }
        checkVesting(chainConfig?.chainType, rawAccount)
    }
    
    func checkVesting(_ chain: ChainType?, _ rawAccount: Google_Protobuf2_Any) {
        let stakingDenom = chainConfig!.stakeDenom
        var dpAvailable = NSDecimalNumber.zero
        var dpVesting = NSDecimalNumber.zero
        var originalVesting = NSDecimalNumber.zero
        var remainVesting = NSDecimalNumber.zero
        var delegatedVesting = NSDecimalNumber.zero
        
        if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)) {
            let vestingAccount = try! Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value)
            dpAvailable = NSDecimalNumber.init(string: granterBalance?.amount)
            vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                if (coin.denom == stakingDenom) {
                    originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                }
            })
            vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                if (coin.denom == stakingDenom) {
                    delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                }
            })
            remainVesting = WUtils.onParsePeriodicRemainVestingsAmountByDenom(vestingAccount, stakingDenom)
            dpVesting = remainVesting.subtracting(delegatedVesting)
            dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
            if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                dpAvailable = dpAvailable.subtracting(remainVesting).adding(delegatedVesting);
            }
            granterAvailable = Coin.init(stakingDenom, dpAvailable.stringValue)
            granterVesting = Coin.init(stakingDenom, dpVesting.stringValue)
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)) {
            let vestingAccount = try! Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value)
            dpAvailable = NSDecimalNumber.init(string: granterBalance?.amount)
            vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                if (coin.denom == stakingDenom) {
                    originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                }
            })
            vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                if (coin.denom == stakingDenom) {
                    delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                }
            })
            let cTime = Date().millisecondsSince1970
            let vestingStart = vestingAccount.startTime * 1000
            let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
            if (cTime < vestingStart) {
                remainVesting = originalVesting
            } else if (cTime > vestingEnd) {
                remainVesting = NSDecimalNumber.zero
            } else {
                let progress = ((Float)(cTime - vestingStart)) / ((Float)(vestingEnd - vestingStart))
                remainVesting = originalVesting.multiplying(by: NSDecimalNumber.init(value: 1 - progress), withBehavior: WUtils.handler0Up)
            }
            dpVesting = remainVesting.subtracting(delegatedVesting)
            dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
            if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                dpAvailable = dpAvailable.subtracting(remainVesting).adding(delegatedVesting);
            }
            granterAvailable = Coin.init(stakingDenom, dpAvailable.stringValue)
            granterVesting = Coin.init(stakingDenom, dpVesting.stringValue)
            
        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)) {
            let vestingAccount = try! Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value)
            dpAvailable = NSDecimalNumber.init(string: granterBalance?.amount)
            vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                if (coin.denom == stakingDenom) {
                    originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                }
            })
            vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                if (coin.denom == stakingDenom) {
                    delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                }
            })
            let cTime = Date().millisecondsSince1970
            let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
            if (cTime < vestingEnd) {
                remainVesting = originalVesting
            }
            dpVesting = remainVesting.subtracting(delegatedVesting)
            dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
            if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                dpAvailable = dpAvailable.subtracting(remainVesting).adding(delegatedVesting);
            }
            granterAvailable = Coin.init(stakingDenom, dpAvailable.stringValue)
            granterVesting = Coin.init(stakingDenom, dpVesting.stringValue)
            
        } else {
            granterAvailable = Coin.init(stakingDenom, granterBalance!.amount)
            granterVesting = Coin.init(stakingDenom, "0")
        }
    }
    
    func getDelegatedSum() -> Coin {
        var sum = NSDecimalNumber.zero
        granterDelegation.forEach { delegation in
            sum = sum.adding(WUtils.plainStringToDecimal(delegation.balance.amount))
        }
        return Coin.init(chainConfig!.stakeDenom, sum.stringValue)
    }
    
    func getUnbondingSum() -> Coin {
        var sum = NSDecimalNumber.zero
        granterUnbonding.forEach { unbonding in
            unbonding.entries.forEach { entry in
                sum = sum.adding(WUtils.plainStringToDecimal(entry.balance))
            }
        }
        return Coin.init(chainConfig!.stakeDenom, sum.stringValue)
    }
    
    func getRewardSum() -> Coin {
        var sum = NSDecimalNumber.zero
        granterReward.forEach { reward in
            reward.reward.forEach { rewardCoin in
                if (rewardCoin.denom == chainConfig!.stakeDenom) {
                    sum = sum.adding(WUtils.plainStringToDecimal(rewardCoin.amount))
                }
            }
        }
        sum = sum.multiplying(byPowerOf10: -18)
        return Coin.init(chainConfig!.stakeDenom, sum.stringValue)
    }
    
    
    
    
    
    func getSendAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Bank_V1beta1_MsgSend.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Bank_V1beta1_SendAuthorization.protoMessageName)) {
                result = grant
                return
            }
        }
        return result
    }
    
    func getDelegateAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Staking_V1beta1_MsgDelegate.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant.authorization.value)
                if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.delegate) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getUndelegateAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Staking_V1beta1_MsgUndelegate.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant.authorization.value)
                if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.undelegate) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getRedelegateAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Staking_V1beta1_MsgBeginRedelegate.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant.authorization.value)
                if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.redelegate) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getRewardAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.protoMessageName)) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getCommissionAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission.protoMessageName)) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getVoteAuth() -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Gov_V1beta1_MsgVote.protoMessageName)) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
}
