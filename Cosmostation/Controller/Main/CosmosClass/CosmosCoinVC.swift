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

class CosmosCoinVC: BaseVC {
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!
    var nativeCoins = Array<Cosmos_Base_V1beta1_Coin>()                 // section 1
    var ibcCoins = Array<Cosmos_Base_V1beta1_Coin>()                    // section 2
    var bridgedCoins = Array<Cosmos_Base_V1beta1_Coin>()                // section 3
    
    var lcdBalances = Array<JSON>()                                     // section 1 for legacy lcd
    
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
        
        onSortAssets()
        
        if (selectedChain is ChainCantoEVM || selectedChain is ChainRegen) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                let sunsetSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
                sunsetSheet.selectedChain = self.selectedChain
                sunsetSheet.noticeType = .ChainDelist
                self.onStartSheet(sunsetSheet, 240, 0.6)
            })
            
        } else if (selectedChain.tag == "okt996_Keccak" || selectedChain.tag == "okt996_Secp") {
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
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain != nil && selectedChain.tag == tag) {
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
                self.nativeCoins.removeAll()
                self.ibcCoins.removeAll()
                self.bridgedCoins.removeAll()
                self.lcdBalances.removeAll()
                self.onSortAssets()
            }
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
        Task {
            if (selectedChain.name == "OKT") {
                if let lcdFetcher = selectedChain.getLcdfetcher() {
                    lcdFetcher.lcdAccountInfo.oktCoins?.forEach { balance in
                        lcdBalances.append(balance)
                    }
                    if (lcdBalances.filter { $0["denom"].string == selectedChain.stakeDenom }.first == nil) {
                        lcdBalances.append(JSON(["denom":"okt", "amount": "0"]))
                    }
                    lcdBalances.sort {
                        if ($0["denom"].string == selectedChain.stakeDenom) { return true }
                        if ($1["denom"].string == selectedChain.stakeDenom) { return false }
                        return false
                    }
                }
                
            } else if let grpcFetcher = selectedChain.getGrpcfetcher() {
                grpcFetcher.cosmosBalances?.forEach { coin in
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
                    let value0 = grpcFetcher.balanceValue($0.denom)
                    let value1 = grpcFetcher.balanceValue($1.denom)
                    return value0.compare(value1).rawValue > 0 ? true : false
                }
                ibcCoins.sort {
                    let value0 = grpcFetcher.balanceValue($0.denom)
                    let value1 = grpcFetcher.balanceValue($1.denom)
                    return value0.compare(value1).rawValue > 0 ? true : false
                }
                bridgedCoins.sort {
                    let value0 = grpcFetcher.balanceValue($0.denom)
                    let value1 = grpcFetcher.balanceValue($1.denom)
                    return value0.compare(value1).rawValue > 0 ? true : false
                }
            }
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


extension CosmosCoinVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedChain.name == "OKT") {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (selectedChain.name == "OKT") {
            view.titleLabel.text = "Native Coins"
            view.cntLabel.text = String(lcdBalances.count)
            
        } else {
            if (section == 0 && nativeCoins.count > 0) {
                view.titleLabel.text = "Native Coins"
                view.cntLabel.text = String(nativeCoins.count)
                
            } else if (section == 1 && ibcCoins.count > 0) {
                view.titleLabel.text = "IBC Coins"
                view.cntLabel.text = String(ibcCoins.count)

            } else if (section == 2 && bridgedCoins.count > 0) {
                view.titleLabel.text = "Bridged Coins"
                view.cntLabel.text = String(bridgedCoins.count)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (selectedChain.name == "OKT") {
            return 40
            
        } else {
            if (section == 0) {
                return (nativeCoins.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (ibcCoins.count > 0) ? 40 : 0
            } else if (section == 2) {
                return (bridgedCoins.count > 0) ? 40 : 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedChain.name == "OKT") {
            loadingView.isHidden = lcdBalances.count > 0
            return lcdBalances.count
            
        } else {
            loadingView.isHidden = nativeCoins.count > 0 || ibcCoins.count > 0  || bridgedCoins.count > 0
            if (section == 0) {
                if (selectedChain is ChainBeraEVM_T) {
                    return nativeCoins.count + 1
                }
                return nativeCoins.count
            } else if (section == 1) {
                return ibcCoins.count
            } else if (section == 2) {
                return bridgedCoins.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCosmosClassCell") as! AssetCosmosClassCell
            cell.bindCosmosStakeAsset(selectedChain)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
            if (selectedChain.name == "OKT") {
                cell.bindOktAsset(selectedChain, lcdBalances[indexPath.row])
            } else if (selectedChain is ChainBeraEVM_T && indexPath.section == 0 && indexPath.row == 1) {
                cell.bindEvmClassCoin(selectedChain as! ChainBeraEVM_T)
            } else {
                cell.bindCosmosClassAsset(selectedChain, getCoinBySection(indexPath)!)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (selectedChain.isBankLocked()) {
//            onShowToast(NSLocalizedString("error_tranfer_disabled", comment: ""))
//            return
//        }
//        if (selectedChain.isTxFeePayable() == false) {
//            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
//            return
//        }
//        if (selectedChain is ChainOkt996Keccak) {
//            onStartLegacyTransferVC(lcdBalances[indexPath.row]["denom"].stringValue)
//            return
//            
//        } else if (selectedChain is ChainOktEVM) {
//            if (indexPath.section == 0) {
//                if (indexPath.row == 0) {                                       //OKT EVM only support Ox style
//                    onStartTransferVC(.Only_EVM_Coin, lcdBalances[indexPath.row]["denom"].stringValue)
//                } else {
//                    onStartLegacyTransferVC(lcdBalances[indexPath.row]["denom"].stringValue)
//                }
//            }
//            return
//            
//        } else if (selectedChain is ChainBeraEVM) {
//            if (indexPath.section == 0 && indexPath.row == 0) {                 //BGT is not sendable
//                onShowToast(NSLocalizedString("error_tranfer_disabled_bgt", comment: ""))
//                return
//                
//            } else if (indexPath.section == 0 && indexPath.row == 1) {          //Only Support BERA Send
//                onStartTransferVC(.Only_EVM_Coin, "abera")
//                return
//            }
//            return
//            
//        } else {
//            if (indexPath.section == 0) {
//                var sendType: SendAssetType!
//                if (indexPath.row == 0) {
//                    if (selectedChain is EvmClass) {                            //stake coin web3-tx and cosmos-tx
//                        sendType = .CosmosEVM_Coin
//                    } else  {                                                   //no evm chain only cosmos-tx
//                        sendType = .Only_Cosmos_Coin
//                    }
//                } else {                                                        //native(not stake) coin only cosmos-tx
//                    sendType = .Only_Cosmos_Coin
//                }
//                onStartTransferVC(sendType, nativeCoins[indexPath.row].denom)
//                return
//                
//            } else if (indexPath.section == 1) {
//                onStartTransferVC(.Only_Cosmos_Coin, ibcCoins[indexPath.row].denom)
//                return
//                
//            } else if (indexPath.section == 2) {
//                if (selectedChain.tag.starts(with: "kava") == true) {
//                    let sendDenom = bridgedCoins[indexPath.row].denom
//                    onStartTransferVC(.Only_Cosmos_Coin, sendDenom)
//                    return
//                    
//                } else {
//                    onStartTransferVC(.Only_Cosmos_Coin, bridgedCoins[indexPath.row].denom)
//                    return
//                }
//            }
//        }
    }
    
    func getCoinBySection(_ indexPath: IndexPath) -> Cosmos_Base_V1beta1_Coin? {
        if (indexPath.section == 0) {
            return nativeCoins[indexPath.row]
        } else if (indexPath.section == 1) {
            return ibcCoins[indexPath.row]
        } else if (indexPath.section == 2) {
            return bridgedCoins[indexPath.row]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (indexPath.section == 0 && indexPath.row == 0 && selectedChain.supportStaking == true && selectedChain.getGrpcfetcher()?.cosmosRewards?.count ?? 0 > 0) {
            let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
            rewardListPopupVC.selectedChain = selectedChain
            rewardListPopupVC.rewards = selectedChain.getGrpcfetcher()!.cosmosRewards!
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
