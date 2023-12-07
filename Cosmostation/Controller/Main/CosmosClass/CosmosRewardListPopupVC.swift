//
//  CosmosRewardListPopupVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CosmosRewardListPopupVC: BaseVC {
    
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
        
        print("rewards ", rewards)
        
        rewards.forEach { delegatorRewards in
            delegatorRewards.reward.forEach { deCoin in
                let amount = NSDecimalNumber(string: deCoin.amount) .multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                if let index = rewardCoins.firstIndex(where: { $0.denom == deCoin.denom }) {
                    let exist = NSDecimalNumber(string: rewardCoins[index].amount)
                    let addes = exist.adding(amount)
                    rewardCoins[index].amount = addes.stringValue
                } else {
                    rewardCoins.append(Cosmos_Base_V1beta1_Coin(deCoin.denom, amount))
                }
            }
        }
        
        print("rewards ", rewards)
    }

}


extension CosmosRewardListPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"RewardDetailCell") as! RewardDetailCell
        return cell
    }
    
}
