//
//  VaildatorDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 04/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import GRPC
import NIO

class VaildatorDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var validatorDetailTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    //grpc
    var mFetchCnt = 0
    var mMyValidator = false
    var mValidator_gRPC: Cosmos_Staking_V1beta1_Validator?
    var mSelfDelegationInfo_gRPC: Cosmos_Staking_V1beta1_DelegationResponse?
    var mApiCustomNewHistories = Array<ApiHistoryNewCustom>()
        
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.validatorDetailTableView.delegate = self
        self.validatorDetailTableView.dataSource = self
        self.validatorDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.validatorDetailTableView.register(UINib(nibName: "ValidatorDetailMyDetailCell", bundle: nil), forCellReuseIdentifier: "ValidatorDetailMyDetailCell")
        self.validatorDetailTableView.register(UINib(nibName: "ValidatorDetailMyActionCell", bundle: nil), forCellReuseIdentifier: "ValidatorDetailMyActionCell")
        self.validatorDetailTableView.register(UINib(nibName: "ValidatorDetailCell", bundle: nil), forCellReuseIdentifier: "ValidatorDetailCell")
        self.validatorDetailTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        self.validatorDetailTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        self.validatorDetailTableView.rowHeight = UITableView.automaticDimension
        self.validatorDetailTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            self.validatorDetailTableView.sectionHeaderTopPadding = 0.0
        }
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onFetch), for: .valueChanged)
        refresher.tintColor = UIColor(named: "_font05")
        validatorDetailTableView.addSubview(refresher)
        
        self.loadingImg.onStartAnimation()
        self.onFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_validator_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_validator_detail", comment: "")
    }
    
    @objc func onFetch() {
        self.mFetchCnt = 6
        BaseData.instance.mMyDelegations_gRPC.removeAll()
        BaseData.instance.mMyUnbondings_gRPC.removeAll()
        BaseData.instance.mMyReward_gRPC.removeAll()
        
        onFetchSingleValidator_gRPC(mValidator_gRPC!.operatorAddress)
        onFetchValidatorSelfBond_gRPC(WKey.getAddressFromOpAddress(mValidator_gRPC!.operatorAddress, chainConfig), mValidator_gRPC!.operatorAddress)
        onFetchDelegations_gRPC(account!.account_address, 0)
        onFetchUndelegations_gRPC(account!.account_address, 0)
        onFetchRewards_gRPC(account!.account_address)
        onFetchNewApiHistoryCustom(account!.account_address, mValidator_gRPC!.operatorAddress)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
//        print("onFetchFinished ", self.mFetchCnt)
        self.validatorDetailTableView.reloadData()
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
        self.validatorDetailTableView.isHidden = false
        self.refresher.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if (BaseData.instance.mMyValidators_gRPC.contains{ $0.operatorAddress == mValidator_gRPC?.operatorAddress }) { return 2 }
            else { return 1 }
        } else {
            return self.mApiCustomNewHistories.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = ValidatorDetailHistoryHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if (indexPath.row == 0 && BaseData.instance.mMyValidators_gRPC.contains{ $0.operatorAddress == mValidator_gRPC?.operatorAddress }) {
                return onSetMyValidatorItems(tableView, indexPath)
            } else if (indexPath.row == 0 && !BaseData.instance.mMyValidators_gRPC.contains{ $0.operatorAddress == mValidator_gRPC?.operatorAddress }) {
                return onSetOtherValidatorItems(tableView, indexPath)
            } else {
                return onSetActionItems(tableView, indexPath)
            }
            
        } else {
            return onSetHistoryItems(tableView, indexPath)
        }
    }
    
    
    //grpc
    func onSetMyValidatorItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ValidatorDetailMyDetailCell") as? ValidatorDetailMyDetailCell
        cell?.updateView(self.mValidator_gRPC, self.mSelfDelegationInfo_gRPC, self.chainConfig)
        cell?.actionTapUrl = {
            guard let url = URL(string: self.mValidator_gRPC?.description_p.website ?? "") else { return }
            if (UIApplication.shared.canOpenURL(url)) {
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.modalPresentationStyle = .popover
                self.present(safariViewController, animated: true, completion: nil)
            }
        }
        return cell!
    }
    
    func onSetOtherValidatorItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ValidatorDetailCell") as? ValidatorDetailCell
        cell?.updateView(self.mValidator_gRPC, self.mSelfDelegationInfo_gRPC, self.chainConfig)
        cell?.actionTapUrl = {
            guard let url = URL(string: self.mValidator_gRPC?.description_p.website ?? "") else { return }
            if (UIApplication.shared.canOpenURL(url)) {
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.modalPresentationStyle = .popover
                self.present(safariViewController, animated: true, completion: nil)
            }
        }
        cell?.actionDelegate = {
            if (self.mValidator_gRPC?.jailed == true) {
                self.onShowToast(NSLocalizedString("error_jailded_delegate", comment: ""))
                return
            } else {
                self.onStartDelegate()
            }
        }
        return cell!
    }
    
    func onSetActionItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ValidatorDetailMyActionCell") as? ValidatorDetailMyActionCell
        cell?.updateView(self.mValidator_gRPC, self.chainConfig)
        cell?.actionDelegate = {
            if (self.mValidator_gRPC?.jailed == true) {
                self.onShowToast(NSLocalizedString("error_jailded_delegate", comment: ""))
            } else {
                self.onStartDelegate()
            }
        }
        cell?.actionUndelegate = {
            self.onStartUndelegate()
        }
        cell?.actionRedelegate = {
            self.onCheckRedelegate()
        }
        cell?.actionReward = {
            self.onStartGetSingleReward()
        }
        cell?.actionReinvest = {
            self.onCheckReinvest()
        }
        return cell!
    }
    
    func onSetHistoryItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
        cell?.bindHistoryView(chainConfig!, mApiCustomNewHistories[indexPath.row], account!.account_address)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let history = mApiCustomNewHistories[indexPath.row]
            let link = WUtils.getTxExplorer(chainConfig, history.data!.txhash!)
            guard let url = URL(string: link) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        } else {
            return 30
        }
    }
    
    
    //gRPC
    func onFetchSingleValidator_gRPC(_ opAddress: String) {
//        print("onFetchSingleValidator_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Staking_V1beta1_QueryValidatorRequest.with {
                $0.validatorAddr = opAddress
            }
            do {
                let response = try Cosmos_Staking_V1beta1_QueryClient(channel: channel).validator(req).response.wait()
//                print("onFetchSingleValidator_gRPC: \(response.validator)")
                self.mValidator_gRPC = response.validator
            } catch {
                print("onFetchgRPCBondedValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
    }
    
    func onFetchValidatorSelfBond_gRPC(_ address: String, _ opAddress: String) {
//        print("onFetchValidatorSelfBond_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Staking_V1beta1_QueryDelegationRequest.with {
                $0.delegatorAddr = address
                $0.validatorAddr = opAddress
            }
            do {
                let response = try Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegation(req).response.wait()
//                print("onFetchValidatorSelfBond_gRPC: \(response.delegationResponse)")
                self.mSelfDelegationInfo_gRPC = response.delegationResponse
            } catch {
                print("onFetchValidatorSelfBond_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
        
    }
    
    func onFetchDelegations_gRPC(_ address: String, _ offset: Int) {
//        print("onFetchDelegations_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with {
                $0.delegatorAddr = address
            }
            do {
                let response = try Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorDelegations(req).response.wait()
                response.delegationResponses.forEach { delegationResponse in
                    BaseData.instance.mMyDelegations_gRPC.append(delegationResponse)
                }
            } catch {
                print("onFetchDelegations_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
    }
    
    func onFetchUndelegations_gRPC(_ address: String, _ offset: Int) {
//        print("onFetchUndelegations_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with {
                $0.delegatorAddr = address
            }
            do {
                let response = try Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorUnbondingDelegations(req).response.wait()
                response.unbondingResponses.forEach { unbondingResponse in
                    BaseData.instance.mMyUnbondings_gRPC.append(unbondingResponse)
                }
            } catch {
                print("onFetchUndelegations_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
    }
    
    func onFetchRewards_gRPC(_ address: String) {
//        print("onFetchRewards_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with {
                $0.delegatorAddress = address
            }
            do {
                let response = try Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegationTotalRewards(req).response.wait()
                response.rewards.forEach { reward in
                    BaseData.instance.mMyReward_gRPC.append(reward)
                }
            } catch {
                print("onFetchgRPCRewards failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
    }
    
    func onFetchRedelegation_gRPC(_ address: String, _ toValAddress: String) {
//        print("onFetchRedelegation_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Staking_V1beta1_QueryRedelegationsRequest.with {
                $0.delegatorAddr = address
            }
            do {
                let response = try Cosmos_Staking_V1beta1_QueryClient(channel: channel).redelegations(req).response.wait()
                let redelegation_responses = response.redelegationResponses
                for redelegation in redelegation_responses {
                    if (redelegation.redelegation.validatorDstAddress == self.mValidator_gRPC?.operatorAddress) {
                        DispatchQueue.main.async(execute: { self.onShowToast(NSLocalizedString("error_redelegation_limitted", comment: "")) });
                        return
                    }
                }
                DispatchQueue.main.async(execute: { self.onStartRedelegate() });
                
            } catch {
                print("onFetchRedelegation_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
    }
    
    func onFetchRewardsAddress_gRPC(_ address: String) {
//        print("onFetchRewardsAddress_gRPC")
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with {
                $0.delegatorAddress = address
            }
            do {
                let response = try Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegatorWithdrawAddress(req).response.wait()
                if (response.withdrawAddress.replacingOccurrences(of: "\"", with: "") != address) {
                    DispatchQueue.main.async(execute: { self.onShowReInvsetFailDialog() });
                    return;
                } else {
                    DispatchQueue.main.async(execute: { self.onStartReInvest() });
                }
            } catch {
                print("onFetchRedelegation_gRPC failed: \(error)")
            }
            
        }
    }
    
    func onFetchNewApiHistoryCustom(_ address: String, _ valAddress: String) {
        print("onFetchNewApiHistoryCustom ", address)
        let url = BaseNetWork.accountStakingHistory(chainType!, address, valAddress)
        let request = Alamofire.request(url, method: .get, parameters: ["limit":"50"], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                self.mApiCustomNewHistories.removeAll()
                if let histories = res as? Array<NSDictionary> {
                    for rawHistory in histories {
                        self.mApiCustomNewHistories.append(ApiHistoryNewCustom.init(rawHistory))
                    }
                }
                
            case .failure(let error):
                print("onFetchNewApiHistoryCustom ", error)
            }
            self.onFetchFinished()
        }
    }
    
    
    // user Actions
    func onStartDelegate() {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (BaseData.instance.getDelegatable_gRPC(chainConfig).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_available", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_DELEGATE
        txVC.mTargetValidator_gRPC = mValidator_gRPC
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onStartUndelegate() {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (BaseData.instance.mMyDelegations_gRPC.filter { $0.delegation.validatorAddress == mValidator_gRPC?.operatorAddress}.first == nil) {
            self.onShowToast(NSLocalizedString("error_not_undelegate", comment: ""))
            return
        }
        if let unbonding = BaseData.instance.mMyUnbondings_gRPC.filter({ $0.validatorAddress == mValidator_gRPC?.operatorAddress}).first {
            if (unbonding.entries.count >= 7) {
                self.onShowToast(NSLocalizedString("error_unbonding_count_over", comment: ""))
                return
            }
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mTargetValidator_gRPC = mValidator_gRPC
        txVC.mType = TASK_TYPE_UNDELEGATE
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCheckRedelegate() {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (BaseData.instance.mMyDelegations_gRPC.filter { $0.delegation.validatorAddress == mValidator_gRPC?.operatorAddress}.first == nil) {
            self.onShowToast(NSLocalizedString("error_not_redelegate", comment: ""))
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        self.onFetchRedelegation_gRPC(account!.account_address, mValidator_gRPC!.operatorAddress)
    }
    
    func onStartRedelegate() {
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mTargetValidator_gRPC = mValidator_gRPC
        txVC.mType = TASK_TYPE_REDELEGATE
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onStartGetSingleReward() {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        let reward = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), mValidator_gRPC?.operatorAddress)
        if (reward.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        var validators = Array<Cosmos_Staking_V1beta1_Validator>()
        validators.append(mValidator_gRPC!)
        txVC.mRewardTargetValidators_gRPC = validators
        txVC.mType = TASK_TYPE_CLAIM_STAKE_REWARD
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCheckReinvest() {
        if(!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        let reward = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), mValidator_gRPC?.operatorAddress)
        if (reward.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        self.onFetchRewardsAddress_gRPC(account!.account_address)
    }
    
    func onStartReInvest() {
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mTargetValidator_gRPC = self.mValidator_gRPC
        txVC.mType = TASK_TYPE_REINVEST
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onShowReInvsetFailDialog() {
        let alert = UIAlertController(title: NSLocalizedString("error_reward_address_changed_title", comment: ""), message: NSLocalizedString("error_reward_address_changed_msg", comment: ""), preferredStyle: .alert)
        if #available(iOS 13.0, *) { alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

