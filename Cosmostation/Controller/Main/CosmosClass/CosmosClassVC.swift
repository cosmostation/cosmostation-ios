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
    @IBOutlet weak var bechAddressLabel: UILabel!
    @IBOutlet weak var evmAddessLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var hideValueBtn: UIButton!
    @IBOutlet weak var tabbar: MDCTabBarView!
    
    @IBOutlet weak var coinList: UIView!
    @IBOutlet weak var tokenList: UIView!
    @IBOutlet weak var nftList: UIView!
    @IBOutlet weak var historyList: UIView!
    @IBOutlet weak var aboutList: UIView!
    
    var addtokenBarBtn: UIBarButtonItem!
    var explorerBarBtn: UIBarButtonItem!
    
    var selectedChain: CosmosClass!
    var totalValue = NSDecimalNumber.zero {
        didSet {
            if (BaseData.instance.getHideValue()) {
                currencyLabel.text = ""
                totalValueLabel.font = .fontSize20Bold
                totalValueLabel.text = "✱✱✱✱✱"
            } else {
                totalValueLabel.font = .fontSize28Bold
                WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
            }
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
        evmAddessLabel.alpha = 0.0
        
        bechAddressLabel.text = selectedChain.bechAddress
        if (selectedChain is EvmClass) {
            evmAddessLabel.text = selectedChain.evmAddress
            starEvmAddressAnimation()
        }
        
        onSetTabbarView()
        onSetFabButton()
        if (selectedChain.supportStaking) {
            selectedChain.fetchStakeData()
        }
        
        if (selectedChain is ChainOkt996Keccak) {
            (selectedChain as? ChainOkt996Keccak)?.fetchValidators()
        }
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onShowAddress))
        addressTap.cancelsTouchesInView = false
        addressLayer.addGestureRecognizer(addressTap)
        
        let addtokenBtn: UIButton = UIButton(type: .custom)
        addtokenBtn.setImage(UIImage(named: "iconAddTokenInfo"), for: .normal)
        addtokenBtn.addTarget(self, action:  #selector(onClickAddToken), for: .touchUpInside)
        addtokenBtn.frame = CGRectMake(0, 0, 40, 30)
        addtokenBarBtn = UIBarButtonItem(customView: addtokenBtn)
        
        let explorerBtn: UIButton = UIButton(type: .custom)
        explorerBtn.setImage(UIImage(named: "iconExplorer"), for: .normal)
        explorerBtn.addTarget(self, action:  #selector(onClickExplorer), for: .touchUpInside)
        explorerBtn.frame = CGRectMake(0, 0, 30, 30)
        explorerBarBtn = UIBarButtonItem(customView: explorerBtn)
        
        navigationItem.rightBarButtonItems = [explorerBarBtn]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchTokenDone(_:)), name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchStakeDone(_:)), name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabVC = (self.parent)?.parent as? MainTabVC
        tabVC?.showChainBgImage(UIImage(named: selectedChain.logo1)!)
        if (BaseData.instance.getHideValue()) {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOff"), for: .normal)
        } else {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOn"), for: .normal)
        }
        if (selectedChain is EvmClass) {
            starEvmAddressAnimation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParent) {
            let tabVC = (self.parent)?.parent as? MainTabVC
            tabVC?.hideChainBgImg()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (tag == selectedChain.tag) {
            totalValue = selectedChain.allValue()
        }
    }
    
    @objc func onFetchTokenDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (tag == selectedChain.tag) {
            totalValue = selectedChain.allValue()
        }
    }
    
    @objc func onFetchStakeDone(_ notification: NSNotification) {
//        print("onFetchStakeDone")
    }
    
    
    @IBAction func onClickHideValue(_ sender: UIButton) {
        BaseData.instance.setHideValue(!BaseData.instance.getHideValue())
        NotificationCenter.default.post(name: Notification.Name("ToggleHideValue"), object: nil, userInfo: nil)
        if (BaseData.instance.getHideValue()) {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOff"), for: .normal)
        } else {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOn"), for: .normal)
        }
        totalValue = selectedChain.allValue()
    }
    
    @objc func onShowAddress() {
        let qrAddressVC = QrAddressVC(nibName: "QrAddressVC", bundle: nil)
        qrAddressVC.selectedChain = selectedChain
        qrAddressVC.modalPresentationStyle = .pageSheet
        present(qrAddressVC, animated: true)
    }
    
    @objc func onClickExplorer() {
        if let evmChain = selectedChain as? EvmClass {
            guard let url = URL(string:String(format: evmChain.addressURL, evmChain.evmAddress)) else { return }
            self.onShowSafariWeb(url)
        } else {
            guard let url = BaseNetWork.getAccountDetailUrl(selectedChain) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    @objc func onClickAddToken() {
        let warnSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
        warnSheet.selectedChain = selectedChain
        warnSheet.noticeType = .TokenGithub
        onStartSheet(warnSheet)
    }
    
    func onSendTx() {
        if (selectedChain.isBankLocked()) {
            onShowToast(NSLocalizedString("error_tranfer_disabled", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain is ChainBinanceBeacon || selectedChain is ChainOkt996Keccak) {
            let transfer = LegacyTransfer(nibName: "LegacyTransfer", bundle: nil)
            transfer.selectedChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            
        } else if (selectedChain is ChainOktEVM) {
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = .Only_EVM_Coin
            transfer.fromChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.toSendMsAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom)
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            
        } else {
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = (selectedChain is EvmClass) ? .CosmosEVM_Coin : .Only_Cosmos_Coin
            transfer.fromChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.toSendMsAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom)
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
    
    func onClaimCommissionTx() {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let claimCommission = CosmosClaimCommission(nibName: "CosmosClaimCommission", bundle: nil)
        claimCommission.selectedChain = selectedChain
        claimCommission.modalTransitionStyle = .coverVertical
        self.present(claimCommission, animated: true)
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
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let okDeposit = OkDeposit(nibName: "OkDeposit", bundle: nil)
        okDeposit.selectedChain = selectedChain as? ChainOkt996Keccak
        okDeposit.modalTransitionStyle = .coverVertical
        self.present(okDeposit, animated: true)
    }
    
    func onOkWithdrawTx() {
        if let oktChain = selectedChain as? ChainOkt996Keccak {
            if (oktChain.lcdOktDepositAmount().compare(NSDecimalNumber.zero).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_no_deposited_asset", comment: ""))
                return
            }
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let okWithdraw = OkWithdraw(nibName: "OkWithdraw", bundle: nil)
        okWithdraw.selectedChain = selectedChain as? ChainOkt996Keccak
        okWithdraw.modalTransitionStyle = .coverVertical
        self.present(okWithdraw, animated: true)
    }
    
    func onOkAddShareTx() {
        if let oktChain = selectedChain as? ChainOkt996Keccak {
            if (oktChain.lcdOktDepositAmount().compare(NSDecimalNumber.zero).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_no_deposited_asset", comment: ""))
                return
            }
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let okAddShare = OkAddShare(nibName: "OkAddShare", bundle: nil)
        okAddShare.selectedChain = selectedChain as? ChainOkt996Keccak
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
        if (selectedChain.supportCw20 || selectedChain is EvmClass) { tabbar.items.append(tokenTabBar) }
        if (selectedChain.supportNft) { tabbar.items.append(nftTabBar) }
        tabbar.items.append(historyTabBar)
        if (!selectedChain.mintscanChainParam.isEmpty && !(selectedChain is ChainOktEVM)) { tabbar.items.append(aboutTabBar) }
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color02, for: .normal)
        tabbar.setTitleColor(.color02, for: .selected)
        tabbar.setSelectedItem(coinTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixed
        tabbar.setContentPadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: .scrollable)
        
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
            if (!BaseData.instance.reviewMode || BaseData.instance.checkInstallTime()) {
                mainFab.addItem(title: "DeFi", image: UIImage(named: "iconFabDefi")) { _ in
                    self.onKavaDefi()
                }
            }
            
        } else if (selectedChain is ChainOkt996Keccak) {
            mainFab.addItem(title: "Select Validators", image: UIImage(named: "iconFabAddShare")) { _ in
                self.onOkAddShareTx()
            }
            mainFab.addItem(title: "Withdraw", image: UIImage(named: "iconFabWithdraw")) { _ in
                self.onOkWithdrawTx()
            }
            mainFab.addItem(title: "Deposit", image: UIImage(named: "iconFabDeposit")) { _ in
                self.onOkDepositTx()
            }
        }
        
        if (selectedChain.supportStaking) {
            mainFab.addItem(title: "Governance", image: UIImage(named: "iconFabGov")) { _ in
                self.onProposalList()
            }
            if (selectedChain.cosmosCommissions.count > 0) {
                mainFab.addItem(title: "Claim Commission", image: UIImage(named: "iconFabCommission")) { _ in
                    self.onClaimCommissionTx()
                }
            }
            mainFab.addItem(title: "Compound All Rewards", image: UIImage(named: "iconFabCompounding")) { _ in
                if (self.selectedChain.cosmosValidators.count > 0) {
                    self.onClaimCompoundingTx()
                } else {
                    self.onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
                }
            }
            mainFab.addItem(title: "Claim All Rewards", image: UIImage(named: "iconFabClaim")) { _ in
                if (self.selectedChain.cosmosValidators.count > 0) {
                    self.onClaimRewardTx()
                } else {
                    self.onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
                }
            }
            mainFab.addItem(title: "Stake", image: UIImage(named: "iconFabStake")) { _ in
                if (self.selectedChain.cosmosValidators.count > 0) {
                    self.onStakeInfo()
                } else {
                    self.onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
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
    
    func starEvmAddressAnimation() {
        bechAddressLabel.layer.removeAllAnimations()
        evmAddessLabel.layer.removeAllAnimations()
        bechAddressLabel.alpha = 0.0
        evmAddessLabel.alpha = 1.0
        
        UIView.animateKeyframes(withDuration: 10.0,
                                delay: 0,
                                options: [.repeat, .calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 4 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.evmAddessLabel.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 5 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.bechAddressLabel.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 14 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.bechAddressLabel.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 15 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.evmAddessLabel.alpha = 1.0
            }
        }
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
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 1) {
            coinList.alpha = 0
            tokenList.alpha = 1
            nftList.alpha = 0
            historyList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn, addtokenBarBtn]
            
        } else if (item.tag == 2) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 1
            historyList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 3) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            historyList.alpha = 1
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 4) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            historyList.alpha = 0
            aboutList.alpha = 1
            navigationItem.rightBarButtonItems = [explorerBarBtn]
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
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let transfer = NeutronVault(nibName: "NeutronVault", bundle: nil)
        transfer.selectedChain = selectedChain as? ChainNeutron
        transfer.vaultType = .Deposit
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onNeutronVaultwithdraw() {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let transfer = NeutronVault(nibName: "NeutronVault", bundle: nil)
        transfer.selectedChain = selectedChain as? ChainNeutron
        transfer.vaultType = .Withdraw
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onNeutronProposals() {
        let neutronDaoVC = UIStoryboard(name: "NeutronDao", bundle: nil).instantiateViewController(withIdentifier: "NeutronDaoVC") as! NeutronDaoVC
        neutronDaoVC.selectedChain = selectedChain as? ChainNeutron
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(neutronDaoVC, animated: true)
    }
    
    func onKavaDefi() {
        let defiVC = KavaDefiVC(nibName: "KavaDefiVC", bundle: nil)
        defiVC.selectedChain = selectedChain as? CosmosClass
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(defiVC, animated: true)
    }
}
