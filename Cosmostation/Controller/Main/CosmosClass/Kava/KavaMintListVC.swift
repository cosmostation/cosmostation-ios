//
//  KavaMintListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaMintListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKava60!
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var cdpParam: Kava_Cdp_V1beta1_Params?
    var myCollateralParamList = [Kava_Cdp_V1beta1_CollateralParam]()
    var otherCollateralParamList = [Kava_Cdp_V1beta1_CollateralParam]()
    var myCdp: [Kava_Cdp_V1beta1_CDPResponse]?

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
        tableView.register(UINib(nibName: "KavaMintListMyCell", bundle: nil), forCellReuseIdentifier: "KavaMintListMyCell")
        tableView.register(UINib(nibName: "KavaMintListCell", bundle: nil), forCellReuseIdentifier: "KavaMintListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_mint_list", comment: "")
    }
    
    func onFetchData() {
        Task {
            let channel = getConnection()
            if let cdpParam = try? await fetchMintParam(channel),
               let myCdps = try? await fetchMyCdps(channel, selectedChain.address!) {
                
                cdpParam?.collateralParams.forEach({ collateralParam in
                    if (myCdps?.filter({ $0.type == collateralParam.type }).count ?? 0 > 0) {
                        myCollateralParamList.append(collateralParam)
                    } else {
                        otherCollateralParamList.append(collateralParam)
                    }
                })
                self.cdpParam = cdpParam
                self.myCdp = myCdps
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

    
    func onCreateCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintCreate = KavaMintCreateAction(nibName: "KavaMintCreateAction", bundle: nil)
        mintCreate.selectedChain = selectedChain
        mintCreate.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintCreate.priceFeed = priceFeed
        mintCreate.modalTransitionStyle = .coverVertical
        self.present(mintCreate, animated: true)
    }
    
    func onDepositCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .Deposit
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
    
    func onWithdrawCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .Withdraw
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
    
    func onDrawDebtCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .DrawDebt
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
    
    func onRepayCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .Repay
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
}

extension KavaMintListVC: UITableViewDelegate, UITableViewDataSource, BaseSheetDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return myCollateralParamList.count
        } else {
            return otherCollateralParamList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaMintListMyCell") as? KavaMintListMyCell
            let collateralParam = myCollateralParamList[indexPath.row]
            let myCdp = myCdp?.filter({ $0.type == collateralParam.type }).first!
            cell?.onBindCdp(collateralParam, priceFeed, myCdp)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaMintListCell") as? KavaMintListCell
            let collateralParam = otherCollateralParamList[indexPath.row]
            cell?.onBindCdp(collateralParam)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.cdpType = myCollateralParamList[indexPath.row].type
            baseSheet.sheetDelegate = self
            baseSheet.sheetType = .SelectMintAction
            onStartSheet(baseSheet)
            
        } else {
            onCreateCdpTx(otherCollateralParamList[indexPath.row].type)
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectMintAction) {
            if let cdpType = result["cdpType"] as? String,
               let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if (index == 0) {
                        self.onDepositCdpTx(cdpType)
                    } else if (index == 1) {
                        self.onWithdrawCdpTx(cdpType)
                    } else if (index == 2) {
                        self.onDrawDebtCdpTx(cdpType)
                    } else if (index == 3) {
                        self.onRepayCdpTx(cdpType)
                    }
                });
            }
        }
    }
    
}


extension KavaMintListVC {
    
    func fetchMintParam(_ channel: ClientConnection) async throws -> Kava_Cdp_V1beta1_Params? {
        let req = Kava_Cdp_V1beta1_QueryParamsRequest()
        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: channel).params(req, callOptions: getCallOptions()).response.get().params
    }
    
    func fetchMyCdps(_ channel: ClientConnection, _ address: String) async throws -> [Kava_Cdp_V1beta1_CDPResponse]? {
        let req = Kava_Cdp_V1beta1_QueryCdpsRequest.with { $0.owner = address }
        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: channel).cdps(req, callOptions: getCallOptions()).response.get().cdps
    }
    
//    func fetchMyDeposit(_ group: DispatchGroup, _ channel: ClientConnection, _ address: String, _ collateralType: String) async throws -> [Kava_Cdp_V1beta1_Deposit]? {
//        let req = Kava_Cdp_V1beta1_QueryDepositsRequest.with { $0.owner = address; $0.collateralType = collateralType }
//        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: channel).deposits(req, callOptions: getCallOptions()).response.get().deposits
//    }
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
    
}


extension Kava_Cdp_V1beta1_CollateralParam {
    public func getLiquidationRatioAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: liquidationRatio).multiplying(byPowerOf10: -18)
    }
    
    public func getDpLiquidationRatio() -> NSDecimalNumber {
        return getLiquidationRatioAmount().multiplying(byPowerOf10: 2, withBehavior: handler2)
    }
    
    public func getLiquidationPenaltyAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: liquidationPenalty).multiplying(byPowerOf10: -18)
    }
    
    public func getDpLiquidationPenalty() -> NSDecimalNumber {
        return getLiquidationPenaltyAmount().multiplying(byPowerOf10: 2, withBehavior: handler2)
    }
    
    public func getExpectCollateralUsdxValue(_ collateralAmount: NSDecimalNumber, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
        let collateralPrice = priceFeed.getKavaOraclePrice(liquidationMarketID)
        let collateralValue = collateralAmount.multiplying(by: collateralPrice).multiplying(byPowerOf10: -Int16(conversionFactor)!, withBehavior: handler6)
        return collateralValue.multiplying(byPowerOf10: 6, withBehavior: handler0)
    }
    
    public func getExpectUsdxLTV(_ collateralAmount: NSDecimalNumber, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
        return getExpectCollateralUsdxValue(collateralAmount, priceFeed).dividing(by: getLiquidationRatioAmount(), withBehavior: handler0)
    }
}

extension Kava_Cdp_V1beta1_CDPResponse {
    
    public func getCollateralAmount() -> NSDecimalNumber {
        return collateral.getAmount()
    }
    
    public func getCollateralUsdxAmount() -> NSDecimalNumber {
        return collateralValue.getAmount().multiplying(byPowerOf10: -6, withBehavior: handler6)
    }
    
//    public func getCollateralValue(_ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
//        let principalPrice = priceFeed.getKavaOraclePrice("usdx:usd")
//        return getCollateralUsdxAmount().multiplying(by: principalPrice).multiplying(byPowerOf10: -6, withBehavior: handler6)
//    }
    
    public func getUsdxLTV(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        return getCollateralUsdxAmount().dividing(by: collateralParam.getLiquidationRatioAmount())
    }
    
    public func getPrincipalAmount() -> NSDecimalNumber {
        return principal.getAmount()
    }
    
    public func getDebtAmount() -> NSDecimalNumber {
        return getPrincipalAmount().adding(accumulatedFees.getAmount())
    }
    
    public func getDebtUsdxValue() -> NSDecimalNumber {
        return getDebtAmount().multiplying(byPowerOf10: -6, withBehavior: handler6)
    }
    
//    public func getDebtValue(_ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
//        let principalPrice = priceFeed.getKavaOraclePrice("usdx:usd")
//        return getDebtAmount().multiplying(by: principalPrice).multiplying(byPowerOf10: -6, withBehavior: handler6)
//    }
    
    public func getLiquidationPrice(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        let cDenomDecimal = Int16(collateralParam.conversionFactor)!
        let collateralAmount = getCollateralAmount().multiplying(byPowerOf10: -cDenomDecimal)
        let rawDebtAmount = getDebtAmount()
            .multiplying(by: collateralParam.getLiquidationRatioAmount())
            .multiplying(byPowerOf10: -6)
        return rawDebtAmount.dividing(by: collateralAmount, withBehavior: handler6)
    }
}
