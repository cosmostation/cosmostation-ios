//
//  SuiStakingInfoVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/11/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import SwiftyJSON
import MaterialComponents

class SuiStakingInfoVC: BaseVC {
    
    @IBOutlet weak var epochTitle: UILabel!
    @IBOutlet weak var epochLable: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tabbar: MDCTabBarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    var refresher: UIRefreshControl!
    
    var selectedChain: ChainSui!
    var suiFehcer: SuiFetcher!
    
    var timer: Timer?
    var epoch: Int64?
    var epochStartTimestampMs: Int64?
    var epochDurationMs: Int64?
    var stakedList = [(String, JSON)]()
    var displayStakedList = [(String, JSON)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        suiFehcer = selectedChain.getSuiFetcher()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        epoch = suiFehcer.suiSystem["epoch"].int64Value
        epochStartTimestampMs = suiFehcer.suiSystem["epochStartTimestampMs"].int64Value
        epochDurationMs = suiFehcer.suiSystem["epochDurationMs"].int64Value
        epochLable.text = "#" + String(epoch!)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onUpdateTime), userInfo: nil, repeats: true)
        onUpdateTime()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SuiStakingCell", bundle: nil), forCellReuseIdentifier: "SuiStakingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconInfo"), style: .plain, target: self, action: #selector(showInfoSheet))
        
        onSetTabbarView()
        onUpdateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        refresher.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }

    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain.tag == tag) {
            onUpdateView()
        }
    }
    
    func onSetTabbarView() {
        let activeTabBar = UITabBarItem(title: "Active", image: nil, tag: 0)
        let pendingTabBar = UITabBarItem(title: "Pending", image: nil, tag: 1)
        tabbar.items.append(activeTabBar)
        tabbar.items.append(pendingTabBar)
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color02, for: .normal)
        tabbar.setTitleColor(.color02, for: .selected)
        tabbar.setSelectedItem(activeTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixedClusteredLeading
        tabbar.setContentPadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: .scrollable)
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_staking_info", comment: "")
        epochTitle.text = NSLocalizedString("str_current_epoch", comment: "")
        timeTitle.text = NSLocalizedString("str_next_reward_distibution", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
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
    
    @objc func onUpdateTime() {
        let endEpoch = epochStartTimestampMs! + epochDurationMs!
        let current = Date().millisecondsSince1970
        if (endEpoch > current) {
            let gap = (endEpoch - current) / 1000
            var hours = String(gap / (60 * 60))
            var minutes = String((gap / 60) % 60)
            var second = String(gap % 60)
            if (hours.count == 1) { hours = "0" + hours }
            if (minutes.count == 1) { minutes = "0" + minutes }
            if (second.count == 1) { second = "0" + second }
            timeLabel.text = hours + " : " + minutes + " : " + second
            
        } else {
            timer?.invalidate()
        }
    }
    
    @objc func showInfoSheet() {
        let infoSheet = SuiStakingInfoSheet(nibName: "SuiStakingInfoSheet", bundle: nil)
        infoSheet.suiFehcer = suiFehcer
        onStartSheet(infoSheet, 420, 0.7)
    }
    
    func onUpdateView() {
        stakedList.removeAll()
        suiFehcer.suiStakedList.forEach { suiStaked in
            suiStaked["stakes"].arrayValue.forEach { stakes in
                stakedList.append((suiStaked["validatorAddress"].stringValue, stakes))
            }
        }
        
        stakedList.sort {
            return $0.1["stakeRequestEpoch"].uInt64Value > $1.1["stakeRequestEpoch"].uInt64Value
        }
        
        if tabbar.selectedItem?.tag == 0 {
            displayStakedList = stakedList.filter{ $0.1["status"].stringValue != "Pending" }
        } else {
            displayStakedList = stakedList.filter{ $0.1["status"].stringValue == "Pending" }
        }
        
        refresher.endRefreshing()
        loadingView.isHidden = true
        tabbar.isHidden = false
        tableView.isHidden = false
        tableView.reloadData()
        
        if (displayStakedList.count == 0) {
            emptyStakeImg.isHidden = false
        } else {
            emptyStakeImg.isHidden = true
        }
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
        if (selectedChain.isTxFeePayable(.SUI_STAKE) == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let suiBalance = suiFehcer.balanceAmount(SUI_MAIN_DENOM)
        if (suiBalance.compare(SUI_MIN_STAKE.adding(SUI_FEE_STAKE)).rawValue < 0) {
            onShowToast(NSLocalizedString("error_not_enough_sui_stake", comment: ""))
            return
        }
        
        let suiStake = SuiStake(nibName: "SuiStake", bundle: nil)
        suiStake.selectedChain = selectedChain
        suiStake.modalTransitionStyle = .coverVertical
        self.present(suiStake, animated: true)
    }
    
    func onClickUnStake(_ stake: (String, JSON)) {
        let suiUnstake = SuiUnstake(nibName: "SuiUnstake", bundle: nil)
        suiUnstake.selectedChain = selectedChain
        suiUnstake.fromValidator = stake
        suiUnstake.modalTransitionStyle = .coverVertical
        self.present(suiUnstake, animated: true)
    }
    
}


extension SuiStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayStakedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SuiStakingCell") as! SuiStakingCell
        cell.onBindMyStake(selectedChain, displayStakedList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if displayStakedList[indexPath.row].1["status"].stringValue == "Pending" {
            onShowToast(NSLocalizedString("error_pending", comment: ""))
        } else {
            onClickUnStake(displayStakedList[indexPath.row])
        }
    }
}

extension SuiStakingInfoVC: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            displayStakedList = stakedList.filter{ $0.1["status"].stringValue != "Pending" }
        } else if item.tag == 1 {
            displayStakedList = stakedList.filter{ $0.1["status"].stringValue == "Pending" }
        }
        
        emptyStakeImg.isHidden = !displayStakedList.isEmpty
        
        tableView.reloadData()
    }
}
