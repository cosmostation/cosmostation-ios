//
//  CosmosStakingInfoVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import SwiftyJSON
import MaterialComponents

class CosmosStakingInfoVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    @IBOutlet weak var tabbar: MDCTabBarView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!
    var rewardAddress: String?
    var validators = [Cosmos_Staking_V1beta1_Validator]()
    var delegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var unbondings = [UnbondingEntry]()
    var rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]?
    var cosmostationValAddress: String?
    
    var initiaValidators = [Initia_Mstaking_V1_Validator]()
    var initiaDelegations = [Initia_Mstaking_V1_DelegationResponse]()
    var initiaUnbondings = [InitiaUnbondingEntry]()
    
    var zenrockValidators = [Zrchain_Validation_ValidatorHV]()
    var zenrockDelegations = [Zrchain_Validation_DelegationResponse]()
    var zenrockUnbondings = [ZenrockUnbondingEntry]()

    var cosmosCryptoVC: CosmosCryptoVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "StakeDelegateCell", bundle: nil), forCellReuseIdentifier: "StakeDelegateCell")
        tableView.register(UINib(nibName: "StakeUnbondingCell", bundle: nil), forCellReuseIdentifier: "StakeUnbondingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        onSetStakeData()
        onSetTabbarView()
    }
    
    override func setLocalizedString() {
        let symbol = selectedChain.assetSymbol(selectedChain.stakingAssetDenom())
        navigationItem.title = String(format: NSLocalizedString("str_coin_manage_stake", comment: ""), symbol)
        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    @objc func onRequestFetch() {
        if (selectedChain.fetchState == .Busy) {
            refresher.endRefreshing()
        } else {
            DispatchQueue.global().async {
                self.selectedChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain.tag == tag) {
            onSetStakeData()
        }
        
        if let cosmosCryptoVC {
            cosmosCryptoVC.onFetchDone(notification)
        }
        
    }
    
    func onSetTabbarView() {
        let stakingTabBar = UITabBarItem(title: "Staking", image: nil, tag: 0)
        let unstakingTabBar = UITabBarItem(title: "Unstaking", image: nil, tag: 1)
        tabbar.items.append(stakingTabBar)
        tabbar.items.append(unstakingTabBar)
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color03, for: .normal)
        tabbar.setTitleColor(.color01, for: .selected)
        tabbar.setSelectedItem(stakingTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixedClusteredLeading
        tabbar.setContentPadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: .scrollable)
    }
    
    func onSetStakeData() {
        Task {
            if let initiaFetcher = (selectedChain as? ChainInitia)?.getInitiaFetcher() {
                rewardAddress = initiaFetcher.rewardAddress
                initiaValidators = initiaFetcher.initiaValidators
                initiaDelegations = initiaFetcher.initiaDelegations
                rewards = initiaFetcher.cosmosRewards
                initiaUnbondings.removeAll()
                
                initiaFetcher.initiaUnbondings?.forEach { unbonding in
                    unbonding.entries.forEach { entry in
                        initiaUnbondings.append(InitiaUnbondingEntry.init(validatorAddress: unbonding.validatorAddress, entry: entry))
                    }
                }
                
                cosmostationValAddress = initiaValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first?.operatorAddress
                initiaDelegations.sort {
                    if ($0.delegation.validatorAddress == cosmostationValAddress) { return true }
                    if ($1.delegation.validatorAddress == cosmostationValAddress) { return false }
                    return Double($0.balance.filter({$0.denom == selectedChain.stakingAssetDenom()}).first!.amount)! > Double($1.balance.filter({$0.denom == selectedChain.stakingAssetDenom()}).first!.amount)!

                }
                initiaUnbondings.sort {
                    return $0.entry.creationHeight < $1.entry.creationHeight
                }
                
            } else if let zenrockFetcher = (selectedChain as? ChainZenrock)?.getZenrockFetcher() {
                rewardAddress = zenrockFetcher.rewardAddress
                zenrockValidators = zenrockFetcher.validators
                zenrockDelegations = zenrockFetcher.delegations
                rewards = zenrockFetcher.cosmosRewards
                zenrockUnbondings.removeAll()
                
                zenrockFetcher.unbondings?.forEach { unbonding in
                    unbonding.entries.forEach { entry in
                        zenrockUnbondings.append(ZenrockUnbondingEntry.init(validatorAddress: unbonding.validatorAddress, entry: entry))
                    }
                }
                
                cosmostationValAddress = zenrockValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first?.operatorAddress
                zenrockDelegations.sort {
                    if ($0.delegation.validatorAddress == cosmostationValAddress) { return true }
                    if ($1.delegation.validatorAddress == cosmostationValAddress) { return false }
                    return Double($0.balance.amount)! > Double($1.balance.amount)!
                }
                zenrockUnbondings.sort {
                    return $0.entry.creationHeight < $1.entry.creationHeight
                }
                
            } else if let cosmosFetcher = selectedChain.getCosmosfetcher() {
                rewardAddress = cosmosFetcher.rewardAddress
                validators = cosmosFetcher.cosmosValidators
                delegations = cosmosFetcher.cosmosDelegations
                rewards = cosmosFetcher.cosmosRewards
                unbondings.removeAll()
                
                cosmosFetcher.cosmosUnbondings?.forEach { unbonding in
                    unbonding.entries.forEach { entry in
                        unbondings.append(UnbondingEntry.init(validatorAddress: unbonding.validatorAddress, entry: entry))
                    }
                }
                
                cosmostationValAddress = validators.filter({ $0.description_p.moniker == "Cosmostation" }).first?.operatorAddress
                delegations.sort {
                    if ($0.delegation.validatorAddress == cosmostationValAddress) { return true }
                    if ($1.delegation.validatorAddress == cosmostationValAddress) { return false }
                    return Double($0.balance.amount)! > Double($1.balance.amount)!
                }
                unbondings.sort {
                    return $0.entry.creationHeight < $1.entry.creationHeight
                }
            }
            
            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onUpdateView() {
        refresher.endRefreshing()
        loadingView.isHidden = true
        tableView.isHidden = false
        tabbar.isHidden = false
        tableView.reloadData()
        if selectedChain is ChainInitia {
            if (tabbar.selectedItem?.tag == 0 ? initiaDelegations.count : initiaUnbondings.count) == 0 {
                emptyStakeImg.isHidden = false
            } else {
                emptyStakeImg.isHidden = true
            }
            
        } else if selectedChain is ChainZenrock {
            if (tabbar.selectedItem?.tag == 0 ? zenrockDelegations.count : zenrockUnbondings.count) == 0 {
                emptyStakeImg.isHidden = false
            } else {
                emptyStakeImg.isHidden = true
            }
            
        } else {
            if (tabbar.selectedItem?.tag == 0 ? delegations.count : unbondings.count) == 0 {
                emptyStakeImg.isHidden = false
            } else {
                emptyStakeImg.isHidden = true
            }
        }
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
        onDelegateTx(nil)
    }
    
    func onDelegateTx(_ toValAddress: String?) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain is ChainInitia) {
            let delegate = CosmosDelegate(nibName: "CosmosDelegate", bundle: nil)
            delegate.selectedChain = selectedChain
            if (toValAddress != nil) {
                delegate.toValidatorInitia = initiaValidators.filter({ $0.operatorAddress == toValAddress }).first
            }
            delegate.modalTransitionStyle = .coverVertical
            self.present(delegate, animated: true)
            
        } else if (selectedChain is ChainZenrock) {
            let delegate = CosmosDelegate(nibName: "CosmosDelegate", bundle: nil)
            delegate.selectedChain = selectedChain
            if (toValAddress != nil) {
                delegate.toValidatorZenrock = zenrockValidators.filter({ $0.operatorAddress == toValAddress }).first
            }
            delegate.modalTransitionStyle = .coverVertical
            self.present(delegate, animated: true)

            
        } else {
            let delegate = CosmosDelegate(nibName: "CosmosDelegate", bundle: nil)
            delegate.selectedChain = selectedChain
            if (toValAddress != nil) {
                delegate.toValidator = validators.filter({ $0.operatorAddress == toValAddress }).first
            }
            delegate.modalTransitionStyle = .coverVertical
            self.present(delegate, animated: true)
        }
    }
    
    func onUndelegateTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain is ChainInitia) {
            let undelegate = CosmosUndelegate(nibName: "CosmosUndelegate", bundle: nil)
            undelegate.selectedChain = selectedChain
            undelegate.fromValidatorInitia = initiaValidators.filter({ $0.operatorAddress == fromValAddress }).first
            undelegate.modalTransitionStyle = .coverVertical
            self.present(undelegate, animated: true)
            
        } else if (selectedChain is ChainZenrock) {
            let undelegate = CosmosUndelegate(nibName: "CosmosUndelegate", bundle: nil)
            undelegate.selectedChain = selectedChain
            undelegate.fromValidatorZenrock = zenrockValidators.filter({ $0.operatorAddress == fromValAddress }).first
            undelegate.modalTransitionStyle = .coverVertical
            self.present(undelegate, animated: true)

        } else {
            let undelegate = CosmosUndelegate(nibName: "CosmosUndelegate", bundle: nil)
            undelegate.selectedChain = selectedChain
            undelegate.fromValidator = validators.filter({ $0.operatorAddress == fromValAddress }).first
            undelegate.modalTransitionStyle = .coverVertical
            self.present(undelegate, animated: true)
        }
    }
    
    func onRedelegateTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain is ChainInitia) {
            let redelegate = CosmosRedelegate(nibName: "CosmosRedelegate", bundle: nil)
            redelegate.selectedChain = selectedChain
            redelegate.fromValidatorInitia = initiaValidators.filter({ $0.operatorAddress == fromValAddress }).first
            redelegate.modalTransitionStyle = .coverVertical
            self.present(redelegate, animated: true)
            
        } else if (selectedChain is ChainZenrock) {
            let redelegate = CosmosRedelegate(nibName: "CosmosRedelegate", bundle: nil)
            redelegate.selectedChain = selectedChain
            redelegate.fromValidatorZenrock = zenrockValidators.filter({ $0.operatorAddress == fromValAddress }).first
            redelegate.modalTransitionStyle = .coverVertical
            self.present(redelegate, animated: true)

        } else {
            let redelegate = CosmosRedelegate(nibName: "CosmosRedelegate", bundle: nil)
            redelegate.selectedChain = selectedChain
            redelegate.fromValidator = validators.filter({ $0.operatorAddress == fromValAddress }).first
            redelegate.modalTransitionStyle = .coverVertical
            self.present(redelegate, animated: true)
        }
    }
    
    func onClaimRewardTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if let claimableReward = rewards?.filter({ $0.validatorAddress == fromValAddress }).first,
           claimableReward.reward.count > 0 {
            let claimRewards = CosmosClaimRewards(nibName: "CosmosClaimRewards", bundle: nil)
            claimRewards.claimableRewards = [claimableReward]
            claimRewards.selectedChain = selectedChain
            claimRewards.modalTransitionStyle = .coverVertical
            self.present(claimRewards, animated: true)
            
        } else {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
        }
    }
    
    func onCompoundingTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain.getCosmosfetcher()?.rewardAddress != selectedChain.bechAddress) {
            onShowToast(NSLocalizedString("error_reward_address_changed_msg", comment: ""))
            return
        }
        if let claimableReward = rewards?.filter({ $0.validatorAddress == fromValAddress }).first,
           claimableReward.reward.count > 0 {
            let compounding = CosmosCompounding(nibName: "CosmosCompounding", bundle: nil)
            compounding.claimableRewards = [claimableReward]
            compounding.selectedChain = selectedChain
            compounding.modalTransitionStyle = .coverVertical
            self.present(compounding, animated: true)
            
        } else {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
        }
    }
    
    func onCancelUnbondingTx(_ position: Int) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain is ChainInitia) {
            let cancel = CosmosCancelUnbonding(nibName: "CosmosCancelUnbonding", bundle: nil)
            cancel.selectedChain = selectedChain
            cancel.unbondingEntryInitia = initiaUnbondings[position]
            cancel.modalTransitionStyle = .coverVertical
            self.present(cancel, animated: true)
            
        } else if (selectedChain is ChainZenrock) {
            let cancel = CosmosCancelUnbonding(nibName: "CosmosCancelUnbonding", bundle: nil)
            cancel.selectedChain = selectedChain
            cancel.unbondingEntryZenrock = zenrockUnbondings[position]
            cancel.modalTransitionStyle = .coverVertical
            self.present(cancel, animated: true)

        } else {
            let cancel = CosmosCancelUnbonding(nibName: "CosmosCancelUnbonding", bundle: nil)
            cancel.selectedChain = selectedChain
            cancel.unbondingEntry = unbondings[position]
            cancel.modalTransitionStyle = .coverVertical
            self.present(cancel, animated: true)
        }
    }
}


extension CosmosStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tabbar.selectedItem?.tag == 0) {
            if (selectedChain is ChainInitia) {
                return initiaDelegations.count
            } else if (selectedChain is ChainZenrock) {
                return zenrockDelegations.count
            } else {
                return delegations.count
            }
            
        } else if (tabbar.selectedItem?.tag == 1) {
            if (selectedChain is ChainInitia) {
                return initiaUnbondings.count
            } else if (selectedChain is ChainZenrock) {
                return zenrockUnbondings.count
            } else {
                return unbondings.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tabbar.selectedItem?.tag == 0) {
            if selectedChain is ChainInitia {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeDelegateCell") as! StakeDelegateCell
                let delegation = initiaDelegations[indexPath.row]
                if let validator = initiaValidators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                    cell.onBindInitiaMyDelegate(selectedChain, validator, delegation)
                }
                return cell
                
            } else if selectedChain is ChainZenrock {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeDelegateCell") as! StakeDelegateCell
                let delegation = zenrockDelegations[indexPath.row]
                if let validator = zenrockValidators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                    cell.onBindZenrockMyDelegate(selectedChain, validator, delegation)
                }
                return cell


            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeDelegateCell") as! StakeDelegateCell
                let delegation = delegations[indexPath.row]
                if let validator = validators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                    cell.onBindMyDelegate(selectedChain, validator, delegation)
                }
                return cell
            }
            
        } else if (tabbar.selectedItem?.tag == 1) {
            if selectedChain is ChainInitia {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeUnbondingCell") as! StakeUnbondingCell
                let entry = initiaUnbondings[indexPath.row]
                if let validator = initiaValidators.filter({ $0.operatorAddress == entry.validatorAddress }).first {
                    cell.onBindInitiaMyUnbonding(selectedChain, validator, entry)
                }
                return cell
                
            } else if selectedChain is ChainZenrock {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeUnbondingCell") as! StakeUnbondingCell
                let entry = zenrockUnbondings[indexPath.row]
                if let validator = zenrockValidators.filter({ $0.operatorAddress == entry.validatorAddress }).first {
                    cell.onBindZenrockMyUnbonding(selectedChain, validator, entry)
                }
                return cell
                

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeUnbondingCell") as! StakeUnbondingCell
                let entry = unbondings[indexPath.row]
                if let validator = validators.filter({ $0.operatorAddress == entry.validatorAddress }).first {
                    cell.onBindMyUnbonding(selectedChain, validator, entry)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tabbar.selectedItem?.tag == 0) {
            if selectedChain is ChainInitia {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.initiaDelegation = initiaDelegations[indexPath.row]
                baseSheet.sheetType = .SelectInitiaDelegatedAction
                onStartSheet(baseSheet, 320, 0.6)
                
            } else if selectedChain is ChainZenrock {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.zenrockDelegation = zenrockDelegations[indexPath.row]
                baseSheet.sheetType = .SelectZenrockDelegatedAction
                onStartSheet(baseSheet, 320, 0.6)

            } else {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.targetChain = selectedChain
                baseSheet.delegation = delegations[indexPath.row]
                baseSheet.sheetType = .SelectDelegatedAction
                onStartSheet(baseSheet, 320, 0.6)
            }
            
        } else if (tabbar.selectedItem?.tag == 1) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.unbondingEnrtyPosition = indexPath.row
            baseSheet.sheetType = .SelectUnbondingAction
            onStartSheet(baseSheet, 240, 0.6)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (tabbar.selectedItem?.tag == 1) {
            if selectedChain is ChainInitia {
                let delegation = initiaDelegations[indexPath.row]
                let rewards = rewards?.filter { $0.validatorAddress == delegation.delegation.validatorAddress }
                
                let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
                rewardListPopupVC.selectedChain = selectedChain
                rewardListPopupVC.rewards = rewards!
                
                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return rewardListPopupVC }) { _ in
                    UIMenu(title: "", children: [])
                }
                
            } else if selectedChain is ChainZenrock {
                let delegation = zenrockDelegations[indexPath.row]
                let rewards = rewards?.filter { $0.validatorAddress == delegation.delegation.validatorAddress }
                
                let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
                rewardListPopupVC.selectedChain = selectedChain
                rewardListPopupVC.rewards = rewards!
                
                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return rewardListPopupVC }) { _ in
                    UIMenu(title: "", children: [])
                }

            } else {
                let delegation = delegations[indexPath.row]
                let rewards = rewards?.filter { $0.validatorAddress == delegation.delegation.validatorAddress }
                    
                let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
                rewardListPopupVC.selectedChain = selectedChain
                rewardListPopupVC.rewards = rewards!
                
                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return rewardListPopupVC }) { _ in
                    UIMenu(title: "", children: [])
                }
            }
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? StakeDelegateCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
    }
}

extension CosmosStakingInfoVC: BaseSheetDelegate, PinDelegate {
    
    public func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectDelegatedAction || sheetType == .SelectInitiaDelegatedAction || sheetType == .SelectZenrockDelegatedAction) {
            if let index = result["index"] as? Int,
               let valAddress = result["validatorAddress"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDelegateTx(valAddress)
                    } else if (index == 1) {
                        self.onUndelegateTx(valAddress)
                    } else if (index == 2) {
                        self.onRedelegateTx(valAddress)
                    } else if (index == 3) {
                        self.onClaimRewardTx(valAddress)
                    } else if (index == 4) {
                        self.onCompoundingTx(valAddress)
                    }
                });
            }
            
        } else if (sheetType == .SelectUnbondingAction) {
            if let entryPosition = result["entryPosition"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.onCancelUnbondingTx(entryPosition)
                });
            }
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        
    }
}

extension CosmosStakingInfoVC: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            emptyStakeImg.isHidden = !delegations.isEmpty || !initiaDelegations.isEmpty || !zenrockDelegations.isEmpty

        } else if item.tag == 1 {
            emptyStakeImg.isHidden = !unbondings.isEmpty || !initiaUnbondings.isEmpty || !zenrockUnbondings.isEmpty
            
        }
        
        tableView.reloadData()
    }
}

struct UnbondingEntry {
    var validatorAddress: String = String()
    var entry: Cosmos_Staking_V1beta1_UnbondingDelegationEntry
}

struct InitiaUnbondingEntry {
    var validatorAddress: String = String()
    var entry: Initia_Mstaking_V1_UnbondingDelegationEntry
}

struct ZenrockUnbondingEntry {
    var validatorAddress: String = String()
    var entry: Zrchain_Validation_UnbondingDelegationEntry
}
