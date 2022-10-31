//
//  EarnViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class EarnViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var earnTableView: UITableView!
    @IBOutlet weak var btnRemoveLiquidity: UIButton!
    @IBOutlet weak var btnAddLiquidity: UIButton!
    var refresher: UIRefreshControl!
    
    var mEarnDeposits: Array<Coin> = Array<Coin>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.earnTableView.delegate = self
        self.earnTableView.dataSource = self
        self.earnTableView.register(UINib(nibName: "EarnStatusCell", bundle: nil), forCellReuseIdentifier: "EarnStatusCell")
        self.earnTableView.register(UINib(nibName: "EarnValidatorCell", bundle: nil), forCellReuseIdentifier: "EarnValidatorCell")
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchData), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        
        self.onFetchData()
    }
    
    var mFetchCnt = 0
    @objc func onFetchData() {
        self.mFetchCnt = 1
        self.onFetchgRPCMyEarnDeposits(account!.account_address)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        mEarnDeposits.sort{
            if ($0.denom == "bkava-kavavaloper140g8fnnl46mlvfhygj3zvjqlku6x0fwu6lgey7") { return true }
            if ($1.denom == "bkava-kavavaloper140g8fnnl46mlvfhygj3zvjqlku6x0fwu6lgey7") { return false }
            return false
        }
        if (mFetchCnt <= 0) {
            self.earnTableView.reloadData()
            self.refresher.endRefreshing()
        }
        print("Earnings ", mEarnDeposits)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return mEarnDeposits.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"EarnStatusCell") as? EarnStatusCell
            cell?.onBindView(mEarnDeposits)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"EarnValidatorCell") as? EarnValidatorCell
            cell?.onBindView(chainConfig!, mEarnDeposits[indexPath.row])
            return cell!
        }
    }
    
    
    @IBAction func onClickRemoveLiquidity(_ sender: UIButton) {
        print("onClickRemoveLiquidity")
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW
        txVC.mKavaEarnDeposit = mEarnDeposits
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @IBAction func onClickAddLiquidity(_ sender: UIButton) {
        print("onClickAddLiquidity")
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT
        txVC.mKavaEarnDeposit = mEarnDeposits
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onFetchgRPCMyEarnDeposits(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Earn_V1beta1_QueryDepositsRequest.with { $0.depositor = address }
                if let response = try? Kava_Earn_V1beta1_QueryClient(channel: channel).deposits(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.deposits.forEach { deposit in
                        deposit.value.forEach { rawCoin in
                            if (rawCoin.denom.starts(with: "bkava-")) {
                                self.mEarnDeposits.append(Coin.init(rawCoin.denom, rawCoin.amount))
                            }
                        }
                    }
                }
                try channel.close().wait()
                
            } catch { print("onFetchgRPCMyEarnDeposits failed: \(error)") }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
