//
//  HarvestListViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import Alamofire
import HDWalletKit

class HardListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var hardTableView: UITableView!
    var refresher: UIRefreshControl!
    
    var mHardParam: Kava_Hard_V1beta1_Params?
    var mHardInterestRates: Array<Kava_Hard_V1beta1_MoneyMarketInterestRate> = Array<Kava_Hard_V1beta1_MoneyMarketInterestRate>()
    var mHardTotalDeposit: Array<Coin> = Array<Coin>()
    var mHardTotalBorrow: Array<Coin> = Array<Coin>()
    var mHardMyDeposit: Array<Coin> = Array<Coin>()
    var mHardMyBorrow: Array<Coin> = Array<Coin>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.hardTableView.delegate = self
        self.hardTableView.dataSource = self
        self.hardTableView.register(UINib(nibName: "HardListMyStatusCell", bundle: nil), forCellReuseIdentifier: "HardListMyStatusCell")
        self.hardTableView.register(UINib(nibName: "HardListCell", bundle: nil), forCellReuseIdentifier: "HardListCell")
        
        self.hardTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.hardTableView.rowHeight = UITableView.automaticDimension
        self.hardTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchHardData), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.hardTableView.addSubview(refresher)
        
        self.onFetchHardData()
    }
    
    var mFetchCnt = 0
    @objc func onFetchHardData() {
        if (self.mFetchCnt > 0)  {
            self.refresher.endRefreshing()
            return
        }
        self.mFetchCnt = 6
        self.mHardInterestRates.removeAll()
        self.mHardTotalDeposit.removeAll()
        self.mHardTotalBorrow.removeAll()
        self.mHardMyDeposit.removeAll()
        self.mHardMyBorrow.removeAll()
        
        self.onFetchgRPCHardParam()
        self.onFetchgRPCHardInterestRate()
        self.onFetchgRPCHardTotalDeposit()
        self.onFetchgRPCHardTotalBorrow()
        self.onFetchgRPCHardMyDeposit(account!.account_address)
        self.onFetchgRPCHardMyBorrow(account!.account_address)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            self.hardTableView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return mHardParam?.moneyMarkets.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"HardListMyStatusCell") as? HardListMyStatusCell
            cell?.onBindMyHard(self.mHardParam, self.mHardMyDeposit, self.mHardMyBorrow)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"HardListCell") as? HardListCell
            cell?.onBindView(indexPath.row, self.mHardParam, self.mHardMyDeposit, self.mHardMyBorrow, self.mHardInterestRates)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let hardDetailVC = HardDetailViewController(nibName: "HardDetailViewController", bundle: nil)
            hardDetailVC.mHardMoneyMarketDenom = mHardParam!.moneyMarkets[indexPath.row].denom
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(hardDetailVC, animated: true)
        }
    }
    
    func onFetchgRPCHardParam()  {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryParamsRequest.init()
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).params(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mHardParam = response.params
                    BaseData.instance.mKavaHardParams_gRPC = response.params
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardParam failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCHardInterestRate()  {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryInterestRateRequest.init()
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).interestRate(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mHardInterestRates = response.interestRates
                    BaseData.instance.mHardInterestRates = response.interestRates
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardInterestRate failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCHardTotalDeposit()  {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryTotalDepositedRequest.init()
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).totalDeposited(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.suppliedCoins.forEach {
                        self.mHardTotalDeposit.append(Coin.init($0.denom, $0.amount))
                    }
                    BaseData.instance.mHardTotalDeposit = self.mHardTotalDeposit
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardTotalDeposit failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCHardTotalBorrow()  {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryTotalBorrowedRequest.init()
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).totalBorrowed(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.borrowedCoins.forEach {
                        self.mHardTotalBorrow.append(Coin.init($0.denom, $0.amount))
                    }
                    BaseData.instance.mHardTotalBorrow = self.mHardTotalBorrow
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardTotalBorrow failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCHardMyDeposit(_ address: String)  {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryDepositsRequest.with { $0.owner = address }
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).deposits(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if (response.deposits.count > 0) {
                        let depositCoins = response.deposits[0].amount
                        depositCoins.forEach { rawCoin in
                            self.mHardMyDeposit.append(Coin.init(rawCoin.denom, rawCoin.amount))
                        }
                    }
                    BaseData.instance.mHardMyDeposit = self.mHardMyDeposit
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardMyDeposit failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCHardMyBorrow(_ address: String)  {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Hard_V1beta1_QueryBorrowsRequest.with { $0.owner = address }
                if let response = try? Kava_Hard_V1beta1_QueryClient(channel: channel).borrows(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if (response.borrows.count > 0) {
                        let borrowCoins = response.borrows[0].amount
                        borrowCoins.forEach { rawCoin in
                            self.mHardMyBorrow.append(Coin.init(rawCoin.denom, rawCoin.amount))
                        }
                    }
                    BaseData.instance.mHardMyBorrow = self.mHardMyBorrow
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCHardMyBorrow failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
