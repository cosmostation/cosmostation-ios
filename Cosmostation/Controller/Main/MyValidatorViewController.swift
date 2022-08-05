//
//  MyValidatorViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class MyValidatorViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myValidatorCnt: UILabel!
    @IBOutlet weak var btnSort: UIView!
    @IBOutlet weak var sortType: UILabel!
    @IBOutlet weak var myValidatorTableView: UITableView!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.myValidatorTableView.delegate = self
        self.myValidatorTableView.dataSource = self
        self.myValidatorTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.myValidatorTableView.register(UINib(nibName: "MyValidatorCell", bundle: nil), forCellReuseIdentifier: "MyValidatorCell")
        self.myValidatorTableView.register(UINib(nibName: "ClaimRewardAllCell", bundle: nil), forCellReuseIdentifier: "ClaimRewardAllCell")
        self.myValidatorTableView.register(UINib(nibName: "PromotionCell", bundle: nil), forCellReuseIdentifier: "PromotionCell")
        self.myValidatorTableView.rowHeight = UITableView.automaticDimension
        self.myValidatorTableView.estimatedRowHeight = UITableView.automaticDimension

        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.myValidatorTableView.addSubview(refresher)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onStartSort))
        self.btnSort.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTabVC = ((self.parent)?.parent)?.parent as? MainTabViewController
        self.balances = BaseData.instance.selectBalanceById(accountId: self.account!.account_id)
        self.onSortingMy()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.onSortingMy()
        self.refresher.endRefreshing()
    }
    
    @objc func onSortingMy() {
        self.myValidatorCnt.text = String(BaseData.instance.mMyValidators_gRPC.count)
        
        if (BaseData.instance.getMyValidatorSort() == 0) {
            self.sortType.text = NSLocalizedString("sort_by_my_delegate", comment: "")
            sortByDelegated()
        } else if (BaseData.instance.getMyValidatorSort() == 1) {
            self.sortType.text = NSLocalizedString("sort_by_name", comment: "")
            sortByName()
        } else {
            self.sortType.text = NSLocalizedString("sort_by_reward", comment: "")
            sortByReward()
        }
        self.myValidatorTableView.reloadData()
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (BaseData.instance.mMyValidators_gRPC.count < 1) { return 1; }
        else if (BaseData.instance.mMyValidators_gRPC.count == 1) { return 1; }
        else { return BaseData.instance.mMyValidators_gRPC.count + 1; }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (BaseData.instance.mMyValidators_gRPC.count < 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"PromotionCell") as? PromotionCell
            cell?.cardView.backgroundColor = chainConfig?.chainColorBG
            return cell!
            
        } else if (BaseData.instance.mMyValidators_gRPC.count == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"MyValidatorCell") as? MyValidatorCell
            cell?.updateView(BaseData.instance.mMyValidators_gRPC[indexPath.row], self.chainConfig)
            return cell!
            
        } else {
            if (indexPath.row == BaseData.instance.mMyValidators_gRPC.count) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"ClaimRewardAllCell") as? ClaimRewardAllCell
//                cell?.updateView(chainConfig)
//                cell?.delegate = self
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"MyValidatorCell") as? MyValidatorCell
                cell?.updateView(BaseData.instance.mMyValidators_gRPC[indexPath.row], self.chainConfig)
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (BaseData.instance.mMyValidators_gRPC.count == 0) {
            if let cosmostation = BaseData.instance.mAllValidators_gRPC.filter({ $0.description_p.moniker == "Cosmostation" }).first {
                self.onStartDelegate(cosmostation, nil)
            }
        }
        if (BaseData.instance.mMyValidators_gRPC.count > 0 && indexPath.row != BaseData.instance.mMyValidators_gRPC.count) {
            let validatorDetailVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VaildatorDetailViewController") as! VaildatorDetailViewController
            validatorDetailVC.mValidator_gRPC = BaseData.instance.mMyValidators_gRPC[indexPath.row]
            validatorDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(validatorDetailVC, animated: true)
        }
    }
    
    /*
    func didTapClaimAll(_ sender: UIButton) {
        if (!self.account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        var claimAbleValidators = Array<Cosmos_Staking_V1beta1_Validator>()
        var toClaimValidators  = Array<Cosmos_Staking_V1beta1_Validator>()
        let mainDenom = chainConfig!.stakeDenom
        
        BaseData.instance.mMyValidators_gRPC.forEach { validator in
            if (BaseData.instance.getReward_gRPC(mainDenom, validator.operatorAddress).compare(NSDecimalNumber.init(string: "0.001")).rawValue > 0) {
                claimAbleValidators.append(validator)
            }
        }
        if (claimAbleValidators.count == 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_reward", comment: ""))
            return;
        }
        claimAbleValidators.sort {
            let reward0 = BaseData.instance.getReward_gRPC(mainDenom, $0.operatorAddress)
            let reward1 = BaseData.instance.getReward_gRPC(mainDenom, $1.operatorAddress)
            return reward0.compare(reward1).rawValue > 0 ? true : false
        }
        if (claimAbleValidators.count > 16) {
            toClaimValidators = Array(claimAbleValidators[0..<16])
        } else {
            toClaimValidators = claimAbleValidators
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mRewardTargetValidators_gRPC = toClaimValidators
        txVC.mType = TASK_TYPE_CLAIM_STAKE_REWARD
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    */
    
    func onStartDelegate(_ validator_gRPC: Cosmos_Staking_V1beta1_Validator?, _ validator: Validator?) {
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
        txVC.mTargetValidator_gRPC = validator_gRPC
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @objc func onStartSort() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if #available(iOS 13.0, *) { alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sort_by_name", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            BaseData.instance.setMyValidatorSort(1)
            self.onSortingMy()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sort_by_my_delegate", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            BaseData.instance.setMyValidatorSort(0)
            self.onSortingMy()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sort_by_reward", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            BaseData.instance.setMyValidatorSort(2)
            self.onSortingMy()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sortByName() {
        BaseData.instance.mMyValidators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return $0.description_p.moniker < $1.description_p.moniker
        }
    }
    
    func sortByDelegated() {
        BaseData.instance.mMyValidators_gRPC.sort {
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            let firstVal = BaseData.instance.getDelegated_gRPC($0.operatorAddress)
            let seconVal = BaseData.instance.getDelegated_gRPC($1.operatorAddress)
            return firstVal.compare(seconVal).rawValue > 0 ? true : false
        }
    }
    
    func sortByReward() {
        BaseData.instance.mMyValidators_gRPC.sort {
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            let firstVal = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(self.chainConfig), $0.operatorAddress)
            let seconVal = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(self.chainConfig), $1.operatorAddress)
            return firstVal.compare(seconVal).rawValue > 0 ? true : false
        }
    }
}
