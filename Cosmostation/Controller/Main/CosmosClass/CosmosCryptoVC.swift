//
//  CosmosCoinVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lottie
import StoreKit

class CosmosCryptoVC: BaseVC {
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    var refresher: UIRefreshControl!
    private lazy var searchBarView = SearchBarWithTopPadding(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 54))
    
    var selectedChain: BaseChain!
    var nativeCoins = Array<Cosmos_Base_V1beta1_Coin>() {
        didSet {
            searchNativeCoins = nativeCoins
        }
    }                                                                  // section 0
    var searchNativeCoins = Array<Cosmos_Base_V1beta1_Coin>()
    
    var ibcCoins = Array<Cosmos_Base_V1beta1_Coin>() {
        didSet {
            searchIbcCoins = ibcCoins
        }
    }                                                                   // section 1
    var searchIbcCoins = Array<Cosmos_Base_V1beta1_Coin>()
    
    var bridgedCoins = Array<Cosmos_Base_V1beta1_Coin>() {
        didSet {
            searchBridgedCoins = bridgedCoins
        }
    }                                                                   // section 2
    var searchBridgedCoins = Array<Cosmos_Base_V1beta1_Coin>()
    
    var mintscanCw20Tokens = [MintscanToken]() {
        didSet {
            searchMintscanCw20Tokens = mintscanCw20Tokens
        }
    }                                                                   // section 3
    var searchMintscanCw20Tokens = [MintscanToken]()
    
    var mintscanErc20Tokens = [MintscanToken]() {
        didSet {
            searchMintscanErc20Tokens = mintscanErc20Tokens
        }
    }                                                                   // section 4
    var searchMintscanErc20Tokens = [MintscanToken]()

    
    var oktBalances = Array<JSON>() {
        didSet {
            searchOktBalances = oktBalances
        }
    }                                                                   // section 1 for legacy okt
    
    var searchOktBalances = Array<JSON>()
    
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
        tableView.register(UINib(nibName: "AssetCosmosClassCell", bundle: nil), forCellReuseIdentifier: "AssetCosmosClassCell")
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        searchBarView.searchBar.delegate = self
        
        onSortAssets()
        onUpdateView()
        
        if (selectedChain.tag == "okt996_Keccak" || selectedChain.tag == "okt996_Secp") {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                let legacySheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
                legacySheet.selectedChain = self.selectedChain
                legacySheet.noticeType = .LegacyPath
                self.onStartSheet(legacySheet, 240, 0.6)
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (nativeCoins.count + ibcCoins.count + bridgedCoins.count + mintscanCw20Tokens.count + mintscanErc20Tokens.count) > 14 {
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
        
#if RELEASE
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
#endif
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
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
                self.nativeCoins.removeAll()
                self.ibcCoins.removeAll()
                self.bridgedCoins.removeAll()
                self.oktBalances.removeAll()
                self.onSortAssets()
                self.onUpdateView()
            }
        }
    }
    
    @objc func onToggleValue(_ notification: NSNotification) {
        tableView.reloadData()
    }

    @objc func onRequestFetch() {
        if (selectedChain.fetchState == FetchState.Busy) {
            refresher.endRefreshing()
        } else {
            DispatchQueue.global().async {
                self.selectedChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    func onSortAssets() {
        Task {
            if let oktFetcher = (selectedChain as? ChainOktEVM)?.getOktfetcher() {
                oktFetcher.oktAccountInfo.oktCoins?.forEach { balance in
                    oktBalances.append(balance)
                }
                if (oktBalances.filter { $0["denom"].string == selectedChain.stakeDenom }.first == nil) {
                    oktBalances.append(JSON(["denom":"okt", "amount": "0"]))
                }
                oktBalances.sort {
                    if ($0["denom"].string == selectedChain.stakeDenom) { return true }
                    if ($1["denom"].string == selectedChain.stakeDenom) { return false }
                    return false
                }
                
            } else if let cosmosFetcher = selectedChain.getCosmosfetcher() {
                cosmosFetcher.cosmosBalances?.forEach { coin in
                    let coinType = BaseData.instance.getAsset(selectedChain.apiName, coin.denom)?.type
                    if (coinType == "staking" || coinType == "native") {
                        nativeCoins.append(coin)
                    } else if (coinType == "bep" || coinType == "bridge") {
                        bridgedCoins.append(coin)
                    } else if (coinType == "ibc") {
                        ibcCoins.append(coin)
                    }
                }
                if (nativeCoins.filter { $0.denom == selectedChain.stakeDenom }.first == nil) {
                    nativeCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = selectedChain.stakeDenom!; $0.amount = "0" })
                }
                nativeCoins.sort {
                    if ($0.denom == selectedChain.stakeDenom) { return true }
                    if ($1.denom == selectedChain.stakeDenom) { return false }
                    let value0 = cosmosFetcher.balanceValue($0.denom)
                    let value1 = cosmosFetcher.balanceValue($1.denom)
                    return value0.compare(value1).rawValue > 0 ? true : false
                }
                ibcCoins.sort {
                    let value0 = cosmosFetcher.balanceValue($0.denom)
                    let value1 = cosmosFetcher.balanceValue($1.denom)
                    return value0.compare(value1).rawValue > 0 ? true : false
                }
                bridgedCoins.sort {
                    let value0 = cosmosFetcher.balanceValue($0.denom)
                    let value1 = cosmosFetcher.balanceValue($1.denom)
                    return value0.compare(value1).rawValue > 0 ? true : false
                }
            }
            tableView.reloadData()
        }
    }
    
    func onUpdateView() {
        self.mintscanCw20Tokens.removeAll()
        self.mintscanErc20Tokens.removeAll()
        if let cosmosFetcher = selectedChain.getCosmosfetcher() {
            cosmosFetcher.mintscanCw20Tokens.forEach { tokenInfo in
                if (tokenInfo.getAmount() != NSDecimalNumber.zero) {
                    mintscanCw20Tokens.append(tokenInfo)
                }
            }
            mintscanCw20Tokens.sort {
                let value0 = cosmosFetcher.tokenValue($0.address!)
                let value1 = cosmosFetcher.tokenValue($1.address!)
                return value0.compare(value1).rawValue > 0 ? true : false
            }
        }
        
        if let evmFetcher = selectedChain.getEvmfetcher() {
            evmFetcher.mintscanErc20Tokens.forEach { tokenInfo in
                if (tokenInfo.getAmount() != NSDecimalNumber.zero) {
                    mintscanErc20Tokens.append(tokenInfo)
                }
            }
            mintscanErc20Tokens.sort {
                let value0 = evmFetcher.tokenValue($0.address!)
                let value1 = evmFetcher.tokenValue($1.address!)
                return value0.compare(value1).rawValue > 0 ? true : false
            }
        }
        
        if (mintscanCw20Tokens.count > 0 || mintscanErc20Tokens.count > 0) {
            tableView.reloadData()
        }
    }
    
    func onStartTransferVC(_ sendType: SendAssetType, _ denom: String) {
        let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
        transfer.sendType = sendType
        transfer.fromChain = selectedChain
        transfer.toSendDenom = denom
        transfer.toSendMsAsset = BaseData.instance.getAsset(selectedChain.apiName, denom)
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onStartLegacyTransferVC(_ denom: String) {
        let transfer = LegacyTransfer(nibName: "LegacyTransfer", bundle: nil)
        transfer.selectedChain = selectedChain
        transfer.toSendDenom = denom
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }

}


extension CosmosCryptoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedChain.name == "OKT") {
            return 2
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (selectedChain.name == "OKT") {
            if section == 0 {
                view.titleLabel.text = "Native Coins"
                view.cntLabel.text = String(searchOktBalances.count)
            } else if section == 1 {
                view.titleLabel.text = "Kip20 Tokens"
                view.cntLabel.text = String(searchMintscanErc20Tokens.count)
            }
        } else {
            if (section == 0 && nativeCoins.count > 0) {
                view.titleLabel.text = "Native Coins"
                view.cntLabel.text = String(searchNativeCoins.count)
                
            } else if (section == 1 && ibcCoins.count > 0) {
                view.titleLabel.text = "IBC Coins"
                view.cntLabel.text = String(searchIbcCoins.count)

            } else if (section == 2 && bridgedCoins.count > 0) {
                view.titleLabel.text = "Bridged Coins"
                view.cntLabel.text = String(searchBridgedCoins.count)
                
            } else if (section == 3 && mintscanCw20Tokens.count > 0) {
                view.titleLabel.text = "Cw20 Tokens"
                view.cntLabel.text = String(searchMintscanCw20Tokens.count)
                
            } else if (section == 4 && mintscanErc20Tokens.count > 0) {
                view.titleLabel.text = "Erc20 Tokens"
                view.cntLabel.text = String(searchMintscanErc20Tokens.count)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (selectedChain.name == "OKT") {
            if (section == 0) {
                return searchOktBalances.count > 0 ? 40 : 0
            } else if (section == 1 ) {
                return searchMintscanErc20Tokens.count > 0 ? 40 : 0
            }
        } else {
            if (section == 0) {
                return (searchNativeCoins.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (searchIbcCoins.count > 0) ? 40 : 0
            } else if (section == 2) {
                return (searchBridgedCoins.count > 0) ? 40 : 0
            } else if (section == 3 && searchMintscanCw20Tokens.count > 0) {
                return 40
            } else if (section == 4 && searchMintscanErc20Tokens.count > 0) {
                return 40
            }
        }
        return 0
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedChain.name == "OKT") {
            if section == 0 {
                loadingView.isHidden = oktBalances.count > 0
                return searchOktBalances.count
            } else if section == 1 {
                return searchMintscanErc20Tokens.count
            }
        } else {
            loadingView.isHidden = nativeCoins.count > 0 || ibcCoins.count > 0  || bridgedCoins.count > 0
            if (section == 0) {
                if (selectedChain is ChainBeraEVM_T) {
                    return searchNativeCoins.count + 1
                }
                return searchNativeCoins.count
            } else if (section == 1) {
                return searchIbcCoins.count
            } else if (section == 2) {
                return searchBridgedCoins.count
            } else if (section == 3) {
                return searchMintscanCw20Tokens.count
            } else if (section == 4) {
                return searchMintscanErc20Tokens.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && indexPath.row == 0) {
            let stakeDenom = selectedChain.stakeDenom!
            let symbol = selectedChain.name == "OKT" ? stakeDenom.lowercased() : BaseData.instance.getAsset(selectedChain.apiName, stakeDenom)!.symbol!.lowercased()
            
            if searchBarView.searchBar.text == "" || symbol.contains(searchBarView.searchBar.text!.lowercased()) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCosmosClassCell") as! AssetCosmosClassCell
                cell.bindCosmosStakeAsset(selectedChain)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                
                if let oktChain = selectedChain as? ChainOktEVM {
                    cell.bindOktAsset(oktChain, searchOktBalances[indexPath.row])
                } else if (selectedChain is ChainBeraEVM_T && indexPath.section == 0 && indexPath.row == 1) {
                    cell.bindEvmClassCoin(selectedChain as! ChainBeraEVM_T)
                    
                } else if (indexPath.section == 0) {
                    cell.bindCosmosClassAsset(selectedChain, getCoinBySection(indexPath)!)
                }
                return cell
            }
            
            } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
            
            if let oktChain = selectedChain as? ChainOktEVM {
                if indexPath.section == 0 {
                    cell.bindOktAsset(oktChain, searchOktBalances[indexPath.row])
                } else if indexPath.section == 1 {
                    cell.bindEvmClassToken(selectedChain, searchMintscanErc20Tokens[indexPath.row])
                }

            } else if (selectedChain is ChainBeraEVM_T && indexPath.section == 0 && indexPath.row == 1) {
                cell.bindEvmClassCoin(selectedChain as! ChainBeraEVM_T)
                
            } else if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
                cell.bindCosmosClassAsset(selectedChain, getCoinBySection(indexPath)!)
                
            } else if (indexPath.section == 3) {
                cell.bindCosmosClassToken(selectedChain, searchMintscanCw20Tokens[indexPath.row])
                
            } else if (indexPath.section == 4) {
                cell.bindEvmClassToken(selectedChain, searchMintscanErc20Tokens[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                if (indexPath.section == 0 && indexPath.row == 0) { //OKT EVM only support Ox style
                    onStartTransferVC(.Only_EVM_Coin, searchOktBalances[indexPath.row]["denom"].stringValue)
                } else if indexPath.section == 1 {
                    let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
                    transfer.sendType = .Only_EVM_ERC20
                    transfer.fromChain = selectedChain
                    transfer.toSendDenom = searchMintscanErc20Tokens[indexPath.row].address
                    transfer.toSendMsToken = searchMintscanErc20Tokens[indexPath.row]
                    transfer.modalTransitionStyle = .coverVertical
                    self.present(transfer, animated: true)
                    return
                } else {
                    onStartLegacyTransferVC(searchOktBalances[indexPath.row]["denom"].stringValue)
                }
            } else {
                onStartLegacyTransferVC(searchOktBalances[indexPath.row]["denom"].stringValue)
            }
            
        } else if (selectedChain is ChainBeraEVM_T) {
            return
            
        } else {
            if (indexPath.section == 0) {
                var sendType: SendAssetType!
                if (indexPath.row == 0) {
                    if (selectedChain.supportEvm) {                            //stake coin web3-tx and cosmos-tx
                        sendType = .CosmosEVM_Coin
                    } else  {                                                   //no evm chain only cosmos-tx
                        sendType = .Only_Cosmos_Coin
                    }
                } else {                                                        //native(not stake) coin only cosmos-tx
                    sendType = .Only_Cosmos_Coin
                }
                onStartTransferVC(sendType, searchNativeCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 1) {
                onStartTransferVC(.Only_Cosmos_Coin, searchIbcCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 2) {
                onStartTransferVC(.Only_Cosmos_Coin, searchBridgedCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 3) {
                let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
                transfer.sendType = .Only_Cosmos_CW20
                transfer.fromChain = selectedChain
                transfer.toSendDenom = searchMintscanCw20Tokens[indexPath.row].address
                transfer.toSendMsToken = searchMintscanCw20Tokens[indexPath.row]
                transfer.modalTransitionStyle = .coverVertical
                self.present(transfer, animated: true)
                return
                
            } else if (indexPath.section == 4) {
                let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
                transfer.sendType = .Only_EVM_ERC20
                transfer.fromChain = selectedChain
                transfer.toSendDenom = searchMintscanErc20Tokens[indexPath.row].address
                transfer.toSendMsToken = searchMintscanErc20Tokens[indexPath.row]
                transfer.modalTransitionStyle = .coverVertical
                self.present(transfer, animated: true)
                return
            }
        }
        
    }
    
    func getCoinBySection(_ indexPath: IndexPath) -> Cosmos_Base_V1beta1_Coin? {
        if (indexPath.section == 0) {
            return searchNativeCoins[indexPath.row]
        } else if (indexPath.section == 1) {
            return searchIbcCoins[indexPath.row]
        } else if (indexPath.section == 2) {
            return searchBridgedCoins[indexPath.row]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (indexPath.section == 0 && indexPath.row == 0 && selectedChain.supportStaking == true && selectedChain.getCosmosfetcher()?.cosmosRewards?.count ?? 0 > 0) {
            let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
            rewardListPopupVC.selectedChain = selectedChain
            rewardListPopupVC.rewards = selectedChain.getCosmosfetcher()!.cosmosRewards!
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return rewardListPopupVC }) { _ in
                UIMenu(title: "", children: [])
            }
        }
        return nil
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
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? AssetCosmosClassCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
    }
}

extension CosmosCryptoVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.lowercased()
        
        searchOktBalances.removeAll()
        searchNativeCoins.removeAll()
        searchIbcCoins.removeAll()
        searchBridgedCoins.removeAll()
        searchMintscanCw20Tokens.removeAll()
        searchMintscanErc20Tokens.removeAll()
        
        
        if searchText.isEmpty {
            searchOktBalances = oktBalances
            searchNativeCoins = nativeCoins
            searchIbcCoins = ibcCoins
            searchBridgedCoins = bridgedCoins
            searchMintscanCw20Tokens = mintscanCw20Tokens
            searchMintscanErc20Tokens = mintscanErc20Tokens
            
            tableView.reloadData()
            return
        }
        
        
        

        let oktChain = selectedChain as? ChainOktEVM
        let oktFetcher = oktChain?.oktFetcher
        oktBalances.forEach { coin in
            guard let token = oktFetcher?.oktTokens.filter({ $0["symbol"].string == coin["denom"].string }).first else { return }
            if token["original_symbol"].description.contains(text) {
                searchOktBalances.append(coin)
            }
        }
        
        nativeCoins.forEach { coin in
            if BaseData.instance.getAsset(selectedChain.apiName, coin.denom)!.symbol!.lowercased().contains(text) {
                searchNativeCoins.append(coin)
            }
        }
        
        ibcCoins.forEach { coin in
            if BaseData.instance.getAsset(selectedChain.apiName, coin.denom)!.symbol!.lowercased().contains(text) {
                searchIbcCoins.append(coin)
            }
        }

        bridgedCoins.forEach { coin in
            if BaseData.instance.getAsset(selectedChain.apiName, coin.denom)!.symbol!.lowercased().contains(text) {
                searchBridgedCoins.append(coin)
            }
        }
        
        searchMintscanCw20Tokens = mintscanCw20Tokens.filter {
            $0.symbol!.lowercased().contains(text)
        }
        
        searchMintscanErc20Tokens = mintscanErc20Tokens.filter {
            $0.symbol!.lowercased().contains(text)
        }
        
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}



extension JSON {
    var bnbCoins: [JSON]? {
        return self["balances"].array
    }
    
    func bnbCoin(_ position: Int) -> JSON? {
        return bnbCoins?[position]
    }
    
    var oktCoins: [JSON]? {
        return self["value","coins"].array
    }
    
    func oktCoin(_ position: Int) -> JSON? {
        return oktCoins?[position]
    }
    
}
