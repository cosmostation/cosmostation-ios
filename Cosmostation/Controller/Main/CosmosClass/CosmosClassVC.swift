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
    
    @IBOutlet weak var coinList: UIView!
    @IBOutlet weak var tokenList: UIView!
    @IBOutlet weak var nftList: UIView!
    @IBOutlet weak var historyList: UIView!
    @IBOutlet weak var aboutList: UIView!
    
    var selectedPosition: Int!
    var selectedChain: CosmosClass!
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        selectedChain = baseAccount.toDisplayCosmosChains[selectedPosition]
        totalValue = selectedChain.allValue()
        addressLabel.text = selectedChain.address
        onSetTabbarView()
        
        print("selectedChain address ", selectedChain.address)
    }
    
    func onSetTabbarView() {
        let coinTabBar = UITabBarItem(title: "Coins", image: nil, tag: 0)
        let tokenTabBar = UITabBarItem(title: "Tokens", image: nil, tag: 1)
        let nftTabBar = UITabBarItem(title: "NFTs", image: nil, tag: 2)
        let historyTabBar = UITabBarItem(title: "Histories", image: nil, tag: 3)
        let aboutTabBar = UITabBarItem(title: "About", image: nil, tag: 4)
        tabbar.items = [ coinTabBar, tokenTabBar, historyTabBar]
//        tabbar.items = [ coinTabBar, tokenTabBar, nftTabBar, historyTabBar, aboutTabBar]
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color02, for: .normal)
        tabbar.setTitleColor(.color02, for: .selected)
        tabbar.setSelectedItem(coinTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.bounces = false
        tabbar.alwaysBounceVertical = false
        tabbar.showsVerticalScrollIndicator = false
        tabbar.preferredLayoutStyle = .fixedClusteredLeading
        
        coinList.alpha = 1
        tokenList.alpha = 0
        nftList.alpha = 0
        historyList.alpha = 0
        aboutList.alpha = 0
    }
}

extension CosmosClassVC: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if (item.tag == 0) {
            coinList.alpha = 1
            tokenList.alpha = 0
            nftList.alpha = 0
            historyList.alpha = 0
            aboutList.alpha = 0
            
        } else if (item.tag == 1) {
            coinList.alpha = 0
            tokenList.alpha = 1
            nftList.alpha = 0
            historyList.alpha = 0
            aboutList.alpha = 0
            
        } else if (item.tag == 2) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 1
            historyList.alpha = 0
            aboutList.alpha = 0
            
        } else if (item.tag == 3) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            historyList.alpha = 1
            aboutList.alpha = 0
            
        } else if (item.tag == 4) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            historyList.alpha = 0
            aboutList.alpha = 1
        }
    }
}
