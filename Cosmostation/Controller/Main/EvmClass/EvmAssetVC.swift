//
//  EvmAssetVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/01/25.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lottie

class EvmAssetVC: BaseVC, SelectTokensListDelegate {
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!
    var allErc20Tokens = [MintscanToken]()
    var toDisplayErc20Tokens = [MintscanToken]() {
        didSet {
            searchErc20Tokens = toDisplayErc20Tokens
        }
    }
    var searchErc20Tokens = [MintscanToken]()
    
    var containCoinSymbol = true
    
    private lazy var searchBarView = SearchBarWithTopPadding(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 54))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        searchBarView.searchBar.delegate = self

        onSortAssets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if toDisplayErc20Tokens.count > 14 {
            tableView.tableHeaderView = searchBarView

            var contentOffset: CGPoint = tableView.contentOffset
            if (contentOffset == CGPoint(x: 0, y: 0) &&
                tableView.tableHeaderView != nil &&
                searchBarView.searchBar.text?.isEmpty == true) {
                contentOffset.y += (tableView.tableHeaderView?.frame)!.height
                tableView.contentOffset = contentOffset
            }
            
            tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onToggleValue(_:)), name: Notification.Name("ToggleHideValue"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ToggleHideValue"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain != nil && selectedChain.tag == tag) {
            self.refresher.endRefreshing()
            self.onSortAssets()
        }
    }
    
    @objc func onToggleValue(_ notification: NSNotification) {
        tableView.reloadData()
    }
    
    @objc func onRequestFetch() {
        if (selectedChain.fetchState == .Busy) {
            refresher.endRefreshing()
        } else {
            DispatchQueue.global().async {
                self.selectedChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    func onSortAssets() {
        allErc20Tokens.removeAll()
        toDisplayErc20Tokens.removeAll()
        Task {
            if let evmFetcher = selectedChain.getEvmfetcher() {
                allErc20Tokens = evmFetcher.mintscanErc20Tokens
                allErc20Tokens = allErc20Tokens.sorted { $0.symbol!.lowercased() < $1.symbol!.lowercased() }
                
                if let userCustomTokens = BaseData.instance.getDisplayErc20s(baseAccount.id, selectedChain.tag) {
                    allErc20Tokens.sort {
                        if (userCustomTokens.contains($0.address!) && !userCustomTokens.contains($1.address!)) { return true }
                        if (!userCustomTokens.contains($0.address!) && userCustomTokens.contains($1.address!)) { return false }
                        let value0 = evmFetcher.tokenValue($0.address!)
                        let value1 = evmFetcher.tokenValue($1.address!)
                        return value0.compare(value1).rawValue > 0 ? true : false
                    }
                    allErc20Tokens.forEach { tokens in
                        if (userCustomTokens.contains(tokens.address!)) {
                            toDisplayErc20Tokens.append(tokens)
                        }
                    }
                    
                } else {
                    allErc20Tokens.sort {
                        let value0 = evmFetcher.tokenValue($0.address!)
                        let value1 = evmFetcher.tokenValue($1.address!)
                        return value0.compare(value1).rawValue > 0 ? true : false
                    }
                    allErc20Tokens.forEach { tokens in
                        if (tokens.getAmount() != NSDecimalNumber.zero) {
                            toDisplayErc20Tokens.append(tokens)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    func onShowTokenListSheet()  {
        let tokenListSheet = SelectDisplayTokenListSheet(nibName: "SelectDisplayTokenListSheet", bundle: nil)
        tokenListSheet.selectedChain = selectedChain
        tokenListSheet.allErc20Tokens = allErc20Tokens
        tokenListSheet.toDisplayErc20Tokens = toDisplayErc20Tokens.map { $0.address! }
        tokenListSheet.tokensListDelegate = self
        onStartSheet(tokenListSheet, 680, 0.8)
    }
    
    func onTokensSelected(_ result: [String]) {
        onRequestFetch()
    }
}


extension EvmAssetVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Coin"
            view.cntLabel.text = containCoinSymbol ? "1" : "0"
            
        } else {
            view.titleLabel.text = "Erc20 Tokens"
            view.cntLabel.text = String(searchErc20Tokens.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return containCoinSymbol ? 40 : 0
        } else if (section == 1 && searchErc20Tokens.count > 0) {
            return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return containCoinSymbol ?  1 :  0
        } else if (section == 1) {
            return searchErc20Tokens.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
        if (indexPath.section == 0) {
            cell.bindEvmClassCoin(selectedChain)
        } else {
            cell.bindEvmClassToken(selectedChain, searchErc20Tokens[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (indexPath.section == 0) {
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = .EVM_COIN
            transfer.fromChain = selectedChain
            transfer.toSendDenom = selectedChain.stakeDenom
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            return
            
        } else {
            let token = searchErc20Tokens[indexPath.row]
            if (token.getAmount() == NSDecimalNumber.zero) {
                onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
                return
            }
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = .EVM_ERC20
            transfer.fromChain = selectedChain
            transfer.toSendDenom = token.address
            transfer.toSendMsToken = token
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
        
        view.endEditing(true)
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
    
}

extension EvmAssetVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchErc20Tokens.removeAll()
        
        if searchText.isEmpty {
            searchErc20Tokens = toDisplayErc20Tokens
            containCoinSymbol = true
            
            tableView.reloadData()
            return
        }
        
        searchErc20Tokens = toDisplayErc20Tokens.filter { token in
            guard let symbol = token.symbol else { return false }
            return symbol.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        let symbol = selectedChain.coinSymbol
        if symbol.range(of: searchText, options: .caseInsensitive) != nil {
            containCoinSymbol = true
        } else {
            containCoinSymbol = false
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
