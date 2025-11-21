//
//  BabylonStakingInfoVC.swift
//  Cosmostation
//
//  Created by 차소민 on 3/10/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class BabylonStakingInfoVC: BaseVC {
    
    @IBOutlet weak var epochView: FixCardView!
    @IBOutlet weak var epochTitle: UILabel!
    @IBOutlet weak var epochLable: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tabbar: MDCTabBarView!
    @IBOutlet weak var tabbarDivider: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!
    var rewardAddress: String?
    var validators = [Cosmos_Staking_V1beta1_Validator]()
    var delegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var unbondings = [UnbondingEntry]()
    var rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]?
    var cosmostationValAddress: String?
    
    var pendingStakingTab: [PendingTx] = []
    var pendingUnstakingTab: [PendingTx] = []
    
    var cosmosCryptoVC: CosmosCryptoVC?
    
    var seconds: Double?
    var currentEpoch: UInt64?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "StakeDelegateCell", bundle: nil), forCellReuseIdentifier: "StakeDelegateCell")
        tableView.register(UINib(nibName: "PendingDelegateCell", bundle: nil), forCellReuseIdentifier: "PendingDelegateCell")
        tableView.register(UINib(nibName: "StakeUnbondingCell", bundle: nil), forCellReuseIdentifier: "StakeUnbondingCell")
        tableView.register(UINib(nibName: "PendingUnbondingCell", bundle: nil), forCellReuseIdentifier: "PendingUnbondingCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0

        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onUpdateTime), userInfo: nil, repeats: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconInfo"), style: .plain, target: self, action: #selector(showInfoSheet))
        onSetStakeData()
        onSetTabbarView()
    }
    
    override func setLocalizedString() {
        let symbol = selectedChain.assetSymbol(selectedChain.stakingAssetDenom())
        navigationItem.title = String(format: NSLocalizedString("str_coin_manage_stake", comment: ""), symbol)
        
        epochTitle.text = NSLocalizedString("str_current_epoch", comment: "")
        timeTitle.text = NSLocalizedString("str_next_epoch", comment: "")
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
    
    @objc func showInfoSheet() {
        let sheet = BabylonStatusInfoSheet(nibName: "BabylonStatusInfoSheet", bundle: nil)
        onStartSheet(sheet, 430, 0.7)
    }
    
    func onSetStakeData() {
        Task {
            if let cosmosFetcher = selectedChain.getCosmosfetcher() {
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
            
            if let babylonFetcher = (selectedChain as? ChainBabylon)?.getBabylonFetcher() {
                if babylonFetcher.unbondingCompletionTime == nil || babylonFetcher.unbondingCompletionTime == 0 {
                    await babylonFetcher.fetchCheckPointTime()
                }
            }
            
            await onSetEpochPending()
            
            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onSetTabbarView() {
        let activeTabBar = UITabBarItem(title: "Staking", image: nil, tag: 0)
        let pendingTabBar = UITabBarItem(title: "Unstaking", image: nil, tag: 1)
        tabbar.items.append(activeTabBar)
        tabbar.items.append(pendingTabBar)
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color03, for: .normal)
        tabbar.setTitleColor(.color01, for: .selected)
        tabbar.setSelectedItem(activeTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixedClusteredLeading
        tabbar.setContentPadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: .scrollable)
    }

    func onUpdateView() {
        refresher.endRefreshing()
        loadingView.isHidden = true
        epochView.isHidden = false
        tabbar.isHidden = false
        tabbarDivider.isHidden = false
        stakeBtn.isHidden = false
        tableView.reloadData()
        
        if (tabbar.selectedItem?.tag == 0 ? (delegations.count + pendingStakingTab.count) : (unbondings.count + pendingUnstakingTab.count)) == 0 {
            emptyStakeImg.isHidden = false
        } else {
            emptyStakeImg.isHidden = true
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
        let cancel = CosmosCancelUnbonding(nibName: "CosmosCancelUnbonding", bundle: nil)
        cancel.selectedChain = selectedChain
        cancel.unbondingEntry = unbondings[position]
        cancel.modalTransitionStyle = .coverVertical
        self.present(cancel, animated: true)
    }

    private func onSetEpochPending() async {
        if let babylonFetcher = (selectedChain as? ChainBabylon)?.getBabylonFetcher() {
            do {
                try await babylonFetcher.getEpochPendingData()
                
                if let epoch = babylonFetcher.epoch,
                   let status = babylonFetcher.status,
                   let txs = babylonFetcher.txs {
                    onSetEpoch(epoch, status)
                    onSetPending(txs)
                    
                }
            } catch {
                onShowToast("Failed to fetch epoch data. Please try again.")
            }
            
        }
    }
    
    private func onSetEpoch(_ epoch: Babylon_Epoching_V1_QueryCurrentEpochResponse, _ status: Cosmos_Base_Node_V1beta1_StatusResponse) {
        let blockTime = selectedChain.getChainParam()["block_time"].doubleValue
        let timeSinceLastBlock = Date().timeIntervalSince(status.timestamp.date)
        let timeUntilNextEpoch = Double(epoch.epochBoundary - status.height) * blockTime
        currentEpoch = epoch.currentEpoch
        seconds = timeUntilNextEpoch - timeSinceLastBlock
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            epochLable.text = "#" + String(epoch.currentEpoch)
            timeLabel.text = WUtils.getGapTime(seconds!)
        }

    }
    
    @objc func onUpdateTime() {
        guard let seconds else { return }
            
        if Int(seconds) == 0 {
            timeLabel.text = WUtils.getGapTime(0)
            self.seconds = 0
                        
        } else {
            let newSeconds = seconds - 1
            timeLabel.text = WUtils.getGapTime(newSeconds)
            self.seconds = newSeconds
        }
    }
    
    private func onSetPending(_ txs: [PendingTx]) {
        pendingStakingTab.removeAll()
        pendingUnstakingTab.removeAll()
        
        txs.forEach { tx in
            if tx.type_url == .delegate || tx.type_url == .redelegate || tx.type_url == .compounding {
                pendingStakingTab.append(tx)
                
            } else if tx.type_url == .undelegate || tx.type_url == .cancelUnbonding {
                pendingUnstakingTab.append(tx)
                unbondings = unbondings.filter{ $0.entry.creationHeight != tx.msg.creation_height }
            }
        }
    }
}

extension BabylonStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (tabbar.selectedItem?.tag == 0) {
            if section == 0 {
                view.titleLabel.text = "Pending State"
                view.cntLabel.text = String(pendingStakingTab.count)

            } else {
                view.titleLabel.text = "Active State"
                view.cntLabel.text = String(delegations.count)
            }

        } else {
            if section == 0 {
                view.titleLabel.text = "Pending State"
                view.cntLabel.text = String(pendingUnstakingTab.count)
            } else {
                view.titleLabel.text = "Active State"
                view.cntLabel.text = String(unbondings.count)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tabbar.selectedItem?.tag == 0) {
            if section == 0 {
                return (pendingStakingTab.count) == 0 ? .leastNormalMagnitude : 40
            } else {
                return delegations.count == 0 ? .leastNormalMagnitude : 40
            }
            
        } else if (tabbar.selectedItem?.tag == 1) {
            if section == 0 {
                return (pendingUnstakingTab.count) == 0 ? .leastNormalMagnitude : 40
            } else {
                return unbondings.count == 0 ? .leastNormalMagnitude : 40
            }
        }
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tabbar.selectedItem?.tag == 0) {
            if section == 0 {
                return pendingStakingTab.count
            } else {
                return delegations.count
            }
        } else if (tabbar.selectedItem?.tag == 1) {
            if section == 0 {
                return pendingUnstakingTab.count
            } else {
                return unbondings.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tabbar.selectedItem?.tag == 0) {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:"PendingDelegateCell") as! PendingDelegateCell
                let pendingData = pendingStakingTab[indexPath.row]
                
                if let validator = validators.filter({ $0.operatorAddress == pendingData.msg.validator_address }).first {
                    cell.onBindMyDelegate(selectedChain, validator, pendingData, currentEpoch)
                    
                } else if let validator = validators.filter({$0.operatorAddress == pendingData.msg.validator_dst_address }).first {
                    cell.onBindMyDelegate(selectedChain, validator, pendingData, currentEpoch)
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
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:"PendingUnbondingCell") as! PendingUnbondingCell
                let pendingData = pendingUnstakingTab[indexPath.row]
                if let validator = validators.filter({ $0.operatorAddress == pendingData.msg.validator_address }).first {
                    cell.onBindMyUnbonding(selectedChain, validator, pendingData, currentEpoch)
                }
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"StakeUnbondingCell") as! StakeUnbondingCell
                let entry = unbondings[indexPath.row]
                if let validator = validators.filter({ $0.operatorAddress == entry.validatorAddress }).first {
                    cell.onBindBabylonUnbonding(selectedChain, validator, entry)
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
        if indexPath.section == 0 {
            if (tabbar.selectedItem?.tag == 0) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.delegation = delegations[indexPath.row]
                baseSheet.sheetType = .SelectDelegatedAction
                onStartSheet(baseSheet, 320, 0.6)
            } 
//            else if (tabbar.selectedItem?.tag == 1) {
//                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
//                baseSheet.sheetDelegate = self
//                baseSheet.unbondingEnrtyPosition = indexPath.row
//                baseSheet.sheetType = .SelectUnbondingAction
//                onStartSheet(baseSheet, 240, 0.6)
//            }
        }
    }
}

extension BabylonStakingInfoVC: BaseSheetDelegate, PinDelegate {
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

extension BabylonStakingInfoVC: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            emptyStakeImg.isHidden = (delegations.count + pendingStakingTab.count) > 0
        } else if item.tag == 1 {
            emptyStakeImg.isHidden = (unbondings.count + pendingUnstakingTab.count) > 0
        }
        tableView.reloadData()
    }
}
