//
//  NeutronStakingInfoVC.swift
//  Cosmostation
//
//  Created by 차소민 on 4/7/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class NeutronStakingInfoVC: BaseVC {
    
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    @IBOutlet weak var tabbar: MDCTabBarView!
    var refresher: UIRefreshControl!
    
    var selectedChain: ChainNeutron!
    var rewardAddress: String?
    var validators = [Cosmos_Staking_V1beta1_Validator]()
    var delegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var unbondings = [UnbondingEntry]()
    var rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]?
    var cosmostationValAddress: String?
    
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
        let symbol = selectedChain.assetSymbol(selectedChain.stakeDenom ?? "")
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
            if let fetcher = selectedChain.getNeutronFetcher() {
                rewardAddress = fetcher.rewardAddress
                validators = fetcher.cosmosValidators
                delegations = fetcher.cosmosDelegations
                rewards = fetcher.cosmosRewards
                unbondings.removeAll()
                
                fetcher.cosmosUnbondings?.forEach { unbonding in
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
        if (tabbar.selectedItem?.tag == 0 ? delegations.count : unbondings.count) == 0 {
            emptyStakeImg.isHidden = false
        } else {
            emptyStakeImg.isHidden = true
        }
        
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom ?? "") {
            let filePath = Bundle.main.path(forResource: "ntrnCoin", ofType: "png")
            let url = URL(fileURLWithPath: filePath ?? "")

            coinImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "tokenDefault"))
            var rewardAmount = NSDecimalNumber.zero
            rewards?.forEach { reward in
                let rawAmount =  NSDecimalNumber(string: reward.reward.filter{ $0.denom == selectedChain.stakeDenom }.first?.amount ?? "0")
                rewardAmount = rewardAmount.adding(rawAmount.multiplying(byPowerOf10: -18, withBehavior: handler0Down))
            }
            WDP.dpCoin(msAsset, rewardAmount, nil, rewardDenomLabel, rewardAmountLabel, msAsset.decimals)
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
        let delegate = CosmosDelegate(nibName: "CosmosDelegate", bundle: nil)
        delegate.selectedChain = selectedChain
        if (toValAddress != nil) {
            delegate.toValidator = validators.filter({ $0.operatorAddress == toValAddress }).first
        }
        delegate.modalTransitionStyle = .coverVertical
        self.present(delegate, animated: true)
        
    }
    
    func onUndelegateTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let undelegate = CosmosUndelegate(nibName: "CosmosUndelegate", bundle: nil)
        undelegate.selectedChain = selectedChain
        undelegate.fromValidator = validators.filter({ $0.operatorAddress == fromValAddress }).first
        undelegate.modalTransitionStyle = .coverVertical
        self.present(undelegate, animated: true)
        
    }
    
    func onRedelegateTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let redelegate = CosmosRedelegate(nibName: "CosmosRedelegate", bundle: nil)
        redelegate.selectedChain = selectedChain
        redelegate.fromValidator = validators.filter({ $0.operatorAddress == fromValAddress }).first
        redelegate.modalTransitionStyle = .coverVertical
        self.present(redelegate, animated: true)
        
    }
        
    func onCancelUnbondingTx(_ position: Int) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let cancel = CosmosCancelUnbonding(nibName: "CosmosCancelUnbonding", bundle: nil)
        cancel.selectedChain = selectedChain
        cancel.unbondingEntry = unbondings[position]
        cancel.modalTransitionStyle = .coverVertical
        self.present(cancel, animated: true)
        
    }
    
    @IBAction func onClaimAllTx(_ sender: Any) {
        guard let comsosFetcher = selectedChain.getCosmosfetcher() else {
            return
        }
        if (comsosFetcher.rewardAllCoins().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (comsosFetcher.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_wasting_fee", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }

        guard let fetcher = selectedChain.getNeutronFetcher() else { return }
        let claimRewards = CosmosClaimRewards(nibName: "CosmosClaimRewards", bundle: nil)
        claimRewards.claimableRewards = fetcher.claimableRewards()
        claimRewards.selectedChain = selectedChain
        claimRewards.modalTransitionStyle = .coverVertical
        self.present(claimRewards, animated: true)
    }
    
    @IBAction func onCompoundingAll(_ sender: Any) {
        guard let comsosFetcher = selectedChain.getCosmosfetcher() else {
            return
        }        
        if (comsosFetcher.rewardAllCoins().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (comsosFetcher.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_wasting_fee", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }

        guard let fetcher = selectedChain.getNeutronFetcher() else { return }
        let compounding = NeutronCompounding(nibName: "NeutronCompounding", bundle: nil)
        compounding.claimableRewards = fetcher.claimableRewards()
        compounding.selectedChain = selectedChain
        compounding.isCompoundingAll = true
        compounding.modalTransitionStyle = .coverVertical
        self.present(compounding, animated: true)
    }
    
}

extension NeutronStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tabbar.selectedItem?.tag == 0) {
            return delegations.count
            
            
        } else if (tabbar.selectedItem?.tag == 1) {
            return unbondings.count
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tabbar.selectedItem?.tag == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"StakeDelegateCell") as! StakeDelegateCell
            let delegation = delegations[indexPath.row]
            if let validator = validators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                cell.onBindNeutronMyDelegate(selectedChain, validator, delegation)
            }
            return cell
            
            
        } else if (tabbar.selectedItem?.tag == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"StakeUnbondingCell") as! StakeUnbondingCell
            let entry = unbondings[indexPath.row]
            if let validator = validators.filter({ $0.operatorAddress == entry.validatorAddress }).first {
                cell.onBindMyUnbonding(selectedChain, validator, entry)
            }
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tabbar.selectedItem?.tag == 0) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.delegation = delegations[indexPath.row]
            baseSheet.sheetType = .SelectNeutronDelegatedAction
            onStartSheet(baseSheet, 320, 0.6)
            
            
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
            let delegation = delegations[indexPath.row]
            let rewards = rewards?.filter { $0.validatorAddress == delegation.delegation.validatorAddress }
            
            let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
            rewardListPopupVC.selectedChain = selectedChain
            rewardListPopupVC.rewards = rewards!
            
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return rewardListPopupVC }) { _ in
                UIMenu(title: "", children: [])
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



extension NeutronStakingInfoVC: BaseSheetDelegate, PinDelegate {
    
    public func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectNeutronDelegatedAction) {
            if let index = result["index"] as? Int,
               let valAddress = result["validatorAddress"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDelegateTx(valAddress)
                    } else if (index == 1) {
                        self.onUndelegateTx(valAddress)
                    } else if (index == 2) {
                        self.onRedelegateTx(valAddress)
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
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) { }
}


extension NeutronStakingInfoVC: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            emptyStakeImg.isHidden = !delegations.isEmpty
            
        } else if item.tag == 1 {
            emptyStakeImg.isHidden = !unbondings.isEmpty
        }
        
        tableView.reloadData()
    }
}
