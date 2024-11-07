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

class CosmosCryptoVC: BaseVC, SelectTokensListDelegate {    
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchEmptyLayer: UIView!
    @IBOutlet weak var dropBtn: LottieAnimationView!
    
    var refresher: UIRefreshControl!
    var searchBar: UISearchBar?
    
    var selectedChain: BaseChain!
    var nativeCoins = [Cosmos_Base_V1beta1_Coin]()
    var searchNativeCoins = [Cosmos_Base_V1beta1_Coin]()                // section 0
    var ibcCoins = [Cosmos_Base_V1beta1_Coin]()
    var searchIbcCoins = [Cosmos_Base_V1beta1_Coin]()                   // section 1
    var bridgedCoins = [Cosmos_Base_V1beta1_Coin]()
    var searchBridgedCoins = [Cosmos_Base_V1beta1_Coin]()               // section 2
    var mintscanCw20Tokens = [MintscanToken]()
    var toDisplayCw20Tokens = [MintscanToken]() {
        didSet {
            searchMintscanCw20Tokens = toDisplayCw20Tokens
        }
    }
    var searchMintscanCw20Tokens = [MintscanToken]()                    // section 3
    var mintscanErc20Tokens = [MintscanToken]()
    var toDisplayErc20Tokens = [MintscanToken]() {
        didSet {
            searchMintscanErc20Tokens = toDisplayErc20Tokens
        }
    }
    var searchMintscanErc20Tokens = [MintscanToken]()                   // section 4
    var oktBalances = [JSON]()
    var searchOktBalances = [JSON]()                                    // section 0 for legacy okt KIP10
    
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
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 54))
        searchBar?.searchTextField.textColor = .color01
        searchBar?.tintColor = UIColor.white
        searchBar?.barTintColor = UIColor.clear
        searchBar?.searchTextField.font = .fontSize14Bold
        searchBar?.backgroundImage = UIImage()
        searchBar?.delegate = self
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        
        onSortAssets()
        onSetDrop()
        
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
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain != nil && selectedChain.tag == tag) {
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
                self.nativeCoins.removeAll()
                self.ibcCoins.removeAll()
                self.bridgedCoins.removeAll()
                self.mintscanCw20Tokens.removeAll()
                self.toDisplayCw20Tokens.removeAll()
                self.mintscanErc20Tokens.removeAll()
                self.toDisplayErc20Tokens.removeAll()
                self.oktBalances.removeAll()
                self.onSortAssets()
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
                searchOktBalances = oktBalances
                
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
            
            if let cosmosFetcher = selectedChain.getCosmosfetcher() {
                mintscanCw20Tokens = cosmosFetcher.mintscanCw20Tokens.sorted { $0.symbol!.lowercased() < $1.symbol!.lowercased() }
                
                if let userCustomTokens = BaseData.instance.getDisplayCw20s(baseAccount.id, selectedChain.tag) {
                    mintscanCw20Tokens.sort {
                        if (userCustomTokens.contains($0.contract!) && !userCustomTokens.contains($1.contract!)) { return true }
                        if (!userCustomTokens.contains($0.contract!) && userCustomTokens.contains($1.contract!)) { return false }
                        let value0 = cosmosFetcher.tokenValue($0.contract!)
                        let value1 = cosmosFetcher.tokenValue($1.contract!)
                        return value0.compare(value1).rawValue > 0 ? true : false
                    }
                    mintscanCw20Tokens.forEach { token in
                        if (userCustomTokens.contains(token.contract!)) {
                            toDisplayCw20Tokens.append(token)
                        }
                    }
                } else {
                    mintscanCw20Tokens.sort {
                        if ($0.getAmount() != NSDecimalNumber.zero) && ($1.getAmount() == NSDecimalNumber.zero) { return true }
                        if ($0.getAmount() == NSDecimalNumber.zero) && ($1.getAmount() != NSDecimalNumber.zero) { return false }
                        let value0 = cosmosFetcher.tokenValue($0.contract!)
                        let value1 = cosmosFetcher.tokenValue($1.contract!)
                        return value0.compare(value1).rawValue > 0 ? true : false
                    }
                    mintscanCw20Tokens.forEach { token in
                        if (token.getAmount() != NSDecimalNumber.zero) {
                            toDisplayCw20Tokens.append(token)
                        
                        }
                    }

                }
            }
            
            if let evmFetcher = selectedChain.getEvmfetcher() {
                mintscanErc20Tokens = evmFetcher.mintscanErc20Tokens.sorted { $0.symbol!.lowercased() < $1.symbol!.lowercased() }
                 
                if let userCustomTokens = BaseData.instance.getDisplayErc20s(baseAccount.id, selectedChain.tag) {
                    mintscanErc20Tokens.sort {
                        if (userCustomTokens.contains($0.contract!) && !userCustomTokens.contains($1.contract!)) { return true }
                        if (!userCustomTokens.contains($0.contract!) && userCustomTokens.contains($1.contract!)) { return false }
                        let value0 = evmFetcher.tokenValue($0.contract!)
                        let value1 = evmFetcher.tokenValue($1.contract!)
                        return value0.compare(value1).rawValue > 0 ? true : false
                    }
                    
                    mintscanErc20Tokens.forEach { token in
                        if (userCustomTokens.contains(token.contract!)) {
                            toDisplayErc20Tokens.append(token)
                        }
                    }
                } else {
                    mintscanErc20Tokens.sort {
                        if ($0.getAmount() != NSDecimalNumber.zero) && ($1.getAmount() == NSDecimalNumber.zero) { return true }
                        if ($0.getAmount() == NSDecimalNumber.zero) && ($1.getAmount() != NSDecimalNumber.zero) { return false }
                        let value0 = evmFetcher.tokenValue($0.contract!)
                        let value1 = evmFetcher.tokenValue($1.contract!)
                        return value0.compare(value1).rawValue > 0 ? true : false
                    }
                    mintscanErc20Tokens.forEach { token in
                        if (token.getAmount() != NSDecimalNumber.zero) {
                            toDisplayErc20Tokens.append(token)
                        }
                    }
                }
            }
            
            searchOktBalances = oktBalances
            searchNativeCoins = nativeCoins
            searchIbcCoins = ibcCoins
            searchBridgedCoins = bridgedCoins
            searchMintscanCw20Tokens = toDisplayCw20Tokens
            searchMintscanErc20Tokens = toDisplayErc20Tokens

            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onShowTokenListSheet()  {
        let tokenListSheet = SelectDisplayTokenListSheet(nibName: "SelectDisplayTokenListSheet", bundle: nil)
        tokenListSheet.selectedChain = selectedChain
        if selectedChain.isSupportCw20() {
            tokenListSheet.allTokens = mintscanCw20Tokens
            tokenListSheet.toDisplayTokens = toDisplayCw20Tokens.map { $0.contract! }
        } else {
            tokenListSheet.allTokens = mintscanErc20Tokens
            tokenListSheet.toDisplayTokens = toDisplayErc20Tokens.map { $0.contract! }
            
        }
        tokenListSheet.tokensListDelegate = self
        onStartSheet(tokenListSheet, 680, 0.8)
    }
    
    func onTokensSelected(_ result: [String]) {
        loadingView.isHidden = false
        onRequestFetch()
    }


    func onUpdateView() {
        if (nativeCoins.count + ibcCoins.count + bridgedCoins.count + mintscanCw20Tokens.count + mintscanErc20Tokens.count < 10) {
            tableView.tableHeaderView = nil
            tableView.headerView(forSection: 0)?.layoutSubviews()
            tableView.contentOffset = CGPoint(x: 0, y: 0)
        } else {
            searchBar?.text = ""
            tableView.tableHeaderView = searchBar
            tableView.headerView(forSection: 0)?.layoutSubviews()
            tableView.contentOffset = CGPoint(x: 0, y: 54)
        }
        
        loadingView.isHidden = true
        tableView.reloadData()
    }
    
    func onStartCoinTransferVC(_ sendType: SendAssetType, _ denom: String) {
        let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
        transfer.sendAssetType = sendType
        transfer.fromChain = selectedChain
        transfer.toSendDenom = denom
        transfer.toSendMsAsset = BaseData.instance.getAsset(selectedChain.apiName, denom)
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    func onStartTokenTransferVC(_ sendType: SendAssetType, _ token: MintscanToken) {
        let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
        transfer.sendAssetType = sendType
        transfer.fromChain = selectedChain
        transfer.toSendDenom = token.contract
        transfer.toSendMsToken = token
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
    
    
    //For drop event
    func onSetDrop() {
        if (!BaseData.instance.showEvenReview()) { return }
        if (selectedChain is ChainCosmos || selectedChain is ChainNeutron || selectedChain is ChainCelestia) {
            dropBtn.animation = LottieAnimation.named("drop")
            dropBtn.contentMode = .scaleAspectFit
            dropBtn.loopMode = .loop
            dropBtn.animationSpeed = 1.3
            dropBtn.play()
            dropBtn.isHidden = false
    
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDrop))
            tapGesture.cancelsTouchesInView = false
            dropBtn.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func tapDrop() {
        let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
        dappDetail.dappType = .INTERNAL_URL
        dappDetail.dappUrl = URL(string: "https://app.drop.money/dashboard?referral_code=dropmaga")
        dappDetail.modalPresentationStyle = .fullScreen
        self.present(dappDetail, animated: true)
    }
}


extension CosmosCryptoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (selectedChain is ChainOktEVM) {
            if section == 0 {
                view.titleLabel.text = "Native Coins"
                view.cntLabel.text = String(searchOktBalances.count)
            } else if section == 4 {
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
        if (selectedChain is ChainOktEVM) {
            if (section == 0) {
                return searchOktBalances.count > 0 ? 40 : 0
            } else if (section == 4 ) {
                return searchMintscanErc20Tokens.count > 0 ? 40 : 0
            }
        } else {
            if (section == 0) {
                return (searchNativeCoins.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (searchIbcCoins.count > 0) ? 40 : 0
            } else if (section == 2) {
                return (searchBridgedCoins.count > 0) ? 40 : 0
            } else if (section == 3) {
                return searchMintscanCw20Tokens.count > 0 ? 40 : 0
            } else if (section == 4) {
                return searchMintscanErc20Tokens.count > 0 ? 40 : 0
            }
        }
        return 0
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedChain is ChainOktEVM) {
            if section == 0 {
                return searchOktBalances.count
            } else if section == 4 {
                return searchMintscanErc20Tokens.count
            }
            
        } else {
            if (section == 0) {
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
        if let oktChain = selectedChain as? ChainOktEVM {
            if (indexPath.section == 0) {
                if (searchOktBalances[indexPath.row]["denom"].stringValue == oktChain.stakeDenom) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCosmosClassCell") as! AssetCosmosClassCell
                    cell.bindCosmosStakeAsset(oktChain)
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                    cell.bindOktAsset(oktChain, searchOktBalances[indexPath.row])
                    return cell
                }
                
            } else if (indexPath.section == 4) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                cell.bindEvmClassToken(oktChain, searchMintscanErc20Tokens[indexPath.row])
                return cell
            }
            
        } else {
            if (indexPath.section == 0) {
                if (searchNativeCoins[indexPath.row].denom == selectedChain.stakeDenom) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCosmosClassCell") as! AssetCosmosClassCell
                    cell.bindCosmosStakeAsset(selectedChain)
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                    cell.bindCosmosClassAsset(selectedChain, searchNativeCoins[indexPath.row])
                    return cell
                }
                
            } else if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                cell.bindCosmosClassAsset(selectedChain, searchIbcCoins[indexPath.row])
                return cell
                
            } else if (indexPath.section == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                cell.bindCosmosClassAsset(selectedChain, searchBridgedCoins[indexPath.row])
                return cell
                
            } else if (indexPath.section == 3) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                cell.bindCosmosClassToken(selectedChain, searchMintscanCw20Tokens[indexPath.row])
                return cell
                
            } else if (indexPath.section == 4) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
                cell.bindEvmClassToken(selectedChain, searchMintscanErc20Tokens[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!selectedChain.isSendEnabled()) {
            onShowToast(NSLocalizedString("error_tranfer_disabled", comment: ""))
            return
        }
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        if let oktChain = selectedChain as? ChainOktEVM {
            if (oktChain.supportEvm) {
                if (indexPath.section == 0 && searchOktBalances[indexPath.row]["denom"].stringValue == oktChain.stakeDenom) {
                    onStartCoinTransferVC(.EVM_COIN, searchOktBalances[indexPath.row]["denom"].stringValue)
                    
                } else if (indexPath.section == 0) {
                    onStartLegacyTransferVC(searchOktBalances[indexPath.row]["denom"].stringValue)
                    
                } else if (indexPath.section == 4) {
                    onStartTokenTransferVC(.EVM_ERC20, searchMintscanErc20Tokens[indexPath.row])
                }
                
            } else {
                onStartLegacyTransferVC(searchOktBalances[indexPath.row]["denom"].stringValue)
            }
            
        } else {
            if (indexPath.section == 0 && searchNativeCoins[indexPath.row].denom == selectedChain.stakeDenom && selectedChain.supportEvm) {
                onStartCoinTransferVC(.COSMOS_EVM_MAIN_COIN, searchNativeCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 0) {
                onStartCoinTransferVC(.COSMOS_COIN, searchNativeCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 1) {
                onStartCoinTransferVC(.COSMOS_COIN, searchIbcCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 2) {
                onStartCoinTransferVC(.COSMOS_COIN, searchBridgedCoins[indexPath.row].denom)
                
            } else if (indexPath.section == 3) {
                let token = searchMintscanCw20Tokens[indexPath.row]
                if (token.getAmount() == NSDecimalNumber.zero) {
                    onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
                    return
                }
                onStartTokenTransferVC(.COSMOS_WASM, searchMintscanCw20Tokens[indexPath.row])
                
            } else if (indexPath.section == 4) {
                let token = searchMintscanErc20Tokens[indexPath.row]
                if (token.getAmount() == NSDecimalNumber.zero) {
                    onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
                    return
                }
                onStartTokenTransferVC(.EVM_ERC20, searchMintscanErc20Tokens[indexPath.row])
            }
            
        }
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
        
        if let oktFetcher = (selectedChain as? ChainOktEVM)?.getOktfetcher() {
            searchOktBalances = searchText.isEmpty ? oktBalances : oktBalances.filter { coin in
                if let token = oktFetcher.oktTokens.filter({ $0["symbol"].string == coin["denom"].string }).first {
                    return token["original_symbol"].string?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                }
                return false
            }
        }
        
        searchNativeCoins = searchText.isEmpty ? nativeCoins : nativeCoins.filter { coin in
            return BaseData.instance.getAsset(selectedChain.apiName, coin.denom)?.symbol?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        searchIbcCoins = searchText.isEmpty ? ibcCoins : ibcCoins.filter { coin in
            return BaseData.instance.getAsset(selectedChain.apiName, coin.denom)?.symbol?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        searchBridgedCoins = searchText.isEmpty ? bridgedCoins : bridgedCoins.filter { coin in
            return BaseData.instance.getAsset(selectedChain.apiName, coin.denom)?.symbol?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        searchMintscanCw20Tokens = searchText.isEmpty ? mintscanCw20Tokens : mintscanCw20Tokens.filter { token in
            return token.symbol?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        searchMintscanErc20Tokens = searchText.isEmpty ? mintscanErc20Tokens : mintscanErc20Tokens.filter { token in
            return token.symbol?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        searchEmptyLayer.isHidden = searchNativeCoins.count + searchIbcCoins.count + searchBridgedCoins.count + searchMintscanCw20Tokens.count + searchMintscanErc20Tokens.count + searchOktBalances.count > 0
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}


