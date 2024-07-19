//
//  KavaLendListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class KavaLendListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKavaEVM!
    var kavaFetcher: KavaFetcher!
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var hardParams: Kava_Hard_V1beta1_Params?
    var hardInterestRates: [Kava_Hard_V1beta1_MoneyMarketInterestRate]?
    var hardTotalDeposit: [Cosmos_Base_V1beta1_Coin]?
    var hardTotalBorrow: [Cosmos_Base_V1beta1_Coin]?
    var hardMyDeposit: [Cosmos_Base_V1beta1_Coin]?
    var hardMyBorrow: [Cosmos_Base_V1beta1_Coin]?

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
        tableView.register(UINib(nibName: "KavaLendListMyCell", bundle: nil), forCellReuseIdentifier: "KavaLendListMyCell")
        tableView.register(UINib(nibName: "KavaLendListCell", bundle: nil), forCellReuseIdentifier: "KavaLendListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_hardpool_list", comment: "")
    }
    
    func onFetchData() {
        Task {
            if let hardParam = try? await kavaFetcher.fetchLendingParam(),
               let hardInterestRate = try? await kavaFetcher.fetchLendingInterestRate(),
               let hardTotalDeposit = try? await kavaFetcher.fetchLendingTotalDeposit(),
               let hardTotalBorrow = try? await kavaFetcher.fetchLendingTotalBorrow(),
               let myDeposit = try? await kavaFetcher.fetchLendingMyDeposit(),
               let myBorrow = try? await kavaFetcher.fetchLendingMyBorrow() {
                
                self.hardParams = hardParam?.params
                self.hardInterestRates = hardInterestRate?.interestRates
                self.hardTotalDeposit = hardTotalDeposit?.suppliedCoins
                self.hardTotalBorrow = hardTotalBorrow?.borrowedCoins
                if (myDeposit?.deposits.count ?? 0 > 0) {
                    self.hardMyDeposit = myDeposit?.deposits[0].amount
                }
                if (myBorrow?.borrows.count ?? 0 > 0) {
                    self.hardMyBorrow = myBorrow?.borrows[0].amount
                }
                
                self.hardParams?.moneyMarkets.sort {
                    let denom0 = $0.denom
                    let denom1 = $1.denom
                    if (hardMyDeposit?.filter({ $0.denom == denom0 }).count ?? 0 > 0 || hardMyBorrow?.filter({ $0.denom == denom0 }).count ?? 0 > 0) { return true }
                    if (hardMyDeposit?.filter({ $0.denom == denom1 }).count ?? 0 > 0 || hardMyBorrow?.filter({ $0.denom == denom1 }).count ?? 0 > 0) { return false }
                    return false
                }
                
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
    
    func onDepositHardTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let hardAction = KavaLendAction(nibName: "KavaLendAction", bundle: nil)
        hardAction.hardActionType = .Deposit
        hardAction.selectedChain = selectedChain
        hardAction.hardMarket = hardParams?.getHardMoneyMarket(denom)
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
    }
    
    func onWithdrawHardTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let depositedAmount = hardMyDeposit?.filter({ $0.denom == denom }).first?.getAmount() ?? NSDecimalNumber.zero
        if (depositedAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            onShowToast(NSLocalizedString("error_not_enough_to_withdraw", comment: ""))
            return
        }
        let hardAction = KavaLendAction(nibName: "KavaLendAction", bundle: nil)
        hardAction.hardActionType = .Withdraw
        hardAction.selectedChain = selectedChain
        hardAction.hardMyDeposit = hardMyDeposit
        hardAction.hardMarket = hardParams?.getHardMoneyMarket(denom)
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
    }
    
    func onBorrowHardTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let borrowable = getRemainBorrowableAmount(denom)
        if (borrowable.compare(NSDecimalNumber.zero).rawValue < 0) {
            onShowToast(NSLocalizedString("error_no_borrowable_asset", comment: ""))
            return
        }
        let hardAction = KavaLendAction(nibName: "KavaLendAction", bundle: nil)
        hardAction.hardActionType = .Borrow
        hardAction.selectedChain = selectedChain
        hardAction.hardMyDeposit = hardMyDeposit
        hardAction.hardMyBorrow = hardMyBorrow
        hardAction.hardMarket = hardParams?.getHardMoneyMarket(denom)
        hardAction.hardBorrowableAmount = borrowable
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
    }
    
    func onRepayHardTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let borrowedAmount = hardMyBorrow?.filter({ $0.denom == denom }).first?.getAmount() ?? NSDecimalNumber.zero
        if (borrowedAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            onShowToast(NSLocalizedString("error_no_repay_asset", comment: ""))
            return
        }
        let hardAction = KavaLendAction(nibName: "KavaLendAction", bundle: nil)
        hardAction.hardActionType = .Repay
        hardAction.selectedChain = selectedChain
        hardAction.hardMyDeposit = hardMyDeposit
        hardAction.hardMyBorrow = hardMyBorrow
        hardAction.hardMarket = hardParams?.getHardMoneyMarket(denom)
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
    }
    
    func getRemainBorrowableAmount(_ denom: String) -> NSDecimalNumber {
        var totalLTVValue = NSDecimalNumber.zero
        var totalBorrowedValue = NSDecimalNumber.zero
        hardMyDeposit?.forEach({ coin in
            let decimal         = BaseData.instance.mintscanAssets?.filter({ $0.denom == coin.denom }).first?.decimals ?? 6
            let LTV             = hardParams!.getLTV(coin.denom)
            let marketIdPrice   = priceFeed!.getKavaOraclePrice(hardParams!.getSpotMarketId(coin.denom))
            let depositValue    = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: handler12Down)
            let ltvValue        = depositValue.multiplying(by: LTV)
            totalLTVValue       = totalLTVValue.adding(ltvValue)
        })
        hardMyBorrow?.forEach ({ coin in
            let decimal         = BaseData.instance.mintscanAssets?.filter({ $0.denom == coin.denom }).first?.decimals ?? 6
            let marketIdPrice   = priceFeed!.getKavaOraclePrice(hardParams!.getSpotMarketId(coin.denom))
            let borrowValue     = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: handler12Down)
            totalBorrowedValue = totalBorrowedValue.adding(borrowValue)
        })
        
        
        totalLTVValue = totalLTVValue.multiplying(by: NSDecimalNumber.init(string: "0.9"), withBehavior: handler0Down)
        let tempBorrowAbleValue  = totalLTVValue.subtracting(totalBorrowedValue)
        let totalBorrowAbleValue = tempBorrowAbleValue.compare(NSDecimalNumber.zero).rawValue > 0 ? tempBorrowAbleValue : NSDecimalNumber.zero
        
        let oraclePrice = priceFeed!.getKavaOraclePrice(hardParams!.getSpotMarketId(denom))
        let decimal = BaseData.instance.mintscanAssets?.filter({ $0.denom == denom }).first?.decimals ?? 6
        let totalBorrowAbleAmount = totalBorrowAbleValue.multiplying(byPowerOf10: decimal, withBehavior: handler12Down).dividing(by: oraclePrice, withBehavior: handler0Down)
        return totalBorrowAbleAmount.compare(NSDecimalNumber.zero).rawValue > 0 ? totalBorrowAbleAmount : NSDecimalNumber.zero
    }

}

extension KavaLendListVC: UITableViewDelegate, UITableViewDataSource, BaseSheetDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return hardParams?.moneyMarkets.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaLendListMyCell") as? KavaLendListMyCell
            cell?.onBindMyHard(hardParams, priceFeed, hardMyDeposit, hardMyBorrow)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaLendListCell") as? KavaLendListCell
            cell?.onBindHard(hardParams?.moneyMarkets[indexPath.row], priceFeed, hardMyDeposit, hardMyBorrow)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.hardMarketDenom = hardParams?.moneyMarkets[indexPath.row].denom
            baseSheet.sheetType = .SelectHardAction
            onStartSheet(baseSheet, 320, 0.6)
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectHardAction) {
            if let denom = result["denom"] as? String,
               let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDepositHardTx(denom)
                    } else if (index == 1) {
                        self.onWithdrawHardTx(denom)
                    } else if (index == 2) {
                        self.onBorrowHardTx(denom)
                    } else if (index == 3) {
                        self.onRepayHardTx(denom)
                    }
                });
            }
        }
        
    }
}
