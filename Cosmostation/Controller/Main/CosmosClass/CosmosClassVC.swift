//
//  CosmosClassVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import JJFloatingActionButton
import SwiftyJSON

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
        onSetFabButton()
        selectedChain.fetchStakeData()
        
        print("selectedChain address ", selectedChain.address)
//        navigationController?.navigationBar.topItem?.title = baseAccount.name
//        let backBarButtonItem = UIBarButtonItem(title: "Zedd", style: .plain, target: self, action: nil)
//        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onShowAddress))
        addressTap.cancelsTouchesInView = false
        addressLayer.addGestureRecognizer(addressTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchTokenDone(_:)), name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchStakeDone(_:)), name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    @objc func onFetchTokenDone(_ notification: NSNotification) {
        totalValue = selectedChain.allValue()
    }
    
    @objc func onFetchStakeDone(_ notification: NSNotification) {
        print("onFetchStakeDone")
    }
    
    @objc func onShowAddress() {
        let qrAddressVC = QrAddressVC(nibName: "QrAddressVC", bundle: nil)
        qrAddressVC.selectedChain = selectedChain
        qrAddressVC.modalPresentationStyle = .pageSheet
        present(qrAddressVC, animated: true)
    }
    
    func onSendTx() {
        let transfer = CosmosTransfer(nibName: "CosmosTransfer", bundle: nil)
        transfer.selectedChain = selectedChain
        transfer.toSendDenom = selectedChain.stakeDenom
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onClaimRewardTx() {
        if (selectedChain.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let claimRewards = CosmosClaimRewards(nibName: "CosmosClaimRewards", bundle: nil)
        claimRewards.claimableRewards = selectedChain.claimableRewards()
        claimRewards.selectedChain = selectedChain
        claimRewards.modalTransitionStyle = .coverVertical
        self.present(claimRewards, animated: true)
    }
    
    func onClaimCompoundingTx() {
        if (selectedChain.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain.rewardAddress != selectedChain.address) {
            onShowToast(NSLocalizedString("error_reward_address_changed_msg", comment: ""))
            return
        }
        let compounding = CosmosCompounding(nibName: "CosmosCompounding", bundle: nil)
        compounding.claimableRewards = selectedChain.claimableRewards()
        compounding.selectedChain = selectedChain
        compounding.modalTransitionStyle = .coverVertical
        self.present(compounding, animated: true)
    }
    
    func onProposalList() {
        let proposalsVC = CosmosProposalsVC(nibName: "CosmosProposalsVC", bundle: nil)
        proposalsVC.selectedChain = selectedChain
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(proposalsVC, animated: true)
    }
    
    func onStakeInfo() {
        let stakingInfoVC = CosmosStakingInfoVC(nibName: "CosmosStakingInfoVC", bundle: nil)
        stakingInfoVC.selectedChain = selectedChain
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(stakingInfoVC, animated: true)
    }
    
    func onSetTabbarView() {
        let coinTabBar = UITabBarItem(title: "Coins", image: nil, tag: 0)
        let tokenTabBar = UITabBarItem(title: "Tokens", image: nil, tag: 1)
        let nftTabBar = UITabBarItem(title: "NFTs", image: nil, tag: 2)
        let historyTabBar = UITabBarItem(title: "Histories", image: nil, tag: 3)
        let aboutTabBar = UITabBarItem(title: "About", image: nil, tag: 4)
//        tabbar.items = [ coinTabBar, tokenTabBar, historyTabBar]
//        tabbar.items = [ coinTabBar, tokenTabBar, nftTabBar, historyTabBar, aboutTabBar]
        tabbar.items.append(coinTabBar)
        if (selectedChain.supportCw20 || selectedChain.supportErc20) { tabbar.items.append(tokenTabBar) }
        if (selectedChain.supportNft) { tabbar.items.append(nftTabBar) }
        tabbar.items.append(historyTabBar)
        tabbar.items.append(aboutTabBar)
        
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
    
    func onSetFabButton() {
        let mainFab = JJFloatingActionButton()
        mainFab.handleSingleActionDirectly = false
        mainFab.buttonImage = UIImage(named: "iconFab")
        mainFab.buttonColor = .colorPrimary
        mainFab.buttonImageSize = CGSize(width: 40, height: 40)
        mainFab.itemAnimationConfiguration.opening = JJAnimationSettings(duration: 0.1, dampingRatio: 1.0, initialVelocity: 0.8, interItemDelay: 0.03)
        mainFab.itemAnimationConfiguration.closing = JJAnimationSettings(duration: 0.1, dampingRatio: 1.0, initialVelocity: 0.8, interItemDelay: 0.01)
        mainFab.configureDefaultItem { item in
            item.titlePosition = .leading
            item.titleLabel.font = .fontSize12Bold
            item.titleLabel.textColor = .color01
            item.buttonColor = .color01
            item.buttonImageColor = .colorPrimary
            item.imageSize = CGSize(width: 24, height: 24)

//            item.layer.shadowColor = UIColor.black.cgColor
//            item.layer.shadowOffset = CGSize(width: 0, height: 1)
//            item.layer.shadowOpacity = Float(0.4)
//            item.layer.shadowRadius = CGFloat(2)
        }
        
        mainFab.addItem(title: "Governance", image: UIImage(named: "iconFabGov")) { _ in
            self.onProposalList()
        }
        mainFab.addItem(title: "Compounding All", image: UIImage(named: "iconFabClaim")) { _ in
            if (self.selectedChain.cosmosValidators.count > 0) {
                self.onClaimCompoundingTx()
            }
        }
        mainFab.addItem(title: "Claim Reward All", image: UIImage(named: "iconFabClaim")) { _ in
            if (self.selectedChain.cosmosValidators.count > 0) {
                self.onClaimRewardTx()
            }
        }
        mainFab.addItem(title: "Stake", image: UIImage(named: "iconFabStake")) { _ in
            if (self.selectedChain.cosmosValidators.count > 0) {
                self.onStakeInfo()
            }
        }
        mainFab.addItem(title: "Receive", image: UIImage(named: "iconFabReceive")) { _ in
            self.onShowAddress()
        }
        mainFab.addItem(title: "Send", image: UIImage(named: "iconFabSend")) { _ in
            self.onSendTx()
        }
        
        view.addSubview(mainFab)
        mainFab.translatesAutoresizingMaskIntoConstraints = false
        mainFab.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        mainFab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
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
