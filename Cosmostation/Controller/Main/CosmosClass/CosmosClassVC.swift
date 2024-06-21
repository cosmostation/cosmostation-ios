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
    @IBOutlet weak var ecosystemList: UIView!
    @IBOutlet weak var historyList: UIView!
    @IBOutlet weak var receiveList: UIView!
    @IBOutlet weak var aboutList: UIView!
    
    var addtokenBarBtn: UIBarButtonItem!
    var addNftBarBtn: UIBarButtonItem!
    var explorerBarBtn: UIBarButtonItem!
    
    var selectedChain: BaseChain!
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
            let target = segue.destination as! CosmosNftVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedReceiveVC") {
            let target = segue.destination as! CosmosReceiveVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedHistoryVC") {
            let target = segue.destination as! CosmosHistoryVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedEcosystemVC") {
            let target = segue.destination as! CosmosEcosystemVC
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
        if (selectedChain.supportEvm) {
            evmAddessLabel.text = selectedChain.evmAddress
            starEvmAddressAnimation()
        }
        
        onSetTabbarView()
        onSetFabButton()
        
        if (selectedChain.name == "OKT" || selectedChain.supportStaking) {
            selectedChain.fetchValidatorInfos()
        }
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onShowAddress))
        addressTap.cancelsTouchesInView = false
        addressLayer.addGestureRecognizer(addressTap)
        
        let addtokenBtn: UIButton = UIButton(type: .custom)
        addtokenBtn.setImage(UIImage(named: "iconAddTokenInfo"), for: .normal)
        addtokenBtn.addTarget(self, action:  #selector(onClickAddToken), for: .touchUpInside)
        addtokenBtn.frame = CGRectMake(0, 0, 40, 30)
        addtokenBarBtn = UIBarButtonItem(customView: addtokenBtn)
        
        let addNftBtn: UIButton = UIButton(type: .custom)
        addNftBtn.setImage(UIImage(named: "iconAddNFTInfo"), for: .normal)
        addNftBtn.addTarget(self, action:  #selector(onClickAddNft), for: .touchUpInside)
        addNftBtn.frame = CGRectMake(0, 0, 40, 30)
        addNftBarBtn = UIBarButtonItem(customView: addNftBtn)
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchValidators(_:)), name: Notification.Name("FetchValidator"), object: nil)
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
        if (selectedChain.supportEvm) {
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchValidator"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (tag == selectedChain.tag) {
            totalValue = selectedChain.allValue()
        }
    }
    
    @objc func onFetchValidators(_ notification: NSNotification) {
//        print("onFetchValidators ", selectedChain.tag)
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
        guard let url = selectedChain.getExplorerAccount() else { return }
        self.onShowSafariWeb(url)
        
    }
    
    @objc func onClickAddToken() {
        let warnSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
        warnSheet.selectedChain = selectedChain
        warnSheet.noticeType = .TokenGithub
        onStartSheet(warnSheet, 420, 0.8)
    }
    
    @objc func onClickAddNft() {
        let warnSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
        warnSheet.selectedChain = selectedChain
        warnSheet.noticeType = .NFTGithub
        onStartSheet(warnSheet, 420, 0.8)
    }
    
    func onSetTabbarView() {
        let coinTabBar = UITabBarItem(title: "Coins", image: nil, tag: 0)
        let tokenTabBar = UITabBarItem(title: "Tokens", image: nil, tag: 1)
        let nftTabBar = UITabBarItem(title: "NFTs", image: nil, tag: 2)
        let receiveTabBar = UITabBarItem(title: "Receive", image: nil, tag: 3)
        let historyTabBar = UITabBarItem(title: "Histories", image: nil, tag: 4)
        let ecosystemTabBar = UITabBarItem(title: "Ecosystem", image: nil, tag: 5)
        let aboutTabBar = UITabBarItem(title: "About", image: nil, tag: 6)
        tabbar.items.append(coinTabBar)
        if (selectedChain.supportCw20 || selectedChain.supportEvm) { tabbar.items.append(tokenTabBar) }
        if (BaseData.instance.showEvenReview() && selectedChain.supportCw721) { tabbar.items.append(nftTabBar) }
        tabbar.items.append(receiveTabBar)
        tabbar.items.append(historyTabBar)
        if (BaseData.instance.showEvenReview() && selectedChain.isEcosystem() && selectedChain.isDefault) { tabbar.items.append(ecosystemTabBar) }
        if (!selectedChain.getChainListParam().isEmpty) { tabbar.items.append(aboutTabBar) }
        
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
        receiveList.alpha = 0
        historyList.alpha = 0
        ecosystemList.alpha = 0
        aboutList.alpha = 0
    }
    
    func onSetFabButton() {
        let mainFab = JJFloatingActionButton()
        mainFab.handleSingleActionDirectly = false
        mainFab.buttonImage = UIImage(named: "iconFab")
        mainFab.buttonColor = .colorPrimary
        mainFab.buttonImageSize = CGSize(width: 52, height: 52)
        mainFab.buttonAnimationConfiguration.angle = 0
        mainFab.itemAnimationConfiguration.opening = JJAnimationSettings(duration: 0.1, dampingRatio: 1.0, initialVelocity: 0.8, interItemDelay: 0.03)
        mainFab.itemAnimationConfiguration.closing = JJAnimationSettings(duration: 0.1, dampingRatio: 1.0, initialVelocity: 0.8, interItemDelay: 0.01)
        mainFab.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.8)
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
            
        } else if (selectedChain.name == "Kava") {
            if (BaseData.instance.showEvenReview()) {
                mainFab.addItem(title: "DeFi", image: UIImage(named: "iconFabDefi")) { _ in
                    self.onKavaDefi()
                }
            }
            
        } else if (selectedChain.name == "OKT") {
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
            if (selectedChain.getGrpcfetcher()?.cosmosCommissions.count ?? 0 > 0) {
                mainFab.addItem(title: "Claim Commission", image: UIImage(named: "iconFabCommission")) { _ in
                    self.onClaimCommissionTx()
                }
            }
//            if !(selectedChain is ChainBeraEVM) {                                                                       //disbale for bera
                mainFab.addItem(title: "Compound All Rewards", image: UIImage(named: "iconFabCompounding")) { _ in
                    self.onClaimCompoundingTx()
                }
                mainFab.addItem(title: "Claim All Rewards", image: UIImage(named: "iconFabClaim")) { _ in
                    self.onClaimRewardTx()
                }
//            }
            
        }
        
        mainFab.addItem(title: "Receive", image: UIImage(named: "iconFabReceive")) { _ in
            self.onShowAddress()
        }
        
        mainFab.addItem(title: "Send", image: UIImage(named: "iconFabSend")) { _ in
            self.onSendTx()
        }
        
        if (selectedChain.supportStaking) {
            mainFab.addItem(title: "Stake", image: UIImage(named: "iconFabStake")) { _ in
                self.onStakeInfo()
            }
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
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 1) {
            coinList.alpha = 0
            tokenList.alpha = 1
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn, addtokenBarBtn]
            
        } else if (item.tag == 2) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 1
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn, addNftBarBtn]
            
        } else if (item.tag == 3) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 1
            historyList.alpha = 0
            ecosystemList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 4) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 1
            ecosystemList.alpha = 0
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 5) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 1
            aboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 6) {
            coinList.alpha = 0
            tokenList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
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

//Common Action
extension CosmosClassVC {
    
    func onSendTx() {
        if (selectedChain.isBankLocked()) {
            onShowToast(NSLocalizedString("error_tranfer_disabled", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        if (selectedChain.name == "OKT") {
            if (selectedChain.tag == "okt60_Keccak") {
                let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
                transfer.sendType = .Only_EVM_Coin
                transfer.fromChain = selectedChain
                transfer.toSendDenom = selectedChain.stakeDenom
                transfer.toSendMsAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
                transfer.modalTransitionStyle = .coverVertical
                self.present(transfer, animated: true)
                
            } else {
                let transfer = LegacyTransfer(nibName: "LegacyTransfer", bundle: nil)
                transfer.selectedChain = selectedChain
                transfer.toSendDenom = selectedChain.stakeDenom!
                transfer.modalTransitionStyle = .coverVertical
                self.present(transfer, animated: true)
            }
            
        } else {
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = selectedChain.supportEvm ? .CosmosEVM_Coin : .Only_Cosmos_Coin
            transfer.fromChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.toSendMsAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
        }
    }
    
    func onClaimRewardTx() {
        guard let grpcFetcher = selectedChain.getGrpcfetcher() else {
            return
        }
        if (grpcFetcher.cosmosValidators.count <= 0) {
            onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
            return
        }
        if (grpcFetcher.rewardAllCoins().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (grpcFetcher.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_wasting_fee", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let claimRewards = CosmosClaimRewards(nibName: "CosmosClaimRewards", bundle: nil)
        claimRewards.claimableRewards = grpcFetcher.claimableRewards()
        claimRewards.selectedChain = selectedChain
        claimRewards.modalTransitionStyle = .coverVertical
        self.present(claimRewards, animated: true)
    }
    
    func onClaimCompoundingTx() {
        guard let grpcFetcher = selectedChain.getGrpcfetcher() else {
            return
        }
        if (grpcFetcher.cosmosValidators.count <= 0) {
            onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
            return
        }
        if (grpcFetcher.rewardAllCoins().count == 0) {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
            return
        }
        if (grpcFetcher.claimableRewards().count == 0) {
            onShowToast(NSLocalizedString("error_wasting_fee", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (grpcFetcher.rewardAddress != selectedChain.bechAddress) {
            onShowToast(NSLocalizedString("error_reward_address_changed_msg", comment: ""))
            return
        }
        let compounding = CosmosCompounding(nibName: "CosmosCompounding", bundle: nil)
        compounding.claimableRewards = grpcFetcher.claimableRewards()
        compounding.selectedChain = selectedChain
        compounding.modalTransitionStyle = .coverVertical
        self.present(compounding, animated: true)
    }
    
    func onClaimCommissionTx() {
        guard let grpcFetcher = selectedChain.getGrpcfetcher() else {
            return
        }
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
        guard let grpcFetcher = selectedChain.getGrpcfetcher() else {
            return
        }
        if (grpcFetcher.cosmosValidators.count <= 0) {
            onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
            return
        }
        let stakingInfoVC = CosmosStakingInfoVC(nibName: "CosmosStakingInfoVC", bundle: nil)
        stakingInfoVC.selectedChain = selectedChain
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(stakingInfoVC, animated: true)
    }
    
}

//Custom Action For Kava
extension CosmosClassVC {
    
    func onKavaDefi() {
        let defiVC = KavaDefiVC(nibName: "KavaDefiVC", bundle: nil)
        defiVC.selectedChain = selectedChain
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(defiVC, animated: true)
    }
}

//Custom Action For Neutron
extension CosmosClassVC {
    
    func onNeutronVault() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectNeutronVault
        onStartSheet(baseSheet, 240, 0.6)
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
}

//Custom Action For OKT
extension CosmosClassVC {
    
    func onOkDepositTx() {
        if let oktFetcher = selectedChain.getLcdfetcher() as? OktFetcher {
            let validators = oktFetcher.lcdOktValidators.count
            if (validators <= 0) {
                onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
                return
            }
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let okDeposit = OkDeposit(nibName: "OkDeposit", bundle: nil)
        okDeposit.selectedChain = selectedChain
        okDeposit.modalTransitionStyle = .coverVertical
        self.present(okDeposit, animated: true)
    }
    
    func onOkWithdrawTx() {
        if let oktFetcher = selectedChain.getLcdfetcher() as? OktFetcher {
            let validators = oktFetcher.lcdOktValidators.count
            let myDeposit = oktFetcher.lcdOktDepositAmount().compare(NSDecimalNumber.zero).rawValue
            if (validators <= 0) {
                onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
                return
            }
            if (myDeposit <= 0) {
                self.onShowToast(NSLocalizedString("error_no_deposited_asset", comment: ""))
                return
            }
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let okWithdraw = OkWithdraw(nibName: "OkWithdraw", bundle: nil)
        okWithdraw.selectedChain = selectedChain
        okWithdraw.modalTransitionStyle = .coverVertical
        self.present(okWithdraw, animated: true)
    }
    
    func onOkAddShareTx() {
        if let oktFetcher = selectedChain.getLcdfetcher() as? OktFetcher {
            let validators = oktFetcher.lcdOktValidators.count
            let myDeposit = oktFetcher.lcdOktDepositAmount().compare(NSDecimalNumber.zero).rawValue
            if (validators <= 0) {
                onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
                return
            }
            if (myDeposit <= 0) {
                self.onShowToast(NSLocalizedString("error_no_deposited_asset", comment: ""))
                return
            }
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let okAddShare = OkAddShare(nibName: "OkAddShare", bundle: nil)
        okAddShare.selectedChain = selectedChain
        okAddShare.modalTransitionStyle = .coverVertical
        self.present(okAddShare, animated: true)
    }
}
