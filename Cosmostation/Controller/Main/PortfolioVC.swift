//
//  PortfolioVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PortfolioVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchEmptyLayer: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var hideValueBtn: UIButton!
    
    var refresher: UIRefreshControl!
    var searchBar: UISearchBar?
    
    var toDisplayEvmChains = [EvmClass]()
    var searchEvmChains = [EvmClass]()
    var toDisplayCosmosChains = [CosmosClass]()
    var searchCosmosChains = [CosmosClass]()
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
    var detailChainTag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
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
        toDisplayCosmosChains = baseAccount.getDisplayCosmosChains()
        searchCosmosChains = toDisplayCosmosChains
        
        toDisplayEvmChains = baseAccount.getDisplayEvmChains()
        searchEvmChains = toDisplayEvmChains
        
        
        onUpdateSearchBar()
        currencyLabel.text = BaseData.instance.getCurrencySymbol()
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "iconSearchChain"), style: .plain, target: self, action: #selector(onClickChainSelect))
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @objc func onRequestFetch() {
        if (toDisplayEvmChains.filter { $0.fetched == false }.count > 0 ||
            toDisplayCosmosChains.filter { $0.fetched == false }.count > 0) {
            refresher.endRefreshing()
            
        } else {
            BaseNetWork().fetchPrices()
            toDisplayEvmChains.forEach { $0.fetched = false }
            toDisplayCosmosChains.forEach { $0.fetched = false }
            baseAccount.fetchDisplayCosmosChains()
            baseAccount.fetchDisplayEvmChains()
            tableView.reloadData()
            refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        onUpdateRow(tag)
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
        for i in 0..<searchEvmChains.count {
            if (searchEvmChains[i].tag == tag) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                })
            }
        }
        for i in 0..<searchCosmosChains.count {
            if (searchCosmosChains[i].tag == tag) {
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
        toDisplayEvmChains.forEach { chain in
            sum = sum.adding(chain.allValue())
        }
        
        toDisplayCosmosChains.forEach { chain in
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
        baseAccount.fetchDisplayCosmosChains()
        toDisplayCosmosChains = baseAccount.getDisplayCosmosChains()
        searchCosmosChains = toDisplayCosmosChains
        
        baseAccount.fetchDisplayEvmChains()
        toDisplayEvmChains = baseAccount.getDisplayEvmChains()
        searchEvmChains = toDisplayEvmChains
        
        onUpdateSearchBar()
        tableView.reloadData()
        onUpdateTotal()
    }
    
    func onUpdateSearchBar() {
        if (toDisplayEvmChains.count + toDisplayCosmosChains.count < 10) {
            tableView.tableHeaderView = nil
            tableView.headerView(forSection: 0)?.layoutSubviews()
        } else {
            tableView.tableHeaderView = searchBar
            tableView.headerView(forSection: 0)?.layoutSubviews()
        }
    }

}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "EVM Class"
            view.cntLabel.text = String(toDisplayEvmChains.count)
        } else if (section == 1) {
            view.titleLabel.text = "Cosmos Class"
            view.cntLabel.text = String(toDisplayCosmosChains.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return searchEvmChains.count
        } else if (section == 1) {
            return searchCosmosChains.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell") as! PortfolioCell
        if (indexPath.section == 0) {
            cell.bindEvmClassChain(baseAccount, searchEvmChains[indexPath.row])
        } else if (indexPath.section == 1) {
            cell.bindCosmosClassChain(baseAccount, searchCosmosChains[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if (searchEvmChains[indexPath.row].fetched == false) { return }
            detailChainTag = searchEvmChains[indexPath.row].tag
            if (searchEvmChains[indexPath.row].supportCosmos) {
                let cosmosClassVC = UIStoryboard(name: "CosmosClass", bundle: nil).instantiateViewController(withIdentifier: "CosmosClassVC") as! CosmosClassVC
                cosmosClassVC.selectedChain = searchEvmChains[indexPath.row]
                cosmosClassVC.hidesBottomBarWhenPushed = true
                self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.getRefreshName())
                self.navigationController?.pushViewController(cosmosClassVC, animated: true)
                
            } else {
                let evmClassVC = UIStoryboard(name: "EvmClass", bundle: nil).instantiateViewController(withIdentifier: "EvmClassVC") as! EvmClassVC
                evmClassVC.selectedChain = searchEvmChains[indexPath.row]
                evmClassVC.hidesBottomBarWhenPushed = true
                self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.getRefreshName())
                self.navigationController?.pushViewController(evmClassVC, animated: true)
            }
            
        } else if (indexPath.section == 1) {
            if (searchCosmosChains[indexPath.row].fetched == false) { return }
            detailChainTag = searchCosmosChains[indexPath.row].tag
            let cosmosClassVC = UIStoryboard(name: "CosmosClass", bundle: nil).instantiateViewController(withIdentifier: "CosmosClassVC") as! CosmosClassVC
            cosmosClassVC.selectedChain = searchCosmosChains[indexPath.row]
            cosmosClassVC.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.getRefreshName())
            self.navigationController?.pushViewController(cosmosClassVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (indexPath.section == 0) {
            let selectedChain = searchEvmChains[indexPath.row]
            if (selectedChain.supportCosmos) {
                let toEvmAddress = selectedChain.evmAddress
                let toBechAddress = selectedChain.bechAddress
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
                qrAddressPopup2VC.selectedChain = selectedChain
                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopup2VC }) { _ in
                    UIMenu(title: "", children: [copyEvm, shareEvm, copyBech, shareBech])
                }
                
            } else {
                let toDpAddress = selectedChain.evmAddress
                let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
                    UIPasteboard.general.string = toDpAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.onShowToast(NSLocalizedString("address_copied", comment: ""))
                }
                let share = UIAction(title: NSLocalizedString("str_share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    let activityViewController = UIActivityViewController(activityItems: [toDpAddress], applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                }
                let qrAddressPopupVC = QrAddressPopupVC(nibName: "QrAddressPopupVC", bundle: nil)
                qrAddressPopupVC.selectedChain = selectedChain
                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopupVC }) { _ in
                    UIMenu(title: "", children: [copy, share])
                }
            }

            
        } else {
            let selectedChain = searchCosmosChains[indexPath.row]
            let toDpAddress = selectedChain.bechAddress
            let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = toDpAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
            let share = UIAction(title: NSLocalizedString("str_share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = UIActivityViewController(activityItems: [toDpAddress], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            let qrAddressPopupVC = QrAddressPopupVC(nibName: "QrAddressPopupVC", bundle: nil)
            qrAddressPopupVC.selectedChain = selectedChain
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopupVC }) { _ in
                UIMenu(title: "", children: [copy, share])
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchEvmChains = searchText.isEmpty ? toDisplayEvmChains : toDisplayEvmChains.filter { evmChain in
            return evmChain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchCosmosChains = searchText.isEmpty ? toDisplayCosmosChains : toDisplayCosmosChains.filter { cosmosChain in
            return cosmosChain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchEmptyLayer.isHidden = searchEvmChains.count + searchCosmosChains.count > 0
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
        guard let cell = tableView.cellForRow(at: indexPath) as? PortfolioCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
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
        onStartSheet(baseSheet)
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

