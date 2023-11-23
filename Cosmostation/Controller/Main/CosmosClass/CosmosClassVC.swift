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
    
    var selectedChain: CosmosClass!
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedCoinVC") {
            let target = segue.destination as! CosmosCoinVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedTokenVC") {
            let target = segue.destination as! CosmosTokenVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedNftVC") {
//            let target = segue.destination as! CosmosCoinVC
//            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedHistoryVC") {
            let target = segue.destination as! CosmosHistoryVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedAboutVC") {
            let target = segue.destination as! CosmosAboutVC
            target.selectedChain = selectedChain
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        totalValue = selectedChain.allValue()
        if (selectedChain is ChainOkt60Keccak || selectedChain.tag == "kava60" || selectedChain.tag == "xplaKeccak256") {
            addressLabel.text = selectedChain.evmAddress
        } else {
            addressLabel.text = selectedChain.bechAddress
        }
        
        onSetTabbarView()
        onSetFabButton()
        if (selectedChain.supportStaking) {
            selectedChain.fetchStakeData()
        }
        
        if (selectedChain is ChainOkt60Keccak) {
            (selectedChain as? ChainOkt60Keccak)?.fetchValidators()
        }
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onShowAddress))
        addressTap.cancelsTouchesInView = false
        addressLayer.addGestureRecognizer(addressTap)
        
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "iconMintscanExplorer"), style: .plain, target: self, action: #selector(onClickExplorer))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchTokenDone(_:)), name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchStakeDone(_:)), name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabVC = (self.parent)?.parent as? MainTabVC
        tabVC?.showChainBgImage(UIImage(named: selectedChain.logo1)!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParent) {
            let tabVC = (self.parent)?.parent as? MainTabVC
            tabVC?.hideChainBgImg()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    @objc func onFetchTokenDone(_ notification: NSNotification) {
        totalValue = selectedChain.allValue()
    }
    
    @objc func onFetchStakeDone(_ notification: NSNotification) {
//        print("onFetchStakeDone")
    }
    
    @objc func onShowAddress() {
        let qrAddressVC = QrAddressVC(nibName: "QrAddressVC", bundle: nil)
        qrAddressVC.selectedChain = selectedChain
        qrAddressVC.modalPresentationStyle = .pageSheet
        present(qrAddressVC, animated: true)
    }
    
    @objc func onClickExplorer() {
        guard let url = BaseNetWork.getAccountDetailUrl(selectedChain) else { return }
        self.onShowSafariWeb(url)
    }
    
    func onSendTx() {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain is ChainBinanceBeacon ||
            selectedChain is ChainOkt60Keccak) {
            let transfer = LegacyTransfer(nibName: "LegacyTransfer", bundle: nil)
            transfer.selectedChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            
        } else {
            let transfer = CosmosTransfer(nibName: "CosmosTransfer", bundle: nil)
            transfer.selectedChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
        }
    }
    
    func onClaimRewardTx() {
        if (selectedChain.rewardAllCoins().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (selectedChain.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_wasting_fee", comment: ""))
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
        if (selectedChain.rewardAllCoins().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (selectedChain.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_wasting_fee", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain.rewardAddress != selectedChain.bechAddress) {
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
    
    func onOkDepositTx() {
        let okDeposit = OkDeposit(nibName: "OkDeposit", bundle: nil)
        okDeposit.selectedChain = selectedChain as? ChainOkt60Keccak
        okDeposit.modalTransitionStyle = .coverVertical
        self.present(okDeposit, animated: true)
    }
    
    func onOkWithdrawTx() {
        let okWithdraw = OkWithdraw(nibName: "OkWithdraw", bundle: nil)
        okWithdraw.selectedChain = selectedChain as? ChainOkt60Keccak
        okWithdraw.modalTransitionStyle = .coverVertical
        self.present(okWithdraw, animated: true)
    }
    
    func onOkAddShareTx() {
        let okAddShare = OkAddShare(nibName: "OkAddShare", bundle: nil)
        okAddShare.selectedChain = selectedChain as? ChainOkt60Keccak
        okAddShare.modalTransitionStyle = .coverVertical
        self.present(okAddShare, animated: true)
    }
    
    func onSetTabbarView() {
        let coinTabBar = UITabBarItem(title: "Coins", image: nil, tag: 0)
        let tokenTabBar = UITabBarItem(title: "Tokens", image: nil, tag: 1)
        let nftTabBar = UITabBarItem(title: "NFTs", image: nil, tag: 2)
        let historyTabBar = UITabBarItem(title: "Histories", image: nil, tag: 3)
        let aboutTabBar = UITabBarItem(title: "About", image: nil, tag: 4)
        tabbar.items.append(coinTabBar)
        if (selectedChain.supportCw20 || selectedChain.supportErc20) { tabbar.items.append(tokenTabBar) }
        if (selectedChain.supportNft) { tabbar.items.append(nftTabBar) }
        tabbar.items.append(historyTabBar)
        if (!selectedChain.mintscanChainParam.isEmpty) { tabbar.items.append(aboutTabBar) }
        
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
        mainFab.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        mainFab.configureDefaultItem { item in
            item.titlePosition = .leading
            item.titleLabel.font = .fontSize12Bold
            item.titleLabel.textColor = .color01
            item.buttonColor = .color08
            item.buttonImageColor = .color01
            item.imageSize = CGSize(width: 24, height: 24)
        }
        
        
        
        if (selectedChain is ChainNeutron) {
            mainFab.addItem(title: "Vault", image: UIImage(named: "iconFabVault")) { _ in
                self.onNeutronVault()
            }
            mainFab.addItem(title: "Dao", image: UIImage(named: "iconFabDao")) { _ in
                self.onNeutronProposals()
            }
            
        } else if (selectedChain is ChainKava118 || selectedChain is ChainKava459) {
            mainFab.addItem(title: "DeFi", image: UIImage(named: "iconFabDefi")) { _ in
                self.onKavaDefi()
            }
            
        } else if (selectedChain is ChainOkt60Keccak) {
            mainFab.addItem(title: "Select Validators", image: UIImage(named: "iconFabDefi")) { _ in
                self.onOkAddShareTx()
            }
            mainFab.addItem(title: "Withdraw", image: UIImage(named: "iconFabDefi")) { _ in
                self.onOkWithdrawTx()
            }
            mainFab.addItem(title: "Deposit", image: UIImage(named: "iconFabDefi")) { _ in
                self.onOkDepositTx()
            }
        }
        
        if (selectedChain.supportStaking) {
            mainFab.addItem(title: "Governance", image: UIImage(named: "iconFabGov")) { _ in
                self.onProposalList()
            }
            mainFab.addItem(title: "Compounding All", image: UIImage(named: "iconFabCompounding")) { _ in
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
        }
        
        if (mainFab.items.count < 4) {
            mainFab.addItem(title: "Receive", image: UIImage(named: "iconFabReceive")) { _ in
                self.onShowAddress()
            }
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

extension CosmosClassVC: MDCTabBarViewDelegate, BaseSheetDelegate {
    
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
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectNeutronVault) {
            if let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onNeutronVaultDeposit()
                    } else if (index == 1) {
                        self.onNeutronVaultwithdraw()
                    }
                });
            }
        }
    }
    
    
}


extension CosmosClassVC {
    
    func onNeutronVault() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectNeutronVault
        onStartSheet(baseSheet, 240)
    }
    
    func onNeutronVaultDeposit() {
        let transfer = NeutronVault(nibName: "NeutronVault", bundle: nil)
        transfer.selectedChain = selectedChain as? ChainNeutron
        transfer.vaultType = .Deposit
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onNeutronVaultwithdraw() {
        let transfer = NeutronVault(nibName: "NeutronVault", bundle: nil)
        transfer.selectedChain = selectedChain as? ChainNeutron
        transfer.vaultType = .Withdraw
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onNeutronProposals() {
        let proposalsVC = NeutronPrpposalsVC(nibName: "NeutronPrpposalsVC", bundle: nil)
        proposalsVC.selectedChain = selectedChain as? ChainNeutron
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(proposalsVC, animated: true)
    }
    
    func onKavaDefi() {
        let defiVC = KavaDefiVC(nibName: "KavaDefiVC", bundle: nil)
        defiVC.selectedChain = selectedChain as? ChainKava60
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(defiVC, animated: true)
    }
}
