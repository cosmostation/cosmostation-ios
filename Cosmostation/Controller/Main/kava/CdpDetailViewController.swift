//
//  CdpDetailViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/27.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import Alamofire
import AlamofireImage

class CdpDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cdpDetailTableView: UITableView!
    @IBOutlet weak var createCdpBtn: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    var refresher: UIRefreshControl!
    @IBOutlet weak var emptyConstraint: NSLayoutConstraint!
    @IBOutlet weak var owenConstraint: NSLayoutConstraint!
    
    var mCDenom: String = ""
    var mPDenom: String = ""
    var cDpDecimal:Int16 = 6
    var pDpDecimal:Int16 = 6
    var kDpDecimal:Int16 = 6
    var mMarketID: String = ""
    var cAvailable: NSDecimalNumber = NSDecimalNumber.zero
    var pAvailable: NSDecimalNumber = NSDecimalNumber.zero
    var kAvailable: NSDecimalNumber = NSDecimalNumber.zero
    var currentPrice: NSDecimalNumber = NSDecimalNumber.zero
    var liquidationPrice: NSDecimalNumber = NSDecimalNumber.zero
    var riskRate: NSDecimalNumber = NSDecimalNumber.zero
    
    var mCollateralParamType: String!
    var mCollateralParam: Kava_Cdp_V1beta1_CollateralParam!
    var mKavaCdpParams_gRPC: Kava_Cdp_V1beta1_Params?
    var mKavaMyCdp_gRPC: Kava_Cdp_V1beta1_CDPResponse?
    var mDebtAmount: NSDecimalNumber = NSDecimalNumber.zero
    var mSelfDepositAmount: NSDecimalNumber = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.cdpDetailTableView.delegate = self
        self.cdpDetailTableView.dataSource = self
        self.cdpDetailTableView.register(UINib(nibName: "CdpDetailTopCell", bundle: nil), forCellReuseIdentifier: "CdpDetailTopCell")
        self.cdpDetailTableView.register(UINib(nibName: "CdpDetailMyTopCell", bundle: nil), forCellReuseIdentifier: "CdpDetailMyTopCell")
        self.cdpDetailTableView.register(UINib(nibName: "CdpDetailMyActionCell", bundle: nil), forCellReuseIdentifier: "CdpDetailMyActionCell")
        self.cdpDetailTableView.register(UINib(nibName: "CdpDetailAssetsCell", bundle: nil), forCellReuseIdentifier: "CdpDetailAssetsCell")
        self.cdpDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.cdpDetailTableView.rowHeight = UITableView.automaticDimension
        self.cdpDetailTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchCdpData), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.cdpDetailTableView.addSubview(refresher)
        
        mKavaCdpParams_gRPC = BaseData.instance.mKavaCdpParams_gRPC
        
        self.loadingImg.onStartAnimation()
        self.onFetchCdpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_cdp_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_cdp_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mKavaMyCdp_gRPC != nil) {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (mKavaMyCdp_gRPC != nil) {
            if (indexPath.row == 0) {
                return self.onSetMyTopItems(tableView, indexPath)
            } else if (indexPath.row == 1) {
                return self.onSetMyActionItems(tableView, indexPath)
            } else {
                return self.onSetAssetsItems(tableView, indexPath)
            }

        } else {
            if (indexPath.row == 0) {
                return self.onSetTopItems(tableView, indexPath)
            } else {
                return self.onSetAssetsItems(tableView, indexPath)
            }
        }
    }
    
    func onSetTopItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell:CdpDetailTopCell? = tableView.dequeueReusableCell(withIdentifier:"CdpDetailTopCell") as? CdpDetailTopCell
        cell?.onBindCdpDetailTop(mCollateralParam, mDebtAmount)
        cell?.helpCollateralRate = {
            self.onShowSimpleHelp(NSLocalizedString("help_collateral_rate_title", comment: ""), NSLocalizedString("help_collateral_rate_msg", comment: ""))
        }
        cell?.helpStabilityFee = {
            self.onShowSimpleHelp(NSLocalizedString("help_stability_fee_title", comment: ""), NSLocalizedString("help_stability_fee_msg", comment: ""))
        }
        cell?.helpLiquidationPenalty = {
            self.onShowSimpleHelp(NSLocalizedString("help_liquidation_penalty_title", comment: ""), NSLocalizedString("help_liquidation_penalty_msg", comment: ""))
        }
        return cell!
        
    }
    
    func onSetMyTopItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell:CdpDetailMyTopCell? = tableView.dequeueReusableCell(withIdentifier:"CdpDetailMyTopCell") as? CdpDetailMyTopCell
        cell?.onBindCdpDetailMy(mCollateralParam, mKavaMyCdp_gRPC, mDebtAmount)
        cell?.helpCollateralRate = {
            self.onShowSimpleHelp(NSLocalizedString("help_collateral_rate_title", comment: ""), NSLocalizedString("help_collateral_rate_msg", comment: ""))
        }
        cell?.helpStabilityFee = {
            self.onShowSimpleHelp(NSLocalizedString("help_stability_fee_title", comment: ""), NSLocalizedString("help_stability_fee_msg", comment: ""))
        }
        cell?.helpLiquidationPenalty = {
            self.onShowSimpleHelp(NSLocalizedString("help_liquidation_penalty_title", comment: ""), NSLocalizedString("help_liquidation_penalty_msg", comment: ""))
        }
        return cell!
    }
    
    func onSetMyActionItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell  {
        let cell:CdpDetailMyActionCell? = tableView.dequeueReusableCell(withIdentifier:"CdpDetailMyActionCell") as? CdpDetailMyActionCell
        cell?.onBindCdpDetailAction(mCollateralParam, mKavaMyCdp_gRPC, mSelfDepositAmount, mDebtAmount)
        cell?.helpCollateralSelf = {
            self.onShowSimpleHelp(NSLocalizedString("help_self_deposited_title", comment: ""), String(format: NSLocalizedString("help_self_deposited_msg", comment: ""), self.mCDenom.uppercased()))
        }
        cell?.helpCollateralTotal = {
            self.onShowSimpleHelp(NSLocalizedString("help_total_deposited_title", comment: ""), String(format: NSLocalizedString("help_total_deposited_msg", comment: ""), self.mCDenom.uppercased()))
        }
        cell?.helpCollateralWithdrawable = {
            self.onShowSimpleHelp(NSLocalizedString("help_withdrawable_title", comment: ""), NSLocalizedString("help_withdrawable_msg", comment: ""))
        }
        cell?.actionDeposit = {
            self.onClickDeposit()
        }
        cell?.actionWithdraw = {
            self.onClickWithdraw()
        }
        cell?.helpPrincipal = {
            self.onShowSimpleHelp(NSLocalizedString("help_loaned_amount_title", comment: ""), NSLocalizedString("help_loaned_amount_msg", comment: ""))
        }
        cell?.helpInterest = {
            self.onShowSimpleHelp(NSLocalizedString("help_total_fee_title", comment: ""), NSLocalizedString("help_total_fee_msg", comment: ""))
        }
        cell?.helpRemaining = {
            self.onShowSimpleHelp(NSLocalizedString("help_remaining_loan_title", comment: ""), NSLocalizedString("help_remaining_loan_msg", comment: ""))
        }
        cell?.actionDrawDebt = {
            self.onClickDrawDebt()
        }
        cell?.actionRepay = {
            self.onClickRepay()
        }
        return cell!
    }
    
    func onSetAssetsItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell:CdpDetailAssetsCell? = tableView.dequeueReusableCell(withIdentifier:"CdpDetailAssetsCell") as? CdpDetailAssetsCell
        cell?.onBindCdpDetailAsset(mCollateralParam)
        return cell!
    }
    
    @IBAction func onClickCreateCdp(_ sender: UIButton) {
        if (!onCommonCheck()) { return }
        let debtFloor = mKavaCdpParams_gRPC!.getDebtFloorAmount()
        let cMinAmount = debtFloor.multiplying(byPowerOf10: cDpDecimal - pDpDecimal).multiplying(by: NSDecimalNumber.init(string: "1.05263157895")).multiplying(by: mCollateralParam!.getLiquidationRatioAmount()).dividing(by: currentPrice, withBehavior: WUtils.handler0Up)
        if (cAvailable.compare(cMinAmount).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_less_than_min_deposit", comment: ""))
            return
        }
        if (mKavaCdpParams_gRPC!.getGlobalDebtAmount().compare(mDebtAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_no_more_debt_kava", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_CDP_CREATE
        txVC.mCollateralParamType = self.mCollateralParamType
        txVC.mCDenom = self.mCDenom
        txVC.mMarketID = self.mCollateralParam.liquidationMarketID
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickDeposit() {
        if (!onCommonCheck()) { return }
        if (cAvailable.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enought_deposit_asset", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_CDP_DEPOSIT
        txVC.mCollateralParamType = self.mCollateralParamType
        txVC.mCDenom = self.mCDenom
        txVC.mMarketID = self.mCollateralParam.liquidationMarketID
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickWithdraw() {
        if (!onCommonCheck()) { return }
        let maxWithdrawableAmount = mKavaMyCdp_gRPC!.getWithdrawableAmount(mCDenom, mPDenom, mCollateralParam!, currentPrice, mSelfDepositAmount)
        if (maxWithdrawableAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enought_withdraw_asset", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_CDP_WITHDRAW
        txVC.mCollateralParamType = self.mCollateralParamType
        txVC.mCDenom = self.mCDenom
        txVC.mMarketID = self.mCollateralParam.liquidationMarketID
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickDrawDebt() {
        if (!onCommonCheck()) { return }
        if (mKavaMyCdp_gRPC!.getMoreLoanableAmount(mCollateralParam!).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_can_not_draw_debt", comment: ""))
            return
        }
        if (mKavaCdpParams_gRPC!.getGlobalDebtAmount().compare(mDebtAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_no_more_debt_kava", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_CDP_DRAWDEBT
        txVC.mCollateralParamType = self.mCollateralParamType
        txVC.mCDenom = self.mCDenom
        txVC.mMarketID = self.mCollateralParam.liquidationMarketID
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickRepay() {
        if (!onCommonCheck()) { return }
        if (pAvailable.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enought_principal_asset", comment: ""))
            return
        }
        var repayAll = true
        var repayPart = true
        let debtFloor = mKavaCdpParams_gRPC!.getDebtFloorAmount()
        let rawDebt = mKavaMyCdp_gRPC!.getRawPrincipalAmount()
        let totalDebt = mKavaMyCdp_gRPC!.getEstimatedTotalDebt(mCollateralParam!)
        if (totalDebt.compare(pAvailable).rawValue > 0) { repayAll = false }
        if (rawDebt.compare(debtFloor).rawValue <= 0) { repayPart = false }
        if (!repayAll && !repayPart) {
            self.onShowToast(NSLocalizedString("error_can_not_repay", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_CDP_REPAY
        txVC.mCollateralParamType = self.mCollateralParamType
        txVC.mCDenom = self.mCDenom
        txVC.mMarketID = self.mCollateralParam.liquidationMarketID
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCommonCheck() -> Bool {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return false
        }
        
        if (BaseData.instance.mKavaCdpParams_gRPC?.circuitBreaker == true) {
            self.onShowToast(NSLocalizedString("error_circuit_breaker", comment: ""))
            return false
        }
        return true
    }
    
    
    var mFetchCnt = 0
    @objc func onFetchCdpData() {
        if (self.mFetchCnt > 0)  {
            self.refresher.endRefreshing()
            return
        }
        self.mFetchCnt = 2
        self.onFetchgRPCMyCdp(account!.account_address, mCollateralParamType)
        self.onFetchCdpDeposit(account!.account_address, mCollateralParamType)
        self.mDebtAmount = NSDecimalNumber.init(string: BaseData.instance.mParam?.getSupplyDenom("debt")?.amount)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {

            self.mCollateralParam = BaseData.instance.mKavaCdpParams_gRPC?.getCollateralParamByType(mCollateralParamType)
            self.mCDenom = mCollateralParam!.getcDenom()!
            self.mPDenom = mCollateralParam!.getpDenom()!
            guard let cMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == mCDenom }).first,
                  let pMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == mPDenom }).first,
                  let kMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == KAVA_MAIN_DENOM }).first else {
                return
            }
            self.cDpDecimal = cMsAsset.decimals
            self.pDpDecimal = pMsAsset.decimals
            self.kDpDecimal = kMsAsset.decimals
            self.cAvailable = BaseData.instance.getAvailableAmount_gRPC(mCDenom)
            self.pAvailable = BaseData.instance.getAvailableAmount_gRPC(mPDenom)
            self.kAvailable = BaseData.instance.getAvailableAmount_gRPC(KAVA_MAIN_DENOM)
            self.currentPrice = BaseData.instance.getKavaOraclePrice(mCollateralParam?.liquidationMarketID)
            
            if (mKavaMyCdp_gRPC != nil) {
                emptyConstraint?.isActive = false
                owenConstraint?.isActive = true
                createCdpBtn.isHidden = true
            } else {
                emptyConstraint?.isActive = true
                owenConstraint?.isActive = false
                createCdpBtn.isHidden = false
            }
            self.cdpDetailTableView.reloadData()
            self.cdpDetailTableView.isHidden = false
            self.loadingImg.onStopAnimation()
            self.loadingImg.isHidden = true
            self.refresher.endRefreshing()
        }
    }
    
    func onShowSimpleHelp(_ title:String, _ msg:String) {
        let helpAlert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        helpAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString(
            string: msg,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
            ]
        )
        helpAlert.setValue(attributedMessage, forKey: "attributedMessage")
        helpAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(helpAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            helpAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onFetchgRPCMyCdp(_ address: String, _ collateralType: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Cdp_V1beta1_QueryCdpRequest.with { $0.owner = address; $0.collateralType = collateralType }
                if let response = try? Kava_Cdp_V1beta1_QueryClient(channel: channel).cdp(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mKavaMyCdp_gRPC = response.cdp
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCMyCdp failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchCdpDeposit(_ address: String, _ collateralType: String) {
        let request = Alamofire.request(BaseNetWork.depositCdpUrl(chainType, address, collateralType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                let cdpDeposits = KavaCdpDeposits.init(responseData)
                if let selfDeposit = cdpDeposits.result?.filter({ $0.depositor == self.account?.account_address}).first {
                    self.mSelfDepositAmount = NSDecimalNumber.init(string: selfDeposit.amount?.amount)
                }

            case .failure(let error):
                print("onFetchCdpDeposit ", error)
            }
            self.onFetchFinished()
        }
    }
    
//    //TODO check this grpc not working!
//    func onFetchgRPCCdpDeposits(_ address: String, _ collateralType: String) {
//        DispatchQueue.global().async {
//            do {
//                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
//                let req = Kava_Cdp_V1beta1_QueryDepositsRequest.with { $0.owner = address; $0.collateralType = collateralType }
//                if let response = try? Kava_Cdp_V1beta1_QueryClient(channel: channel).deposits(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    response.deposits.forEach { deposit in
//                        self.mSelfDepositAmount = NSDecimalNumber.init(string: deposit.amount.amount)
//                    }
//                }
//                try channel.close().wait()
//
//            } catch {
//                print("onFetchgRPCCdpDeposits failed: \(error)")
//            }
//            DispatchQueue.main.async(execute: { self.onFetchFinished() });
//        }
//    }
}
