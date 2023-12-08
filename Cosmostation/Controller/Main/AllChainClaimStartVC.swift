//
//  AllChainClaimStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class AllChainClaimStartVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var claimBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    
    var valueableRewards = [(CosmosClass, [Cosmos_Distribution_V1beta1_DelegationDelegatorReward])]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        cntLabel.isHidden = true
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClaimAllChainCell", bundle: nil), forCellReuseIdentifier: "ClaimAllChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
        onUpdateView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    override func setLocalizedString() {
//        navigationItem.title = NSLocalizedString("title_staking_info", comment: "")
//        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        onUpdateView()
    }
    
    func onUpdateView() {
        valueableRewards.removeAll()
        if (baseAccount.getDisplayCosmosChains().filter { $0.fetched == false }.count == 0) {
            baseAccount.getDisplayCosmosChains().forEach { chain in
                let valueableReward = chain.valueableRewards()
                if (valueableReward.count > 0) {
                    valueableRewards.append((chain, valueableReward))
                }
            }
            
            cntLabel.text = String(valueableRewards.count)
            loadingView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            claimBtn.isEnabled = true
        }
    }
    
    @IBAction func onClickClaim(_ sender: BaseButton) {
        
    }
    
}

extension AllChainClaimStartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueableRewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ClaimAllChainCell") as! ClaimAllChainCell
        cell.onBindRewards(valueableRewards[indexPath.row].0, valueableRewards[indexPath.row].1)
        return cell
    }
    
}
