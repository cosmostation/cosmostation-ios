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


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal

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
        onSetStakeData()
        onSetTabbarView()

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
            displayData = delegations.filter({ $0.state.uppercased() == "EARLY_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING_WITHDRAWABLE"})
        }

        refresher.endRefreshing()
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
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
            let delegate = BtcDelegate(nibName: "BtcDelegate", bundle: nil)
            delegate.selectedChain = selectedChain
            if (toFpPk != nil) {
                delegate.toProvider = providers.filter({ $0.btcPk == toFpPk }).first
            }
            delegate.modalTransitionStyle = .coverVertical
            self.present(delegate, animated: true)
    }

}


extension BtcStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tabbar.selectedItem?.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BtcStakingCell") as! BtcStakingCell
            let provider = providers.filter({ $0.btcPk == displayData[indexPath.row].providerPk }).first
            cell.onBindBtcMyDelegate(selectedChain, displayData[indexPath.row], provider, timeLockWeeks)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"UnstakingApproxCell") as! UnstakingApproxCell
            let provider = providers.filter({ $0.btcPk == displayData[indexPath.row].providerPk }).first
            cell.onBindBtcUndelegate(selectedChain, displayData[indexPath.row], provider)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension BtcStakingInfoVC: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            displayData = delegations.filter({ $0.state.uppercased().contains("ACTIVE")})
        } else {
            displayData = delegations.filter({ $0.state.uppercased() == "EARLY_UNBONDING" || $0.state.uppercased() == "EARLY_UNBONDING_WITHDRAWABLE"})
        }
        emptyStakeImg.isHidden = !displayData.isEmpty
        tableView.reloadData()
    }
}
