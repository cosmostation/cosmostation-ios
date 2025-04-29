//
//  MajorClassVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import JJFloatingActionButton
import SwiftyJSON

class MajorClassVC: BaseVC {
    
    @IBOutlet weak var addressLayer: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var hideValueBtn: UIButton!
    @IBOutlet weak var tabbar: MDCTabBarView!
    
    @IBOutlet weak var assetList: UIView!
    @IBOutlet weak var nftList: UIView!
    @IBOutlet weak var receiveList: UIView!
    @IBOutlet weak var historyList: UIView!
    @IBOutlet weak var ecosystemList: UIView!
    @IBOutlet weak var AboutList: UIView!
    
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
    
    var majorCryptoVC: MajorCryptoVC?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "majorCryptoVC") {
            let target = segue.destination as! MajorCryptoVC
            majorCryptoVC = target
            target.selectedChain = selectedChain
        } else if (segue.identifier == "majorNftVC") {
            let target = segue.destination as! MajorNftVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "majorReceiveVC") {
            let target = segue.destination as! MajorReceiveVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "majorHistoryVC") {
            let target = segue.destination as! MajorHistoryVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "majorEcosystemVC") {
            let target = segue.destination as! MajorEcosystemVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "majorAboutVC") {
            let target = segue.destination as! MajorAboutVC
            target.selectedChain = selectedChain
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        totalValue = selectedChain.allValue()
        addressLabel.text = selectedChain.mainAddress
        
        onSetTabbarView()
        if (selectedChain is ChainSui || selectedChain.isSupportBTCStaking() || selectedChain is ChainIota) {
            onSetFabButton()
        }
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onShowAddress))
        addressTap.cancelsTouchesInView = false
        addressLayer.addGestureRecognizer(addressTap)
        
        let explorerBtn: UIButton = UIButton(type: .custom)
        explorerBtn.setImage(UIImage(named: "iconExplorer"), for: .normal)
        explorerBtn.addTarget(self, action:  #selector(onClickExplorer), for: .touchUpInside)
        explorerBtn.frame = CGRectMake(0, 0, 30, 30)
        explorerBarBtn = UIBarButtonItem(customView: explorerBtn)
        
        navigationItem.rightBarButtonItems = [explorerBarBtn]
        navigationItem.titleView = BgRandomButton()
        
        Task {
            if let babylonBtcFetcher = (selectedChain as? ChainBitCoin86)?.getBabylonBtcFetcher(),
               selectedChain.isSupportBTCStaking(),
               let btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher() {
                _ = await babylonBtcFetcher.fetchFinalityProvidersInfo()
                btcFetcher.fastestFee = try await btcFetcher.fetchFee()?["fastestFee"].intValue
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabVC = (self.parent)?.parent as? MainTabVC
        tabVC?.showChainBgImage(selectedChain.getChainImage())
        if (BaseData.instance.getHideValue()) {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOff"), for: .normal)
        } else {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOn"), for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParent) {
            let tabVC = (self.parent)?.parent as? MainTabVC
            tabVC?.hideChainBgImg()
        }
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
    
    func onSetTabbarView() {
        let coinTabBar = UITabBarItem(title: "Crypto", image: nil, tag: 0)
        let nftTabBar = UITabBarItem(title: "NFTs", image: nil, tag: 1)
        let receiveTabBar = UITabBarItem(title: "Receive", image: nil, tag: 2)
        let historyTabBar = UITabBarItem(title: "History", image: nil, tag: 3)
        let ecosystemTabBar = UITabBarItem(title: "Ecosystem", image: nil, tag: 4)
        let aboutTabBar = UITabBarItem(title: "About", image: nil, tag: 5)
        
        tabbar.items.append(coinTabBar)
        if (selectedChain is ChainSui) {
            if (BaseData.instance.showEvenReview()) { tabbar.items.append(nftTabBar) }
            tabbar.items.append(receiveTabBar)
            tabbar.items.append(historyTabBar)
            if (BaseData.instance.showEvenReview()) { tabbar.items.append(ecosystemTabBar) }
            tabbar.items.append(aboutTabBar)
            
        } else if  (selectedChain is ChainBitCoin86) {
            tabbar.items.append(receiveTabBar)
            tabbar.items.append(historyTabBar)
            tabbar.items.append(aboutTabBar)
            
        } else if (selectedChain is ChainIota) {
            if (BaseData.instance.showEvenReview()) { tabbar.items.append(nftTabBar) }
            tabbar.items.append(receiveTabBar)
            tabbar.items.append(historyTabBar)
            if (BaseData.instance.showEvenReview() && selectedChain.isSupportMobileDapp()) { tabbar.items.append(ecosystemTabBar) }
            tabbar.items.append(aboutTabBar)
        }
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color03, for: .normal)
        tabbar.setTitleColor(.color01, for: .selected)
        tabbar.setSelectedItem(coinTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixed
        tabbar.setContentPadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: .scrollable)
        
        assetList.alpha = 1
        nftList.alpha = 0
        receiveList.alpha = 0
        historyList.alpha = 0
        ecosystemList.alpha = 0
        AboutList.alpha = 0
    }
    
    
    func onSetFabButton() {
        if (selectedChain is ChainBitCoin44 || selectedChain is ChainBitCoin49) { return }
        
        let mainFab = JJFloatingActionButton()
        mainFab.handleSingleActionDirectly = true
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
        
        if (selectedChain is ChainSui) {
            mainFab.addItem(title: "Earn", image: UIImage(named: "iconFab")) { _ in
                self.onSuiStake()
            }
        } else if (selectedChain.isSupportBTCStaking()) {
            mainFab.addItem(title: "Earn", image: UIImage(named: "iconFab")) { _ in
                self.onBtcStake()
            }
        } else if (selectedChain is ChainIota) {
            mainFab.addItem(title: "Earn", image: UIImage(named: "iconFab")) { _ in
                self.onIotaStake()
            }

        }
        
        view.addSubview(mainFab)
        mainFab.translatesAutoresizingMaskIntoConstraints = false
        mainFab.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        mainFab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
    }

}


extension MajorClassVC: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if (item.tag == 0) {
            assetList.alpha = 1
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            
        } else if (item.tag == 1) {
            assetList.alpha = 0
            nftList.alpha = 1
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            
        } else if (item.tag == 2) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 1
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            
        } else if (item.tag == 3) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 1
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            
        } else if (item.tag == 4) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 1
            AboutList.alpha = 0
            
        } else if (item.tag == 5) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 1
        }
    }
}


extension MajorClassVC {
    
    func onSuiStake() {
        
        //TODO check gas
        let stakingInfoVC = SuiStakingInfoVC(nibName: "SuiStakingInfoVC", bundle: nil)
        stakingInfoVC.selectedChain = selectedChain as? ChainSui
        stakingInfoVC.majorCryptoVC = majorCryptoVC
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(stakingInfoVC, animated: true)
        
    }
    
    func onIotaStake() {
        let stakingInfoVC = IotaStakingInfoVC(nibName: "IotaStakingInfoVC", bundle: nil)
        stakingInfoVC.selectedChain = selectedChain as? ChainIota
        stakingInfoVC.majorCryptoVC = majorCryptoVC
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(stakingInfoVC, animated: true)
        
    }

    
    func onBtcStake() {
        if selectedChain.isStakeEnabled() {
            if let babylonBtcFetcher = (selectedChain as? ChainBitCoin86)?.getBabylonBtcFetcher() {
                if babylonBtcFetcher.finalityProviders.isEmpty {
                    onShowToast(NSLocalizedString("error_wait_moment", comment: ""))
                    return
                }
            }
            
            let stakingInfoVC = BtcStakingInfoVC(nibName: "BtcStakingInfoVC", bundle: nil)
            stakingInfoVC.selectedChain = selectedChain as? ChainBitCoin86
            self.navigationController?.pushViewController(stakingInfoVC, animated: true)
            
        } else {
            if (!BaseData.instance.showEvenReview()) { onShowToast("Please try again later."); return }
            
            if BaseData.instance.getEcosystemPopUpActiveStatus(.MoveBabylonDappDetail) {
                let dappPopUpView = EcosystemPopUpSheet(nibName: "EcosystemPopUpSheet", bundle: nil)
                dappPopUpView.selectedChain = selectedChain
                dappPopUpView.tag = 102
                dappPopUpView.sheetDelegate = self
                dappPopUpView.modalPresentationStyle = .overFullScreen
                self.present(dappPopUpView, animated: true)
                
            } else {
                onSelectedSheet(.MoveBabylonDappDetail, [:])
            }
            
        }
    }

    
    
}

extension MajorClassVC: BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if sheetType == .MoveBabylonDappDetail {
            let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
            dappDetail.dappType = .INTERNAL_URL
            dappDetail.dappUrl = URL(string: selectedChain.btcStakingExplorerUrl())
            dappDetail.btcTargetChain = selectedChain
            dappDetail.modalPresentationStyle = .fullScreen
            self.present(dappDetail, animated: true)
        }
    }
}
