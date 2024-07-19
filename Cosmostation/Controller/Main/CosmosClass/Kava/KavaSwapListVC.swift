//
//  KavaSwapListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class KavaSwapListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKavaEVM!
    var kavaFetcher: KavaFetcher!
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var swapParam: Kava_Swap_V1beta1_Params?
    var swapList = [Kava_Swap_V1beta1_PoolResponse]()
    var swapMyList = [Kava_Swap_V1beta1_PoolResponse]()
    var swapOtherList = [Kava_Swap_V1beta1_PoolResponse]()
    var swapMyDeposit: [Kava_Swap_V1beta1_DepositResponse]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        kavaFetcher = selectedChain.getKavaFetcher()
        
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "KavaSwapListMyCell", bundle: nil), forCellReuseIdentifier: "KavaSwapListMyCell")
        tableView.register(UINib(nibName: "KavaSwapListCell", bundle: nil), forCellReuseIdentifier: "KavaSwapListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_swappool_list", comment: "")
    }
    
    func onFetchData() {
        Task {
            if var swapPools = try? await kavaFetcher.fetchSwapList(),
               var myDeposit = try? await kavaFetcher.fetchSwapMyDeposit() {
                myDeposit?.sort {
                    return $0.getUsdxAmount().compare($1.getUsdxAmount()).rawValue > 0 ? true : false
                }
                swapPools?.sort {
                    return $0.getUsdxAmount().compare($1.getUsdxAmount()).rawValue > 0 ? true : false
                }
                swapPools?.forEach({ pool in
                    //remove terra assets
                    if (!pool.name.contains("B448C0CA358B958301D328CCDC5D5AD642FC30A6D3AE106FF721DB315F3DDE5C") &&
                        !pool.name.contains("B8AF5D92165F35AB31F3FC7C7B444B9D240760FA5D406C49D24862BD0284E395")) {
                        if (myDeposit?.filter({ $0.poolID == pool.name }).count ?? 0 > 0) {
                            swapMyList.append(pool)
                        } else {
                            swapOtherList.append(pool)
                        }
                    }
                })
                swapList = swapPools ?? []
                swapMyDeposit = myDeposit
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.loadingView.isHidden = true
                    self.tableView.reloadData()
                }
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onDepositSwpTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let swpAction = KavaSwapAction(nibName: "KavaSwapAction", bundle: nil)
        swpAction.selectedChain = selectedChain
        swpAction.swapPool = swapList.filter({ $0.name == denom }).first!
        swpAction.swpActionType = .Deposit
        swpAction.modalTransitionStyle = .coverVertical
        self.present(swpAction, animated: true)
    }
    
    func onWithdrawSwpTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let swpAction = KavaSwapAction(nibName: "KavaSwapAction", bundle: nil)
        swpAction.selectedChain = selectedChain
        swpAction.swapPool = swapList.filter({ $0.name == denom }).first!
        swpAction.myDeposit = swapMyDeposit?.filter({ $0.poolID == denom }).first!
        swpAction.swpActionType = .Withdraw
        swpAction.modalTransitionStyle = .coverVertical
        self.present(swpAction, animated: true)
    }

}

extension KavaSwapListVC: UITableViewDelegate, UITableViewDataSource, BaseSheetDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return swapMyDeposit?.count ?? 0
        } else {
            return swapOtherList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaSwapListMyCell") as? KavaSwapListMyCell
            let deposit = swapMyDeposit?[indexPath.row]
            let pool = swapMyList.filter { $0.name == deposit?.poolID }.first
            cell?.onBindSwpPool(selectedChain, priceFeed, deposit, pool)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaSwapListCell") as? KavaSwapListCell
            let pool = swapOtherList[indexPath.row]
            cell?.onBindSwpPool(selectedChain, priceFeed, pool)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.swpName = swapMyDeposit?[indexPath.row].poolID
            baseSheet.sheetType = .SelectSwpAction
            onStartSheet(baseSheet, 240, 0.6)
            
        } else {
            onDepositSwpTx(swapOtherList[indexPath.row].name)
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectSwpAction) {
            if let swpName = result["swpName"] as? String,
               let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDepositSwpTx(swpName)
                    } else if (index == 1) {
                        self.onWithdrawSwpTx(swpName)
                    }
                });
            }
        }
    }
    
}
