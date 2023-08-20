//
//  CosmosClassVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class CosmosClassVC: BaseVC {
    
    @IBOutlet weak var tabbar: MDCTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        onSetTabbarView()
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

}

extension CosmosClassVC: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        print("tabBarView didSelect ")
    }
}
