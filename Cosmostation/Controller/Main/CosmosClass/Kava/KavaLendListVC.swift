//
//  KavaLendListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaLendListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKava60!
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
            let channel = getConnection()
            if let hardParam = try? await fetchLendingParam(channel),
               let hardInterestRate = try? await fetchLendingInterestRate(channel),
               let hardTotalDeposit = try? await fetchLendingTotalDeposit(channel),
               let hardTotalBorrow = try? await fetchLendingTotalBorrow(channel),
               let myDeposit = try? await fetchLendingMyDeposit(channel, selectedChain.address!),
               let myBorrow = try? await fetchLendingMyBorrow(channel, selectedChain.address!) {
                
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
        let hardAction = KavaHardAction(nibName: "KavaHardAction", bundle: nil)
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
        let hardAction = KavaHardAction(nibName: "KavaHardAction", bundle: nil)
        hardAction.hardActionType = .Withdraw
        hardAction.selectedChain = selectedChain
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
    }
    
    func onBorrowHardTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let hardAction = KavaHardAction(nibName: "KavaHardAction", bundle: nil)
        hardAction.hardActionType = .Borrow
        hardAction.selectedChain = selectedChain
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
    }
    
    func onRepayHardTx(_ denom: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let hardAction = KavaHardAction(nibName: "KavaHardAction", bundle: nil)
        hardAction.hardActionType = .Repay
        hardAction.selectedChain = selectedChain
        hardAction.modalTransitionStyle = .coverVertical
        self.present(hardAction, animated: true)
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
            onStartSheet(baseSheet)
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectHardAction) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                if (result.position == 0) {
                    self.onDepositHardTx(result.param!)
                } else if (result.position == 1) {
                    self.onWithdrawHardTx(result.param!)
                } else if (result.position == 2) {
                    self.onBorrowHardTx(result.param!)
                } else if (result.position == 3) {
                    self.onRepayHardTx(result.param!)
                }
//                let aa = HardActionType.init(rawValue: result.position!)
            });
        }
        
    }
    
    
    
}


extension KavaLendListVC {
    
    func fetchLendingParam(_ channel: ClientConnection) async throws -> Kava_Hard_V1beta1_QueryParamsResponse? {
        let req = Kava_Hard_V1beta1_QueryParamsRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: channel).params(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingInterestRate(_ channel: ClientConnection) async throws -> Kava_Hard_V1beta1_QueryInterestRateResponse? {
        let req = Kava_Hard_V1beta1_QueryInterestRateRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: channel).interestRate(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingTotalDeposit(_ channel: ClientConnection) async throws -> Kava_Hard_V1beta1_QueryTotalDepositedResponse? {
        let req = Kava_Hard_V1beta1_QueryTotalDepositedRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: channel).totalDeposited(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingTotalBorrow(_ channel: ClientConnection) async throws -> Kava_Hard_V1beta1_QueryTotalBorrowedResponse? {
        let req = Kava_Hard_V1beta1_QueryTotalBorrowedRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: channel).totalBorrowed(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingMyDeposit(_ channel: ClientConnection, _ address: String) async throws -> Kava_Hard_V1beta1_QueryDepositsResponse? {
        let req = Kava_Hard_V1beta1_QueryDepositsRequest.with { $0.owner = address }
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: channel).deposits(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingMyBorrow(_ channel: ClientConnection, _ address: String) async throws -> Kava_Hard_V1beta1_QueryBorrowsResponse? {
        let req = Kava_Hard_V1beta1_QueryBorrowsRequest.with { $0.owner = address }
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: channel).borrows(req, callOptions: getCallOptions()).response.get()
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.grpcHost, port: selectedChain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}


extension Kava_Hard_V1beta1_Params {
    
    public func getHardMoneyMarket(_ denom: String) -> Kava_Hard_V1beta1_MoneyMarket? {
        return moneyMarkets.filter { $0.denom == denom }.first
    }
    
    public func getLTV(_ denom: String) -> NSDecimalNumber {
        if let market = moneyMarkets.filter({ $0.denom == denom }).first {
            return NSDecimalNumber.init(string: market.borrowLimit.loanToValue).multiplying(byPowerOf10: -18)
        }
        return NSDecimalNumber.zero
    }
    
    public func getSpotMarketId(_ denom: String) -> String {
        if let market = moneyMarkets.filter({ $0.denom == denom }).first {
            return market.spotMarketID
        }
        return ""
    }
}
