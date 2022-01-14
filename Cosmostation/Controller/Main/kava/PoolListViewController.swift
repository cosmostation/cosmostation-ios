//
//  KavaPoolViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/27.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class PoolListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var swapPoolTableView: UITableView!
    var refresher: UIRefreshControl!
    var pageHolderVC: DAppsListViewController!
    
    var mKavaSwapPoolParam: Kava_Swap_V1beta1_Params?
    var mKavaSwapPools: Array<Kava_Swap_V1beta1_PoolResponse> = Array<Kava_Swap_V1beta1_PoolResponse>()
    var mMyKavaPoolDeposits: Array<Kava_Swap_V1beta1_DepositResponse> = Array<Kava_Swap_V1beta1_DepositResponse>()
    var mMyKavaSwapPools: Array<Kava_Swap_V1beta1_PoolResponse> = Array<Kava_Swap_V1beta1_PoolResponse>()
    var mOtherKavaSwapPools: Array<Kava_Swap_V1beta1_PoolResponse> = Array<Kava_Swap_V1beta1_PoolResponse>()
    
    override func viewDidLoad() {
        print("PoolListViewController viewDidLoad")
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.swapPoolTableView.delegate = self
        self.swapPoolTableView.dataSource = self
        self.swapPoolTableView.register(UINib(nibName: "CommonPoolCell", bundle: nil), forCellReuseIdentifier: "CommonPoolCell")
        self.swapPoolTableView.register(UINib(nibName: "CommonMyPoolCell", bundle: nil), forCellReuseIdentifier: "CommonMyPoolCell")
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onReFetchData), for: .valueChanged)
        self.refresher.tintColor = UIColor.white
        self.swapPoolTableView.addSubview(refresher)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("PoolListViewController viewDidAppear")
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKavaSwapPoolDone(_:)), name: Notification.Name("KavaSwapPoolDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("KavaSwapPoolDone"), object: nil)
    }
    
    @objc func onReFetchData() {
        self.pageHolderVC.onFetchKavaSwapPoolData()
    }
    
    @objc func onKavaSwapPoolDone(_ notification: NSNotification) {
        print("onKavaSwapPoolDone")
        self.mMyKavaSwapPools.removeAll()
        self.mOtherKavaSwapPools.removeAll()
        self.mKavaSwapPoolParam = BaseData.instance.mKavaSwapPoolParam
        self.pageHolderVC = self.parent as? DAppsListViewController
        self.mKavaSwapPools = pageHolderVC.mKavaSwapPools
        self.mMyKavaPoolDeposits = pageHolderVC.mMyKavaPoolDeposits
        
        self.mKavaSwapPools.forEach { kavaSwapPool in
            var myPool = false
            if (mMyKavaPoolDeposits.filter { $0.poolID == kavaSwapPool.name }.first != nil) {
                myPool = true
            }
            if (myPool) { mMyKavaSwapPools.append(kavaSwapPool) }
            else { mOtherKavaSwapPools.append(kavaSwapPool) }
        }
        self.swapPoolTableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mMyKavaSwapPools.count
        } else {
            return mOtherKavaSwapPools.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"CommonMyPoolCell") as? CommonMyPoolCell
//            let pool = mMySwapPools[indexPath.row]
//            let myDeposit = mMySwapPoolDeposits.filter { $0.pool_id == pool.name }.first!
//            cell?.onBindKavaPoolView(pool, myDeposit)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"CommonPoolCell") as? CommonPoolCell
//            let pool = mOtherSwapPools[indexPath.row]
//            cell?.onBindKavaPoolView(pool)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (indexPath.section == 0) {
//            let noticeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//            noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("title_pool_join", comment: ""), style: .default, handler: { _ in
//                self.onCheckPoolJoin(self.mMySwapPools[indexPath.row])
//            }))
//            noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("title_pool_exit", comment: ""), style: .default, handler: { _ in
//                self.onCheckExitJoin(self.mMySwapPools[indexPath.row])
//            }))
//            self.present(noticeAlert, animated: true) {
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
//                noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
//            }
//
//        } else {
//            self.onCheckPoolJoin(self.mOtherSwapPools[indexPath.row])
//        }
    }
    
    func onCheckPoolJoin(_ pool: Kava_Swap_V1beta1_PoolResponse) {
//        print("onCheckPoolJoin ", pool.name)
//        if (!account!.account_has_private) {
//            self.onShowAddMenomicDialog()
//            return
//        }
//
//        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
//        txVC.mType = KAVA_MSG_TYPE_SWAP_DEPOSIT
//        txVC.mKavaPool = pool
//        self.navigationItem.title = ""
//        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCheckExitJoin(_ pool: Kava_Swap_V1beta1_PoolResponse) {
//        print("onCheckExitJoin ", pool.name)
//        if (!account!.account_has_private) {
//            self.onShowAddMenomicDialog()
//            return
//        }
//        let myDeposit = mMySwapPoolDeposits.filter { $0.pool_id == pool.name }.first!
//
//        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
//        txVC.mType = KAVA_MSG_TYPE_SWAP_WITHDRAW
//        txVC.mKavaPool = pool
//        txVC.mKavaDeposit = myDeposit
//        self.navigationItem.title = ""
//        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
}
