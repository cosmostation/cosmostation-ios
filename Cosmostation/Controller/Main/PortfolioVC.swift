//
//  PortfolioVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import BigInt
import SwiftyJSON

class PortfolioVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchEmptyLayer: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var hideValueBtn: UIButton!
    
    var refresher: UIRefreshControl!
    var searchBar: UISearchBar?
    
    var mainnetChains = [BaseChain]()
    var searchMainnets = [BaseChain]()
    var testnetChains = [BaseChain]()
    var searchTestnets = [BaseChain]()
    
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
    
    var lastSortingType: SortingType = .value
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        tableView.register(UINib(nibName: "Portfolio2Cell", bundle: nil), forCellReuseIdentifier: "Portfolio2Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar?.searchTextField.textColor = .color01
        searchBar?.tintColor = UIColor.white
        searchBar?.barTintColor = UIColor.clear
        searchBar?.searchTextField.font = .fontSize14Bold
        searchBar?.backgroundImage = UIImage()
        searchBar?.delegate = self
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        
        navigationItem.titleView = BgRandomButton()
        
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var contentOffset: CGPoint = tableView.contentOffset
        if (contentOffset == CGPoint(x: 0, y: 0) && 
            tableView.tableHeaderView != nil &&
            searchBar?.text?.isEmpty == true) {
            contentOffset.y += (tableView.tableHeaderView?.frame)!.height
            tableView.contentOffset = contentOffset
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchPrice(_:)), name: Notification.Name("FetchPrice"), object: nil)
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.getRefreshName())
        onUpdateVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchPrice"), object: nil)
    }
    
    func initView() {
        baseAccount = BaseData.instance.baseAccount
        
        mainnetChains = baseAccount.getDpChains().filter({ $0.isTestnet == false })
        searchMainnets = mainnetChains
        
        testnetChains = baseAccount.getDpChains().filter({ $0.isTestnet == true }).sorted{ $0.name < $1.name }
        searchTestnets = testnetChains
        
        onUpdateSearchBar()
        currencyLabel.text = BaseData.instance.getCurrencySymbol()
        
        let sortType = UserDefaults.standard.string(forKey: KEY_CHAIN_SORT) ?? SortingType.value.rawValue
        lastSortingType = SortingType(rawValue: sortType)!
        
        navigationItem.rightBarButtonItems = rightBarButton()
        navigationItem.rightBarButtonItems?.last?.isEnabled = false
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @objc func onRequestFetch() {
        navigationItem.rightBarButtonItems?.last?.isEnabled = false
        if (baseAccount.getDpChains().filter { $0.fetchState == .Busy }.count > 0) {
            refresher.endRefreshing()
        } else {
            BaseNetWork().fetchPrices()
            baseAccount.getDpChains().forEach { $0.fetchState = .Idle }
            baseAccount?.fetchDpChains()
            tableView.reloadData()
            refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        Task {
            onUpdateRow(tag)
            onUpdateSortButton()
        }
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        tableView.reloadData()
        onUpdateTotal()
    }
    
    func onUpdateVC() {
        tableView.reloadData()
        onUpdateHideValue()
        onUpdateTotal()
        onUpdateSortButton()
    }
    
    func onUpdateRow(_ tag: String) {
        for i in 0..<searchMainnets.count {
            if (searchMainnets[i].tag == tag) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                })
            }
        }
        for i in 0..<searchTestnets.count {
            if (searchTestnets[i].tag == tag) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .none)
                    self.tableView.endUpdates()
                })
            }
        }
        onUpdateTotal()
    }
    
    func onUpdateHideValue() {
        if (BaseData.instance.getHideValue()) {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOff"), for: .normal)
        } else {
            hideValueBtn.setImage(UIImage.init(named: "iconHideValueOn"), for: .normal)
        }
    }
    
    func onUpdateTotal() {
        var sum = NSDecimalNumber.zero
        baseAccount.getDpChains().forEach { chain in
            sum = sum.adding(chain.allValue())
        }
        DispatchQueue.main.async {
            self.totalValue = sum
        }
    }
    
    func onUpdateSortButton() {
        if baseAccount.getDpChains().filter({ $0.fetchState == .Busy }).count == 0 {
            self.navigationItem.rightBarButtonItems?.last?.isEnabled = true
        }
    }
    
    @IBAction func onClickHideValue(_ sender: UIButton) {
        BaseData.instance.setHideValue(!BaseData.instance.getHideValue())
        onUpdateVC()
    }
    
    @objc func onClickChainSelect() {
        let chainSelectVC = ChainSelectVC(nibName: "ChainSelectVC", bundle: nil)
        chainSelectVC.modalTransitionStyle = .coverVertical
        chainSelectVC.onChainSelected = {
            self.onChainSelected()
        }
        chainSelectVC.chainSortingDelegate = self
        self.present(chainSelectVC, animated: true)
    }
    
    func chainSortReloadView() {
        switch lastSortingType {
        case .name:
            mainnetChains.sort {
                if ($0.tag == "cosmos118") { return true }
                if ($1.tag == "cosmos118") { return false }
                return $0.name < $1.name
            }
        case .value:
            mainnetChains.sort {
                if ($0.tag == "cosmos118") { return true }
                if ($1.tag == "cosmos118") { return false }
                return $0.allValue(true).compare($1.allValue(true)).rawValue > 0 ? true : false
            }
        }
        
        searchMainnets = searchBar!.text!.isEmpty ? mainnetChains : mainnetChains.filter { chain in
            return chain.name.range(of: searchBar!.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchTestnets = searchBar!.text!.isEmpty ? testnetChains : testnetChains.filter { chain in
            return chain.name.range(of: searchBar!.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()

        if let button = navigationItem.rightBarButtonItems?[1].customView as? UIButton {
            button.setImage(UIImage(named: SortingType(rawValue: lastSortingType.rawValue)!.rawValue), for: .normal)
        }
    }
    
    func onChainSelected() {
        baseAccount.fetchDpChains()
        mainnetChains = baseAccount.getDpChains().filter({ $0.isTestnet == false })
        searchMainnets = mainnetChains
        
        testnetChains = baseAccount.getDpChains().filter({ $0.isTestnet == true }).sorted{ $0.name < $1.name }
        searchTestnets = testnetChains
        
        searchEmptyLayer.isHidden = true
        tableView.reloadData()
        onUpdateSearchBar()
        onUpdateTotal()
    }
    
    func onUpdateSearchBar() {
        if (mainnetChains.count + testnetChains.count < 10) {
            tableView.tableHeaderView = nil
            tableView.headerView(forSection: 0)?.layoutSubviews()
        } else {
            searchBar?.text = ""
            tableView.tableHeaderView = searchBar
            tableView.headerView(forSection: 0)?.layoutSubviews()
        }
    }
    
    func onNodedownPopup(_ baseChain: BaseChain) {
        let warnSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
        warnSheet.selectedChain = baseChain
        warnSheet.noticeType = .NodeDownGuide
        warnSheet.noticeDelegate = self
        onStartSheet(warnSheet, 420, 0.6)
    }
}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && searchMainnets.count == 0) { return nil }
        if (section == 1 && searchTestnets.count == 0) { return nil }
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Mainnet"
            view.cntLabel.text = String(searchMainnets.count)
        } else if (section == 1) {
            view.titleLabel.text = "Testnet"
            view.cntLabel.text = String(searchTestnets.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return mainnetChains.count == 0 ? 0 : 40
        } else if (section == 1) {
            return testnetChains.count == 0 ? 0 : 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return searchMainnets.count
        } else if (section == 1) {
            return searchTestnets.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (BaseData.instance.getStyle() == ProtfolioStyle.Simple.rawValue) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell") as! PortfolioCell
            if (indexPath.section == 0) {
                cell.bindChain(baseAccount, searchMainnets[indexPath.row])
            } else if (indexPath.section == 1) {
                cell.bindChain(baseAccount, searchTestnets[indexPath.row])
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"Portfolio2Cell") as! Portfolio2Cell
            if (indexPath.section == 0) {
                cell.bindChain(baseAccount, searchMainnets[indexPath.row])
            } else if (indexPath.section == 1) {
                cell.bindChain(baseAccount, searchTestnets[indexPath.row])
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var chain: BaseChain!
        if (indexPath.section == 0) {
            chain = searchMainnets[indexPath.row]
        } else {
            chain = searchTestnets[indexPath.row]
        }
        
        if (chain.fetchState == .Fail) {
            onNodedownPopup(chain)
            return
        }
        if (chain.fetchState != .Success) {
            return
        }
        
        if (chain.supportCosmos) {
            let cosmosClassVC = UIStoryboard(name: "CosmosClass", bundle: nil).instantiateViewController(withIdentifier: "CosmosClassVC") as! CosmosClassVC
            cosmosClassVC.selectedChain = chain
            cosmosClassVC.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.getRefreshName())
            self.navigationController?.pushViewController(cosmosClassVC, animated: true)
            
        } else if (chain.supportEvm) {
            let evmClassVC = UIStoryboard(name: "EvmClass", bundle: nil).instantiateViewController(withIdentifier: "EvmClassVC") as! EvmClassVC
            evmClassVC.selectedChain = chain
            evmClassVC.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.getRefreshName())
            self.navigationController?.pushViewController(evmClassVC, animated: true)
            
        } else if (!chain.mainAddress.isEmpty) {
            let majorClass = UIStoryboard(name: "MajorClass", bundle: nil).instantiateViewController(withIdentifier: "MajorClassVC") as! MajorClassVC
            majorClass.selectedChain = chain
            majorClass.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.getRefreshName())
            self.navigationController?.pushViewController(majorClass, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var chain: BaseChain!
        if (indexPath.section == 0) {
            chain = searchMainnets[indexPath.row]
        } else {
            chain = searchTestnets[indexPath.row]
        }
        
        if (chain.supportCosmos && chain.supportEvm) {
            let toEvmAddress = chain.evmAddress!
            let toBechAddress = chain.bechAddress!
            let copyEvm = UIAction(title: NSLocalizedString("str_copy_evm_address", comment: ""), image: nil) { _ in
                UIPasteboard.general.string = toEvmAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
            let shareEvm = UIAction(title: NSLocalizedString("str_share_evm_address", comment: ""), image: nil) { _ in
                let activityViewController = UIActivityViewController(activityItems: [toEvmAddress], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            let copyBech = UIAction(title: NSLocalizedString("str_copy_bech_address", comment: ""), image: nil) { _ in
                UIPasteboard.general.string = toBechAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
            let shareBech = UIAction(title: NSLocalizedString("str_share_bech_address", comment: ""), image: nil) { _ in
                let activityViewController = UIActivityViewController(activityItems: [toBechAddress], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            let qrAddressPopup2VC = QrAddressPopup2VC(nibName: "QrAddressPopup2VC", bundle: nil)
            qrAddressPopup2VC.selectedChain = chain
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopup2VC }) { _ in
                UIMenu(title: "", children: [copyEvm, shareEvm, copyBech, shareBech])
            }
            
        } else if (chain.supportCosmos) {
            let toBechAddress = chain.bechAddress!
            let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = toBechAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
            let share = UIAction(title: NSLocalizedString("str_share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = UIActivityViewController(activityItems: [toBechAddress], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            let qrAddressPopupVC = QrAddressPopupVC(nibName: "QrAddressPopupVC", bundle: nil)
            qrAddressPopupVC.selectedChain = chain
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopupVC }) { _ in
                UIMenu(title: "", children: [copy, share])
            }
            
        } else if (chain.supportEvm) {
            let toEvmAddress = chain.evmAddress!
            let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = toEvmAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
            let share = UIAction(title: NSLocalizedString("str_share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = UIActivityViewController(activityItems: [toEvmAddress], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            let qrAddressPopupVC = QrAddressPopupVC(nibName: "QrAddressPopupVC", bundle: nil)
            qrAddressPopupVC.selectedChain = chain
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopupVC }) { _ in
                UIMenu(title: "", children: [copy, share])
            }
            
        } else if (!chain.mainAddress.isEmpty) {
            let toMainAddress = chain.mainAddress
            let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = toMainAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
            let share = UIAction(title: NSLocalizedString("str_share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = UIActivityViewController(activityItems: [toMainAddress], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            let qrAddressPopupVC = QrAddressPopupVC(nibName: "QrAddressPopupVC", bundle: nil)
            qrAddressPopupVC.selectedChain = chain
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopupVC }) { _ in
                UIMenu(title: "", children: [copy, share])
            }
            
        }
        return nil
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchMainnets = searchText.isEmpty ? mainnetChains : mainnetChains.filter { chain in
            return chain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchTestnets = searchText.isEmpty ? testnetChains : testnetChains.filter { chain in
            return chain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchEmptyLayer.isHidden = searchMainnets.count + searchTestnets.count > 0
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        if let cell = tableView.cellForRow(at: indexPath) as? PortfolioCell {
            return UITargetedPreview(view: cell, parameters: parameters)
            
        } else if let cell = tableView.cellForRow(at: indexPath) as? Portfolio2Cell {
            return UITargetedPreview(view: cell, parameters: parameters)
        }
        return nil
    }
}

extension PortfolioVC: BaseSheetDelegate {
    
    func leftBarButton(_ name: String?, _ imge: UIImage? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        
        var title = AttributedString(name == nil ? "Account" : name!)
        title.font = .fontSize16Bold
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = title
        config.image = UIImage(named: "naviCon")
        config.imagePadding = 8
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        config.titleLineBreakMode = .byTruncatingMiddle
        
        button.configuration = config
        button.addTarget(self, action: #selector(onClickSwitchAccount(_:)), for: .touchUpInside)

        return UIBarButtonItem(customView: button)
    }
    
    private func rightBarButton() -> [UIBarButtonItem] {
        let chainSearchButton = UIButton()
        let chainSortingButton = UIButton()
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        chainSearchButton.configuration = config
        chainSearchButton.setImage(UIImage(named: "iconSearchChain"), for: .normal)
        chainSearchButton.addTarget(self, action: #selector(onClickChainSelect), for: .touchUpInside)
        
        chainSortingButton.configuration = config
        chainSortingButton.setImage(UIImage(named: SortingType(rawValue: lastSortingType.rawValue)!.rawValue), for: .normal)
        chainSortingButton.addTarget(self, action: #selector(onClickSortingButton), for: .touchUpInside)

        return [UIBarButtonItem(customView: chainSearchButton), UIBarButtonItem(customView: chainSortingButton)]
    }

    @objc func onClickSwitchAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SwitchAccount
        onStartSheet(baseSheet, 320, 0.6)
    }

    public func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SwitchAccount) {
            if let toAddcountId = result["accountId"] as? Int64 {
                if (BaseData.instance.baseAccount?.id != toAddcountId) {
                    showWait()
                    DispatchQueue.global().async {
                        let toAccount = BaseData.instance.selectAccount(toAddcountId)
                        BaseData.instance.setLastAccount(toAccount!.id)
                        BaseData.instance.baseAccount = toAccount
                        
                        DispatchQueue.main.async(execute: {
                            self.hideWait()
                            self.onStartMainTab()
                        });
                    }
                }
            }
        }
    }
}


extension PortfolioVC: NoticeSheetDelegate, EndpointDelegate {
    
    func onMainResult(_ noticeType: NoticeType?, _ result: Dictionary<String, Any>?) {
        if (noticeType == .NodeDownGuide) {
            if let chainTag = result?["chainTag"] as? String {
                baseAccount.getDpChains().filter { $0.tag == chainTag }.first?.fetchData(baseAccount.id)
                onUpdateRow(chainTag)
            }
        }
    }
    
    func onSubResult(_ noticeType: NoticeType?, _ result: Dictionary<String, Any>?) {
        if (noticeType == .NodeDownGuide) {
            if let chainTag = result?["chainTag"] as? String {
                let endpointSheet = SelectEndpointSheet(nibName: "SelectEndpointSheet", bundle: nil)
                endpointSheet.targetChain = baseAccount.getDpChains().filter { $0.tag == chainTag }.first
                endpointSheet.endpointDelegate = self
                onStartSheet(endpointSheet, 420, 0.8)
            }
        }
    }
    
    func onEndpointUpdated(_ result: Dictionary<String, Any>?) {
        if let chainTag = result?["chainTag"] as? String {
            baseAccount.getDpChains().filter { $0.tag == chainTag }.first?.getCosmosfetcher()?.grpcConnection = nil
            baseAccount.getDpChains().filter { $0.tag == chainTag }.first?.fetchData(baseAccount.id)
            onUpdateRow(chainTag)
        }
    }
}

extension PortfolioVC: ChainSortingTypeDelegate {
    @objc func onClickSortingButton() {
        switch lastSortingType {
        case .name:
            lastSortingType = .value
            
        case .value:
            lastSortingType = .name
        }
        
        UserDefaults.standard.setValue(lastSortingType.rawValue, forKey: KEY_CHAIN_SORT)
        chainSortReloadView()
    }
}

enum SortingType: String {
    case name = "iconSortName"
    case value = "iconSortValue"
}

protocol ChainSortingTypeDelegate {
    func onClickSortingButton()
}
