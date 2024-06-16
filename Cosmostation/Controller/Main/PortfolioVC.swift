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
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchPrice"), object: nil)
    }
    
    func initView() {
        baseAccount = BaseData.instance.baseAccount
        
        mainnetChains = baseAccount.getDisplayChains().filter({ $0.isTestnet == false })
        searchMainnets = mainnetChains
        
        testnetChains = baseAccount.getDisplayChains().filter({ $0.isTestnet == true })
        searchTestnets = testnetChains
        
        onUpdateSearchBar()
        currencyLabel.text = BaseData.instance.getCurrencySymbol()
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "iconSearchChain"), style: .plain, target: self, action: #selector(onClickChainSelect))
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @objc func onRequestFetch() {
        if (baseAccount.getDisplayChains().filter { $0.fetchState == .Busy }.count > 0) {
            refresher.endRefreshing()
        } else {
            BaseNetWork().fetchPrices()
            baseAccount.getDisplayChains().forEach { $0.fetchState = .Idle }
            baseAccount?.fetchDpChains()
            tableView.reloadData()
            refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        Task {
            onUpdateRow(tag)
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
        baseAccount.getDisplayChains().forEach { chain in
            sum = sum.adding(chain.allValue())
        }
        DispatchQueue.main.async {
            self.totalValue = sum
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
        self.present(chainSelectVC, animated: true)
    }
    
    func onChainSelected() {
        baseAccount.fetchDpChains()
        mainnetChains = baseAccount.getDisplayChains().filter({ $0.isTestnet == false })
        searchMainnets = mainnetChains
        
        testnetChains = baseAccount.getDisplayChains().filter({ $0.isTestnet == true })
        searchTestnets = testnetChains
        
        onUpdateSearchBar()
        tableView.reloadData()
        onUpdateTotal()
    }
    
    func onUpdateSearchBar() {
        if (mainnetChains.count + testnetChains.count < 10) {
            tableView.tableHeaderView = nil
            tableView.headerView(forSection: 0)?.layoutSubviews()
        } else {
            tableView.tableHeaderView = searchBar
            tableView.headerView(forSection: 0)?.layoutSubviews()
        }
    }
    
    func onNodedownPopup() {
        let warnSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
        warnSheet.noticeType = .NodeDownGuide
        onStartSheet(warnSheet, 320, 0.6)
    }

}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && mainnetChains.count == 0) { return nil }
        if (section == 1 && testnetChains.count == 0) { return nil }
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Mainnet"
            view.cntLabel.text = String(mainnetChains.count)
        } else if (section == 1) {
            view.titleLabel.text = "Testnet"
            view.cntLabel.text = String(testnetChains.count)
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
            onNodedownPopup()
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
        button.setImage(UIImage(named: "naviCon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        button.setTitle(name == nil ? "Account" : name, for: .normal)
        button.titleLabel?.font = .fontSize16Bold
        button.sizeToFit()
        button.addTarget(self, action: #selector(onClickSwitchAccount(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
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

