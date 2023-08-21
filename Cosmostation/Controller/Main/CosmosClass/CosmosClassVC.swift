//
//  CosmosClassVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class CosmosClassVC: BaseVC {
    
    @IBOutlet weak var tabbar: MDCTabBarView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedPosition: Int!
    var selectedChain: CosmosClass!
    var selectedTab: TabType = .assets
    
    var nativeCoins = Array<Cosmos_Base_V1beta1_Coin>()                // section 1
    var ibcCoins = Array<Cosmos_Base_V1beta1_Coin>()                   // section 2
    var bridgedCoins = Array<Cosmos_Base_V1beta1_Coin>()               // section 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AssetCosmosClassCell", bundle: nil), forCellReuseIdentifier: "AssetCosmosClassCell")
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        onSetTabbarView()
        
        baseAccount = BaseData.instance.baseAccount
        selectedChain = baseAccount.cosmosClassChains[selectedPosition]
        
        print("selectedChain ", selectedChain.cosmosBalances.count)
    }
    
    func onSetTabbarView() {
        let coinTabBar = UITabBarItem(title: "Coins", image: nil, tag: 0)
        let historyTabBar = UITabBarItem(title: "Histories", image: nil, tag: 1)
        tabbar.items = [ coinTabBar, historyTabBar]
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.fontColor02, for: .normal)
        tabbar.setTitleColor(.fontColor01, for: .selected)
        tabbar.setSelectedItem(coinTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixedClusteredLeading
    }
    
    
    func onSortAssets() {
        selectedChain.cosmosBalances.forEach { coin in
            let coinType = BaseData.instance.getAsset(selectedChain.apiName, coin.denom)?.type
            if (coinType == "staking" || coinType == "native") {
                nativeCoins.append(coin)
            } else if (coinType == "bep" || coinType == "bridge") {
                bridgedCoins.append(coin)
            } else if (coinType == "ibc") {
                ibcCoins.append(coin)
            }
        }
        
        nativeCoins.sort {
            if ($0.denom == selectedChain.stakeDenom) { return true }
            if ($1.denom == selectedChain.stakeDenom) { return false }
            let value0 = selectedChain.balanceValue($0.denom)
            let value1 = selectedChain.balanceValue($1.denom)
            return value0.compare(value1).rawValue > 0 ? true : false
        }
        
        ibcCoins.sort {
            let value0 = selectedChain.balanceValue($0.denom)
            let value1 = selectedChain.balanceValue($1.denom)
            return value0.compare(value1).rawValue > 0 ? true : false
        }
        
        bridgedCoins.sort {
            let value0 = selectedChain.balanceValue($0.denom)
            let value1 = selectedChain.balanceValue($1.denom)
            return value0.compare(value1).rawValue > 0 ? true : false
        }
    }

}

extension CosmosClassVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedTab == .assets) {
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (selectedTab == .assets) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCosmosClassCell") as! AssetCosmosClassCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
            return cell
            
        } else {
            
        }
        return UITableViewCell()
    }
    

}

extension CosmosClassVC: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        print("tabBarView didSelect ", item.tag, "  ", selectedTab)
        selectedTab = TabType(rawValue: item.tag)!
    }
}


enum TabType: Int {
    case assets = 0
    case histories = 1
    case governance = 2
}
