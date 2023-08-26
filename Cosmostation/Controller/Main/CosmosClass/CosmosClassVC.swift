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
    
    @IBOutlet weak var addressLayer: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var tabbar: MDCTabBarView!
    @IBOutlet weak var assetList: UIView!
    @IBOutlet weak var historyList: UIView!
    
    var selectedPosition: Int!
    var selectedChain: CosmosClass!
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSetTabbarView()
        
        baseAccount = BaseData.instance.baseAccount
        selectedChain = baseAccount.toDisplayCosmosChains[selectedPosition]
        totalValue = selectedChain.allValue()
        addressLabel.text = selectedChain.address
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
        
        assetList.alpha = 1
        historyList.alpha = 0
    }
}

extension CosmosClassVC: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if (item.tag == 0) {
            assetList.alpha = 1
            historyList.alpha = 0
            
        } else if (item.tag == 1) {
            assetList.alpha = 0
            historyList.alpha = 1
        }
    }
}
