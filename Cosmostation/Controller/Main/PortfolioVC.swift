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
    
    var refresher: UIRefreshControl!
    var searchBar: UISearchBar?
    
    var toDisplayCosmosChains = [CosmosClass]()
    var searchCosmosChains = [CosmosClass]()
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
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
        onUpdateRow(detailChainTag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchPrice"), object: nil)
    }
    
    func initView() {
        baseAccount = BaseData.instance.baseAccount
        toDisplayCosmosChains = baseAccount.getDisplayCosmosChains()
        onUpdateSearchBar()
        searchCosmosChains = toDisplayCosmosChains
        
        currencyLabel.text = BaseData.instance.getCurrencySymbol()
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.name)
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "iconSearchChain"), style: .plain, target: self, action: #selector(onClickChainSelect))
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @objc func onRequestFetch() {
        if (toDisplayCosmosChains.filter { $0.fetched == false }.count > 0) {
            refresher.endRefreshing()
        } else {
            BaseNetWork().fetchPrices()
            toDisplayCosmosChains.forEach { chain in
                chain.fetched = false
            }
            baseAccount.fetchDisplayCosmosChains()
            tableView.reloadData()
            refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        print("onFetchDone ", tag)
        onUpdateRow(tag)
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        tableView.reloadData()
        onUpdateTotal()
    }
    
    func onUpdateRow(_ tag: String) {
        for i in 0..<searchCosmosChains.count {
            if (searchCosmosChains[i].tag == tag) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        onUpdateTotal()
    }
    
    func onUpdateTotal() {
        var sum = NSDecimalNumber.zero
        toDisplayCosmosChains.forEach { chain in
            sum = sum.adding(chain.allValue())
        }
        DispatchQueue.main.async {
            self.totalValue = sum
        }
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
        baseAccount.loadDisplayCTags()
        baseAccount.fetchDisplayCosmosChains()
        toDisplayCosmosChains = baseAccount.getDisplayCosmosChains()
        onUpdateSearchBar()
        searchCosmosChains = toDisplayCosmosChains
        tableView.reloadData()
        onUpdateTotal()
    }
    
    func onUpdateSearchBar() {
        if (toDisplayCosmosChains.count < 10) {
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = "Cosmos Class"
        view.cntLabel.text = String(toDisplayCosmosChains.count)
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
        return searchCosmosChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell") as! PortfolioCell
        cell.bindCosmosClassChain(baseAccount, searchCosmosChains[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (searchCosmosChains[indexPath.row].fetched == false) { return }
        detailChainTag = searchCosmosChains[indexPath.row].tag
        let cosmosClassVC = UIStoryboard(name: "CosmosClass", bundle: nil).instantiateViewController(withIdentifier: "CosmosClassVC") as! CosmosClassVC
        cosmosClassVC.selectedChain = searchCosmosChains[indexPath.row]
        cosmosClassVC.hidesBottomBarWhenPushed = true
        self.navigationItem.backBarButtonItem = backBarButton(baseAccount?.name)
        self.navigationController?.pushViewController(cosmosClassVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedChain = searchCosmosChains[indexPath.row]
        let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
            UIPasteboard.general.string = selectedChain.address!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.onShowToast(NSLocalizedString("address_copied", comment: ""))
        }
        let share = UIAction(title: NSLocalizedString("str_share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { _ in
            let activityViewController = UIActivityViewController(activityItems: [selectedChain.address!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        let qrAddressPopupVC = QrAddressPopupVC(nibName: "QrAddressPopupVC", bundle: nil)
        qrAddressPopupVC.selectedChain = selectedChain
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return qrAddressPopupVC }) { _ in
            UIMenu(title: "", children: [copy, share])
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCosmosChains = searchText.isEmpty ? toDisplayCosmosChains : toDisplayCosmosChains.filter { cosmosChain in
            return cosmosChain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchEmptyLayer.isHidden = searchCosmosChains.count > 0
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

