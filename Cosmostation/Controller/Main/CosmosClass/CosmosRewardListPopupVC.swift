//
//  CosmosRewardListPopupVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CosmosRewardListPopupVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedChain: CosmosClass!
    var rewards = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
    var rewardCoins = [Cosmos_Base_V1beta1_Coin]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "RewardDetailCell", bundle: nil), forCellReuseIdentifier: "RewardDetailCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        rewardCoins = selectedChain.rewardAllCoins()
        rewardCoins.sort {
            if ($0.denom == selectedChain.stakeDenom) { return true }
            if ($1.denom == selectedChain.stakeDenom) { return false }
            if ($0.denom == DYDX_USDC_DENOM) { return true }
            if ($1.denom == DYDX_USDC_DENOM) { return false }
            
            if (BaseData.instance.getAsset(selectedChain.apiName, $0.denom) == nil) { return false }
            if (BaseData.instance.getAsset(selectedChain.apiName, $1.denom) == nil) { return true }
            
            var value0 = NSDecimalNumber.zero
            var value1 = NSDecimalNumber.zero
            if let msAsset0 = BaseData.instance.getAsset(selectedChain.apiName, $0.denom) {
                let msPrice0 = BaseData.instance.getPrice(msAsset0.coinGeckoId)
                let amount0 = NSDecimalNumber(string: $0.amount)
                value0 = msPrice0.multiplying(by: amount0).multiplying(byPowerOf10: -msAsset0.decimals!, withBehavior: handler6)
            }
            if let msAsset1 = BaseData.instance.getAsset(selectedChain.apiName, $1.denom) {
                let msPrice1 = BaseData.instance.getPrice(msAsset1.coinGeckoId)
                let amount1 = NSDecimalNumber(string: $1.amount)
                value1 = msPrice1.multiplying(by: amount1).multiplying(byPowerOf10: -msAsset1.decimals!, withBehavior: handler6)
            }
            return value0.compare(value1).rawValue > 0 ? true : false
        }
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("title_reward_detail_list", comment: "") + " (" + String(rewardCoins.count) + ")"
    }
}


extension CosmosRewardListPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"RewardDetailCell") as! RewardDetailCell
        cell.onBindRewardDetail(selectedChain, rewardCoins[indexPath.row])
        return cell
    }
    
}
