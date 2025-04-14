//
//  BtcStakingInfoVC.swift
//  Cosmostation
//
//  Created by 차소민 on 2/20/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents
import SwiftyJSON

class BtcStakingInfoVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    @IBOutlet weak var tabbar: MDCTabBarView!
    @IBOutlet weak var tabbarDivider: UIView!
    var refresher: UIRefreshControl!

    var selectedChain: ChainBitCoin86!
        
    var delegations: [BtcDelegation] = []
    var providers: [FinalityProvider] = []
    var timeLockWeeks: Int = 0
    
    var displayData = [BtcDelegation]()

    var chainBabylon: BaseChain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
            
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
            tableView.register(UINib(nibName: "BtcStakingCell", bundle: nil), forCellReuseIdentifier: "BtcStakingCell")
            tableView.register(UINib(nibName: "StakeUnbondingCell", bundle: nil), forCellReuseIdentifier: "StakeUnbondingCell")
            tableView.register(UINib(nibName: "UnstakingApproxCell", bundle: nil), forCellReuseIdentifier: "UnstakingApproxCell")
            tableView.rowHeight = UITableView.automaticDimension
            tableView.sectionHeaderTopPadding = 0.0
            
            refresher = UIRefreshControl()
            refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
            refresher.tintColor = .color01
            tableView.addSubview(refresher)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconInfo"), style: .plain, target: self, action: #selector(showInfoSheet))
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            
            try await selectedChain.getBabylonBtcFetcher()?.fetchNetworkInfo()
            
            baseAccount = BaseData.instance.baseAccount
            chainBabylon = await self.initBabylonKeys(self.selectedChain.isTestnet)
            if let cosmosFetcher = chainBabylon.getCosmosfetcher() {
                cosmosFetcher.cosmosBalances = try await cosmosFetcher.fetchBalance()
            }

            
            onSetStakeData()
            onSetTabbarView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onFetchDone), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        refresher.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    override func setLocalizedString() {
        navigationItem.title = String(format: NSLocalizedString("str_coin_manage_stake", comment: ""), selectedChain.coinSymbol)
        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
    }
    
    @objc func showInfoSheet() {
        let infoSheet = BtcStakingInfoSheet(nibName: "BtcStakingInfoSheet", bundle: nil)
        infoSheet.chain = selectedChain
        onStartSheet(infoSheet, 420, 0.7)
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
    }


    func onSetStakeData() {
        guard let fetcher = selectedChain.getBabylonBtcFetcher() else { return }
        Task {
            await fetcher.updateProvidersVotingPower()
            delegations = fetcher.btcDelegations
            providers = fetcher.finalityProviders
            timeLockWeeks = fetcher.btcStakingTimeLockWeeks
            
            DispatchQueue.main.async {
                self.onUpdateView()
            }
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

    func onUpdateView() {
        
        if tabbar.selectedItem?.tag == 0 {
            displayData = delegations.filter({ $0.state.uppercased().contains("ACTIVE")})
        } else {
            displayData = delegations.filter({ $0.state.uppercased() == "TIMELOCK_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING" || $0.state.uppercased().contains("WITHDRAWABLE") })
        }

        refresher.endRefreshing()
        stakeBtn.isEnabled = true
        loadingView.isHidden = true
        tableView.isHidden = false
        tabbar.isHidden = false
        tabbarDivider.isHidden = false
        tableView.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = true
        if (displayData.count) == 0 {
            emptyStakeImg.isHidden = false
        } else {
            emptyStakeImg.isHidden = true
        }
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
        onDelegateTx(nil)
    }
    
    func onDelegateTx(_ toFpPk: String?) {
        
        if (chainBabylon.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if let btcFetcher = selectedChain.getBtcFetcher(),
           let minStakingValue = selectedChain.getBabylonBtcFetcher()?.networkInfo.last?["min_staking_value_sat"].uInt64Value,
           btcFetcher.btcBalances.compare(NSDecimalNumber(value: minStakingValue)).rawValue <= 0 {
            onShowToast("Staking amount must be at least \(NSDecimalNumber(value: minStakingValue).multiplying(byPowerOf10: -8)) \(selectedChain.coinSymbol).")
            return
        }
        
        let delegate = BtcDelegate(nibName: "BtcDelegate", bundle: nil)
        delegate.selectedChain = selectedChain
        delegate.chainBabylon = chainBabylon
        if (toFpPk != nil) {
            delegate.toProvider = providers.filter({ $0.btcPk == toFpPk }).first
        }
        delegate.modalTransitionStyle = .coverVertical
        self.present(delegate, animated: true)
    }
    
    func onUndelegateTx(_ delegation: BtcDelegation?, _ type: SheetType) {
        if let babylonBtcFetcher = selectedChain.getBabylonBtcFetcher(),
           let btcFetcher = selectedChain.getBtcFetcher() {
            let fee = NSDecimalNumber(value: babylonBtcFetcher.unbondingFeeSat ?? 0)
            if btcFetcher.btcBalances.compare(fee).rawValue <= 0 {
                onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
        }
        
        let type: BtcStakeActionType = (type == .SelectBtcWithdrawAction) ? .withdraw : .unstake
        let undelegate = BtcUndelegate(nibName: "BtcUndelegate", bundle: nil)
        undelegate.selectedChain = selectedChain
        undelegate.delegation = delegation
        undelegate.actionType = type
        undelegate.modalTransitionStyle = .coverVertical
        self.present(undelegate, animated: true)
    }

}


extension BtcStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabbar.selectedItem?.tag == 0 {
            return displayData.count
        } else {
            if (section == 0) {
                return displayData.filter({$0.state.uppercased().contains("WITHDRAWABLE")}).count
            } else {
                return displayData.filter({$0.state.uppercased() == "TIMELOCK_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING"}).count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tabbar.selectedItem?.tag == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tabbar.selectedItem?.tag == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let withdrawable = displayData.filter({$0.state.uppercased().contains("WITHDRAWABLE")})
        let unstaking = displayData.filter({$0.state.uppercased() == "TIMELOCK_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING"})
        if tabbar.selectedItem?.tag == 1 {
            let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            if (section == 0) {
                view.titleLabel.text = "Withdrawable State"
                view.cntLabel.text = String(withdrawable.count)

            } else if (section == 1) {
                view.titleLabel.text = "Unstaking State"
                view.cntLabel.text = String(unstaking.count)

            }
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tabbar.selectedItem?.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BtcStakingCell") as! BtcStakingCell
            let provider = providers.filter({ $0.btcPk == displayData[indexPath.row].providerPk }).first
            cell.onBindBtcMyDelegate(selectedChain, displayData[indexPath.row], provider, timeLockWeeks)
            return cell
            
        } else {
            var data = [BtcDelegation]()
            if (indexPath.section == 0) {
                data = displayData.filter({$0.state.uppercased().contains("WITHDRAWABLE")})
            } else if (indexPath.section == 1) {
                data = displayData.filter({$0.state.uppercased() == "TIMELOCK_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING"})
            }
            let cell = tableView.dequeueReusableCell(withIdentifier:"UnstakingApproxCell") as! UnstakingApproxCell
            let provider = providers.filter({ $0.btcPk == data[indexPath.row].providerPk }).first
            cell.onBindBtcUndelegate(selectedChain, data[indexPath.row], provider)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tabbar.selectedItem?.tag == 0 {
            let provider = providers.filter({ $0.btcPk == displayData[indexPath.row].providerPk }).first
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.btcFinalityProvider = provider
            baseSheet.btcDelegation = displayData[indexPath.row]
            baseSheet.sheetType = .SelectBtcDelegatedAction
            onStartSheet(baseSheet, 320, 0.6)

        } else {
            if (indexPath.section == 0) {
                let data = displayData.filter({$0.state.uppercased().contains("WITHDRAWABLE")})
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.btcDelegation = data[indexPath.row]
                baseSheet.sheetType = .SelectBtcWithdrawAction
                onStartSheet(baseSheet, 320, 0.6)
                
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tabbar.selectedItem?.tag == 1 {
            for cell in tableView.visibleCells {
                let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
                if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                    maskCell(cell: cell, margin: Float(hiddenFrameHeight))
                }
            }
            view.endEditing(true)
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }

}

extension BtcStakingInfoVC: BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if sheetType == .SelectBtcDelegatedAction {
            if let index = result["index"] as? Int,
               let fp = result["finalityProvider"] as? FinalityProvider {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDelegateTx(fp.btcPk)
                    } else if (index == 1) {
                        self.onUndelegateTx(result["delegation"] as? BtcDelegation, sheetType!)
                    }
                });
            }

        } else if sheetType == .SelectBtcWithdrawAction {
            if let delegation = result["delegation"] as? BtcDelegation {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.onUndelegateTx(delegation, sheetType!)
                })
            }
        }
    }
}

extension BtcStakingInfoVC: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            displayData = delegations.filter({ $0.state.uppercased().contains("ACTIVE")})
        } else {
            displayData = delegations.filter({$0.state.uppercased() == "TIMELOCK_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING" || $0.state.uppercased().contains("WITHDRAWABLE") })
        }
        emptyStakeImg.isHidden = !displayData.isEmpty
        tableView.reloadData()
        
        if item.tag == 1 {
            tableView.visibleCells.forEach { cell in
                let hiddenFrameHeight = tableView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
                if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                    maskCell(cell: cell, margin: Float(hiddenFrameHeight))
                }
            }
        }
    }
}


extension BtcStakingInfoVC {
    func initBabylonKeys(_ isTestnet: Bool) async -> BaseChain {
        let chain = ALLCHAINS().filter({ $0 is ChainBabylon }).filter({ isTestnet ? $0.isTestnet : !$0.isTestnet}).first!
        let keychain = BaseData.instance.getKeyChain()
        if (baseAccount.type == .withMnemonic) {
            if let secureData = try? keychain.getString(baseAccount.uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                if (chain.publicKey == nil) {
                    chain.setInfoWithSeed(seed, baseAccount.lastHDPath)
                }
                
            }
            
        } else if (baseAccount.type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(baseAccount.uuid.sha1()) {
                if (chain.publicKey == nil) {
                    chain.setInfoWithPrivateKey(Data.fromHex(secureKey!)!)
                    
                }
            }
        }
        return chain
    }

}
