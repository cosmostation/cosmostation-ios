//
//  EvmClassVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/01/25.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import JJFloatingActionButton
import SwiftyJSON

class EvmClassVC: BaseVC {
    
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
    
    var addtokenBarBtn: UIBarButtonItem!
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
    
    var evmAssetVC: EvmAssetVC?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedAssetVC") {
            let target = segue.destination as! EvmAssetVC
            target.selectedChain = selectedChain
            evmAssetVC = target
        } else if (segue.identifier == "embedNftVC") {
            let target = segue.destination as! EvmNftVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedReceiveVC") {
            let target = segue.destination as! EvmReceiveVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedHistoryVC") {
            let target = segue.destination as! EvmHistoryVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedEcosystemVC") {
            let target = segue.destination as! EvmEcosystemVC
            target.selectedChain = selectedChain
        } else if (segue.identifier == "embedAboutVC") {
            let target = segue.destination as! EvmAboutVC
            target.selectedChain = selectedChain
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        totalValue = selectedChain.allValue()
        addressLabel.text = selectedChain.evmAddress
        
        if selectedChain.isSupportEthStaking() {
            onSetFabButton()
        }
        onSetTabbarView()
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(onShowAddress))
        addressTap.cancelsTouchesInView = false
        addressLayer.addGestureRecognizer(addressTap)
        
        let addtokenBtn: UIButton = UIButton(type: .custom)
        addtokenBtn.setImage(UIImage(named: "iconAddToken"), for: .normal)
        addtokenBtn.addTarget(self, action:  #selector(onClickAddToken), for: .touchUpInside)
        addtokenBtn.frame = CGRectMake(0, 0, 40, 30)
        addtokenBarBtn = UIBarButtonItem(customView: addtokenBtn)
        
        let explorerBtn: UIButton = UIButton(type: .custom)
        explorerBtn.setImage(UIImage(named: "iconExplorer"), for: .normal)
        explorerBtn.addTarget(self, action:  #selector(onClickExplorer), for: .touchUpInside)
        explorerBtn.frame = CGRectMake(0, 0, 30, 30)
        explorerBarBtn = UIBarButtonItem(customView: explorerBtn)
        
        
        if #available(iOS 26.0, *) {
            addtokenBarBtn.sharesBackground = false
            explorerBarBtn.sharesBackground = false
        }
        navigationItem.rightBarButtonItems = [explorerBarBtn, addtokenBarBtn]
        
        let titleView = BgRandomButton()
        titleView.setName(baseAccount?.getRefreshName())
        navigationItem.titleView = titleView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (tag == selectedChain.tag) {
            totalValue = selectedChain.allValue()
        }
    }
    
    func onSetTabbarView() {
        let assetTabBar = UITabBarItem(title: "Crypto", image: nil, tag: 0)
//        let nftTabBar = UITabBarItem(title: "NFTs", image: nil, tag: 1)
        let receiveTabBar = UITabBarItem(title: "Receive", image: nil, tag: 2)
        let historyTabBar = UITabBarItem(title: "History", image: nil, tag: 3)
        let ecosystemTabBar = UITabBarItem(title: "Ecosystem", image: nil, tag: 4)
        let aboutTabBar = UITabBarItem(title: "About", image: nil, tag: 5)
        tabbar.items.append(assetTabBar)
//        if (BaseData.instance.showEvenReview()) { tabbar.items.append(nftTabBar) }
        tabbar.items.append(receiveTabBar)
        if !(selectedChain is ChainBeraEVM || selectedChain is ChainStoryEVM) { tabbar.items.append(historyTabBar) }
        if (BaseData.instance.showEvenReview() && selectedChain.isSupportMobileDapp()) { tabbar.items.append(ecosystemTabBar) }
        if (!selectedChain.getChainListParam().isEmpty) {
            tabbar.items.append(aboutTabBar)
        }
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color03, for: .normal)
        tabbar.setTitleColor(.color01, for: .selected)
        tabbar.setSelectedItem(assetTabBar, animated: false)
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
        let mainFab = JJFloatingActionButton()
        mainFab.handleSingleActionDirectly = true
        mainFab.buttonImageSize = CGSize(width: 52, height: 52)
        mainFab.buttonColor = .clear
        mainFab.buttonAnimationConfiguration.angle = 0
        mainFab.itemAnimationConfiguration.opening = JJAnimationSettings(duration: 0.1, dampingRatio: 1.0, initialVelocity: 0.8, interItemDelay: 0.03)
        mainFab.itemAnimationConfiguration.closing = JJAnimationSettings(duration: 0.1, dampingRatio: 1.0, initialVelocity: 0.8, interItemDelay: 0.01)
        mainFab.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        mainFab.addItem(title: nil, image: UIImage(named: "iconEthFab")) { _ in
            self.tapFloatingBtn()
        }
        
        view.addSubview(mainFab)
        mainFab.translatesAutoresizingMaskIntoConstraints = false
        mainFab.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        mainFab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
    }
    
    func tapFloatingBtn() {
        if (!BaseData.instance.showEvenReview()) { return }
        if BaseData.instance.getEcosystemPopUpActiveStatus(SheetType.MoveEthStaking) {
            let dappPopUpView = EcosystemPopUpSheet(nibName: "EcosystemPopUpSheet", bundle: nil)
            dappPopUpView.selectedChain = selectedChain
            dappPopUpView.tag = SheetType.MoveEthStaking.rawValue
            dappPopUpView.sheetDelegate = self
            dappPopUpView.modalPresentationStyle = .overFullScreen
            self.present(dappPopUpView, animated: true)
        } else {
            onSelectedSheet(SheetType.MoveEthStaking, [:])
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
    
    @objc func onClickAddToken() {
        if (evmAssetVC != nil) {
            evmAssetVC?.onShowTokenListSheet()
        }
    }
}


extension EvmClassVC: MDCTabBarViewDelegate, BaseSheetDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if (item.tag == 0) {
            assetList.alpha = 1
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn, addtokenBarBtn]
            
        } else if (item.tag == 1) {
            assetList.alpha = 0
            nftList.alpha = 1
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 2) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 1
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 3) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 1
            ecosystemList.alpha = 0
            AboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 4) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 1
            AboutList.alpha = 0
            navigationItem.rightBarButtonItems = [explorerBarBtn]
            
        } else if (item.tag == 5) {
            assetList.alpha = 0
            nftList.alpha = 0
            receiveList.alpha = 0
            historyList.alpha = 0
            ecosystemList.alpha = 0
            AboutList.alpha = 1
            navigationItem.rightBarButtonItems = [explorerBarBtn]
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
        dappDetail.dappType = .INTERNAL_URL
        dappDetail.dappUrl = URL(string: selectedChain.ethStakingExplorerUrl())
        dappDetail.modalPresentationStyle = .fullScreen
        self.present(dappDetail, animated: true)
    }
}
