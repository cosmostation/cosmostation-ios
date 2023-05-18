//
//  HardDetailViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/14.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import Alamofire
import HDWalletKit

class HardDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var harvestDetailTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    var refresher: UIRefreshControl!
    
    var mHardMoneyMarketDenom: String!
    var mHardParam: Kava_Hard_V1beta1_Params?
    var mHardInterestRates: Array<Kava_Hard_V1beta1_MoneyMarketInterestRate> = Array<Kava_Hard_V1beta1_MoneyMarketInterestRate>()
    var mHardModuleCoins: Array<Coin> = Array<Coin>()
    var mHardReserveCoins: Array<Coin> = Array<Coin>()
    var mHardTotalDeposit: Array<Coin> = Array<Coin>()
    var mHardTotalBorrow: Array<Coin> = Array<Coin>()
    var mHardMyDeposit: Array<Coin> = Array<Coin>()
    var mHardMyBorrow: Array<Coin> = Array<Coin>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.balances = BaseData.instance.selectBalanceById(accountId: account!.account_id)
        
        self.mHardParam = BaseData.instance.mKavaHardParams_gRPC
        self.mHardInterestRates = BaseData.instance.mHardInterestRates
        self.mHardTotalDeposit = BaseData.instance.mHardTotalDeposit
        self.mHardTotalBorrow = BaseData.instance.mHardTotalBorrow
        self.mHardMyDeposit = BaseData.instance.mHardMyDeposit
        self.mHardMyBorrow = BaseData.instance.mHardMyBorrow
        
        self.harvestDetailTableView.delegate = self
        self.harvestDetailTableView.dataSource = self
        self.harvestDetailTableView.register(UINib(nibName: "HarvestDetailTopCell", bundle: nil), forCellReuseIdentifier: "HarvestDetailTopCell")
        self.harvestDetailTableView.register(UINib(nibName: "HarvestDetailMyActionCell", bundle: nil), forCellReuseIdentifier: "HarvestDetailMyActionCell")
        self.harvestDetailTableView.register(UINib(nibName: "HardDetailAssetsCell", bundle: nil), forCellReuseIdentifier: "HardDetailAssetsCell")
        self.harvestDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.harvestDetailTableView.rowHeight = UITableView.automaticDimension
        self.harvestDetailTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchHardInfo), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.harvestDetailTableView.addSubview(refresher)
        
        self.loadingImg.onStartAnimation()
        self.onFetchHardInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_harvest_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_harvest_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return self.onBindTop(tableView, indexPath.row)
        } else if (indexPath.row == 1) {
            return self.onBindAction(tableView, indexPath.row)
        } else {
            return self.onBindAsset(tableView, indexPath.row)
        }
    }
    
    func onBindTop(_ tableView: UITableView, _ position:Int) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier:"HarvestDetailTopCell") as? HarvestDetailTopCell
        cell?.onBindHardDetailTop(mHardMoneyMarketDenom, mHardParam, mHardInterestRates, mHardTotalDeposit, mHardTotalBorrow, mHardModuleCoins, mHardReserveCoins)
        return cell!
    }
    
    func onBindAction(_ tableView: UITableView, _ position:Int) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier:"HarvestDetailMyActionCell") as? HarvestDetailMyActionCell
        cell?.onBindHardDetailAction(mHardMoneyMarketDenom, mHardParam, mHardMyDeposit, mHardMyBorrow, mHardModuleCoins, mHardReserveCoins)
        cell?.actionDepoist = { self.onClickDeposit() }
        cell?.actionWithdraw = { self.onClickWithdraw() }
        cell?.actionBorrow = { self.onClickBorrow() }
        cell?.actionRepay = { self.onClickRepay() }
        return cell!
    }
    
    func onBindAsset(_ tableView: UITableView, _ position:Int) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier:"HardDetailAssetsCell") as? HardDetailAssetsCell
        cell?.onBindHardDetailAsset(mHardMoneyMarketDenom, mHardParam!)
        return cell!
    }
    
    
    func onClickDeposit() {
        if (!onCommonCheck()) { return }
        if (BaseData.instance.getAvailableAmount_gRPC(mHardMoneyMarketDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_no_available_to_deposit", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_HARD_DEPOSIT
        txVC.mHardMoneyMarketDenom = mHardMoneyMarketDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickWithdraw() {
        if (!onCommonCheck()) { return }
        let mySuppliedAmount = WUtils.getHardSuppliedAmountByDenom(mHardMoneyMarketDenom, mHardMyDeposit)
        if (mySuppliedAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_no_deposited_asset", comment: ""))
            return
        }
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_HARD_WITHDRAW
        txVC.mHardMoneyMarketDenom = mHardMoneyMarketDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickBorrow() {
        if (!onCommonCheck()) { return }
        let myBorrowableAmount = WUtils.getHardBorrowableAmountByDenom(mHardMoneyMarketDenom!, mHardMyDeposit, mHardMyBorrow, mHardModuleCoins, mHardReserveCoins)
        if (myBorrowableAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_no_borrowable_asset", comment: ""))
            return
        }
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_HARD_BORROW
        txVC.mHardMoneyMarketDenom = mHardMoneyMarketDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickRepay() {
        if (!onCommonCheck()) { return }
        if (BaseData.instance.getAvailableAmount_gRPC(mHardMoneyMarketDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_no_repay_asset", comment: ""))
            return
        }
        let myBorrowedAmount = WUtils.getHardBorrowedAmountByDenom(mHardMoneyMarketDenom!, mHardMyBorrow)
        if (myBorrowedAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_noting_repay_asset", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_HARD_REPAY
        txVC.mHardMoneyMarketDenom = mHardMoneyMarketDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCommonCheck() -> Bool {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return false
        }
        return true
    }
    
    var mFetchCnt = 0
    @objc func onFetchHardInfo() {
        if(self.mFetchCnt > 0)  {
            self.refresher.endRefreshing()
            return
        }
        
        self.mFetchCnt = 2
//        self.onFetchgRPCHardModuleAccount()
        self.onFetchHardModuleAccount()
        self.onFetchgRPCHardReserves()
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            self.harvestDetailTableView.reloadData()
            self.harvestDetailTableView.isHidden = false
            self.loadingImg.onStopAnimation()
            self.loadingImg.isHidden = true
            self.refresher.endRefreshing()
        }
    }
    
    /*
    func onFetchgRPCHardModuleAccount() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Hard_V1beta1_QueryAccountsRequest.init()
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).accounts(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    print("response ", response)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardInterestRate failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
     */
    
    func onFetchHardModuleAccount() {
        let request = Alamofire.request(BaseNetWork.managerHardPoolUrl(chainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseData = res as? NSDictionary, let responseResult = responseData.object(forKey: "accounts") as? Array<NSDictionary>,
                let address = responseResult[0].object(forKey: "address") as? String {
                    self.mFetchCnt = self.mFetchCnt + 1
                    self.onFetchBalance_gRPC(address)
                }
                
            case .failure(let error):
                print("onFetchHardModuleAccount ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchgRPCHardReserves() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryReservesRequest.init()
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).reserves(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.amount.forEach { coin in
                        self.mHardReserveCoins.append(Coin.init(coin.denom, coin.amount))
                    }
                    BaseData.instance.mHardReserveCoins = self.mHardReserveCoins
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardInterestRate failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchBalance_gRPC(_ moduleAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
                let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = moduleAddress; $0.pagination = page }
                if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.balances.forEach { balance in
                        self.mHardModuleCoins.append(Coin.init(balance.denom, balance.amount))
                    }
                    BaseData.instance.mHardModuleCoins = self.mHardModuleCoins
                }
                try channel.close().wait()

            } catch {
                print("onFetchBalance_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
