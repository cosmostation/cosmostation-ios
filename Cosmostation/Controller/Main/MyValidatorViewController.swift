//
//  MyValidatorViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftKeychainWrapper

class MyValidatorViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, PasswordViewDelegate {
    
    let EASY_MODE_CLAIM_REWARDS = 0
    let EASY_MODE_COMPONDING = 1
    
    @IBOutlet weak var myValidatorLabel: UILabel!
    @IBOutlet weak var myValidatorCnt: UILabel!
    @IBOutlet weak var btnSort: UIView!
    @IBOutlet weak var sortType: UILabel!
    @IBOutlet weak var myValidatorTableView: UITableView!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
    var easyMode = -1
    
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
        self.refresher.tintColor = UIColor.font05
        self.myValidatorTableView.addSubview(refresher)
        
        self.myValidatorLabel.text = NSLocalizedString("str_validators", comment: "")
        let tap = UITapGestureRecognizer(target: self, action: #selector(onStartSort))
        self.btnSort.addGestureRecognizer(tap)
        self.getKey()
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
        else { return BaseData.instance.mMyValidators_gRPC.count + 1; }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (BaseData.instance.mMyValidators_gRPC.count < 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"PromotionCell") as? PromotionCell
            cell?.cardView.backgroundColor = chainConfig?.chainColorBG
            return cell!
            
        } else {
            if (indexPath.row == BaseData.instance.mMyValidators_gRPC.count) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"ClaimRewardAllCell") as? ClaimRewardAllCell
                cell?.updateView(chainConfig)
                cell?.actionRewardAll = { self.onCheckEasyClaim() }
                cell?.actionCompunding = { self.onCheckEasyCompounding() }
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
    
    func onCheckEasyClaim() {
        if (!self.account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let toClaimRewards = getClaimableReward()
        if (toClaimRewards.count <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_reward", comment: ""))
            return
        }
        self.easyMode = EASY_MODE_CLAIM_REWARDS
        self.onStartPinCode()
    }
    
    func onStartEasyClaim(_ selectFee: Int) {
        self.showWaittingAlert()
        var feeGasAmount = NSDecimalNumber.init(string: "500000")
        let feeInfo = BaseData.instance.mParam!.getFeeInfos()
        let feeData = feeInfo[selectFee].FeeDatas[0]
        var fee: Fee!
        var feeCoin: Coin!
        if (chainType == .SIF_MAIN) {
            feeCoin = Coin.init(feeData.denom!, "100000000000000000")
        } else if (chainType == .CHIHUAHUA_MAIN) {
            if (selectFee == 0) {
                feeCoin = Coin.init(feeData.denom!, "1000000")
            } else if (selectFee == 1) {
                feeCoin = Coin.init(feeData.denom!, "5000000")
            } else {
                feeCoin = Coin.init(feeData.denom!, "10000000")
            }
        } else {
            let amount = (feeData.gasRate)!.multiplying(by: feeGasAmount, withBehavior: WUtils.handler0Up)
            feeCoin = Coin.init(feeData.denom!, amount.stringValue)
        }
        fee = Fee.init(feeGasAmount.stringValue, [feeCoin])
        
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let authReq = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = self.account!.account_address }
                if let authRes = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(authReq, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    let simulReq = Signer.genSimulateClaimRewardsTxgRPC(authRes, self.account!.account_pubkey_type, self.getClaimableReward(), fee, "", self.privateKey!, self.publicKey!, self.chainType!)
                    if let simulRes = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).simulate(simulReq, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        if (self.chainType == .IXO_MAIN) {
                            feeGasAmount = NSDecimalNumber.init(value: simulRes.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 3), withBehavior: WUtils.handler0Up)
                        } else {
                            feeGasAmount = NSDecimalNumber.init(value: simulRes.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 1.5), withBehavior: WUtils.handler0Up)
                        }
                        if (self.chainType != .SIF_MAIN && self.chainType != .CHIHUAHUA_MAIN) {
                            let amount = (feeData.gasRate)!.multiplying(by: feeGasAmount, withBehavior: WUtils.handler0Up)
                            feeCoin = Coin.init(feeData.denom!, amount.stringValue)
                        }
                        fee = Fee.init(feeGasAmount.stringValue, [feeCoin])
                        let txReq = Signer.genSignedClaimRewardsTxgRPC(authRes, self.account!.account_pubkey_type, self.getClaimableReward(), fee, "",  self.privateKey!, self.publicKey!, self.chainType!)
                        if let txRes = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(txReq).response.wait() {
                            DispatchQueue.main.async(execute: {
                                if (self.waitAlert != nil) {
                                    self.waitAlert?.dismiss(animated: true, completion: {
                                        self.onStartTxDetailgRPC(txRes)
                                    })
                                }
                            });
                        }
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onStartEasyClaim failed: \(error)")
                if (self.waitAlert != nil) {
                    self.waitAlert?.dismiss(animated: true, completion: {
                        self.onShowToast(NSLocalizedString("error_network", comment: "") + "\n" + "\(error)")
                    })
                }
            }
        }
    }
    
    func onCheckEasyCompounding() {
        if (!self.account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let toClaimRewards = getClaimableReward()
        if (toClaimRewards.count <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_reward", comment: ""))
            return
        }
        self.easyMode = EASY_MODE_COMPONDING
        self.onStartPinCode()
    }
    
    func onStartEasyCompounding(_ selectFee: Int) {
        self.showWaittingAlert()
        var feeGasAmount = NSDecimalNumber.init(string: "500000")
        let feeInfo = BaseData.instance.mParam!.getFeeInfos()
        let feeData = feeInfo[selectFee].FeeDatas[0]
        var fee: Fee!
        var feeCoin: Coin!
        if (chainType == .SIF_MAIN) {
            feeCoin = Coin.init(feeData.denom!, "100000000000000000")
        } else if (chainType == .CHIHUAHUA_MAIN) {
            if (selectFee == 0) {
                feeCoin = Coin.init(feeData.denom!, "1000000")
            } else if (selectFee == 1) {
                feeCoin = Coin.init(feeData.denom!, "5000000")
            } else {
                feeCoin = Coin.init(feeData.denom!, "10000000")
            }
        } else {
            let amount = (feeData.gasRate)!.multiplying(by: feeGasAmount, withBehavior: WUtils.handler0Up)
            feeCoin = Coin.init(feeData.denom!, amount.stringValue)
        }
        fee = Fee.init(feeGasAmount.stringValue, [feeCoin])
        
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let rewardAddressReq = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = self.account!.account_address }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegatorWithdrawAddress(rewardAddressReq).response.wait() {
                    if (response.withdrawAddress.replacingOccurrences(of: "\"", with: "") == self.account!.account_address) {
                        let authReq = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = self.account!.account_address }
                        if let authRes = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(authReq, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                            let simulReq = Signer.genSimulateCompounding(authRes, self.account!.account_pubkey_type, self.getClaimableReward(), fee, "", self.privateKey!, self.publicKey!, self.chainType!)
                            if let simulRes = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).simulate(simulReq, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                                feeGasAmount = NSDecimalNumber.init(value: simulRes.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 1.1), withBehavior: WUtils.handler0Up)
                                if (self.chainType != .SIF_MAIN && self.chainType != .CHIHUAHUA_MAIN) {
                                    let amount = (feeData.gasRate)!.multiplying(by: feeGasAmount, withBehavior: WUtils.handler0Up)
                                    feeCoin = Coin.init(feeData.denom!, amount.stringValue)
                                }
                                fee = Fee.init(feeGasAmount.stringValue, [feeCoin])
                                let txReq = Signer.genSignedCompounding(authRes, self.account!.account_pubkey_type, self.getClaimableReward(), fee, "",  self.privateKey!, self.publicKey!, self.chainType!)
                                if let txRes = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(txReq).response.wait() {
                                    DispatchQueue.main.async(execute: {
                                        if (self.waitAlert != nil) {
                                            self.waitAlert?.dismiss(animated: true, completion: {
                                                self.onStartTxDetailgRPC(txRes)
                                            })
                                        }
                                    });
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async(execute: {
                            if (self.waitAlert != nil) {
                                self.waitAlert?.dismiss(animated: true, completion: {
                                    self.onShowToast(NSLocalizedString("error_reward_address_changed_msg", comment: ""))
                                })
                            }
                        });
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onStartEasyCompounding failed: \(error)")
                DispatchQueue.main.async(execute: {
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.onShowToast(NSLocalizedString("error_network", comment: "") + "\n" + "\(error)")
                        })
                    }
                });
            }
        }
        
    }
    
    func onShowFeeDialog() {
        let feeInfo = BaseData.instance.mParam!.getFeeInfos()
        if (feeInfo.count == 1) {
            if (self.easyMode == EASY_MODE_CLAIM_REWARDS) { self.onStartEasyClaim(0) }
            else { self.onStartEasyCompounding(0) }
            
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("tx_set_fee", comment: ""), message: "", preferredStyle: .actionSheet)
            alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
            let feeInfo = BaseData.instance.mParam!.getFeeInfos()
            for i in 0 ..< Int(feeInfo.count) {
                let feeAction = UIAlertAction(title: feeInfo[i].title + " Fee", style: .default) { (_) -> Void in
                    if (self.easyMode == self.EASY_MODE_CLAIM_REWARDS) { self.onStartEasyClaim(i) }
                    else { self.onStartEasyCompounding(i) }
                }
                alertController.addAction(feeAction)
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            DispatchQueue.main.async { self.present(alertController, animated: true, completion: nil) }
        }
    }
    
    func onStartPinCode() {
        if (BaseData.instance.isAutoPass()) {
            self.onShowFeeDialog()
            
        } else {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_CHECK_TX), animated: false)
        }
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.onShowFeeDialog()
            });
        }
    }
    
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
        alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
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
            let firstVal = BaseData.instance.getReward_gRPC(chainConfig!.stakeDenom, $0.operatorAddress)
            let seconVal = BaseData.instance.getReward_gRPC(chainConfig!.stakeDenom, $1.operatorAddress)
            return firstVal.compare(seconVal).rawValue > 0 ? true : false
        }
    }
    
    func getClaimableReward() -> Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward> {
        var result = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
        if let msAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == chainConfig!.stakeDenom }).first {
            let decimal = msAsset.decimals
            let soreted = BaseData.instance.mMyReward_gRPC.sorted {
                let firstCoin = $0.reward.filter({ $0.denom == chainConfig?.stakeDenom }).first
                let secondCoin = $1.reward.filter({ $0.denom == chainConfig?.stakeDenom }).first
                let firstAmount = NSDecimalNumber.init(string: firstCoin?.amount)
                let secondAmount = NSDecimalNumber.init(string: secondCoin?.amount)
                return firstAmount.compare(secondAmount).rawValue > 0 ? true : false
            }
            soreted.forEach { rawReward in
                if let stakeCoin = rawReward.reward.filter({ $0.denom == chainConfig?.stakeDenom }).first {
                    var rewardAmount = NSDecimalNumber.init(string: stakeCoin.amount)
                    rewardAmount = rewardAmount.multiplying(byPowerOf10: -18).multiplying(byPowerOf10: -decimal)
                    if (rewardAmount.compare(NSDecimalNumber.init(string: "0.01")).rawValue > 0) {
                        result.append(rawReward)
                    }
                }
            }
            if (result.count > 10) {
                result = Array(result[0..<10])
            }
        }
        return result
    }
    
    var privateKey: Data?
    var publicKey: Data?
    func getKey() {
        DispatchQueue.global().async {
            if (BaseData.instance.getUsingEnginerMode()) {
                if (self.account?.account_from_mnemonic == true) {
                    if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                        self.privateKey = KeyFac.getPrivateRaw(words, self.account!)
                        self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    }
                    
                } else {
                    if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                        self.privateKey = KeyFac.getPrivateFromString(key)
                        self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    }
                }
                
            } else {
                //Speed up for get privatekey with non-enginerMode
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    self.privateKey = KeyFac.getPrivateFromString(key)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                }
            }
        }
    }
}
