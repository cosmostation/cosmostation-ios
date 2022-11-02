//
//  MyAccountViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/10.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class MyAccountViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myAccountTableView: UITableView!
    @IBOutlet weak var myAccountCnt: UILabel!
    
    var refresher: UIRefreshControl!
    
    var myAccounts_gRPC: Array<Starnamed_X_Starname_V1beta1_Account> = Array<Starnamed_X_Starname_V1beta1_Account>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.balances = account!.account_balances
        
        self.myAccountTableView.delegate = self
        self.myAccountTableView.dataSource = self
        self.myAccountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.myAccountTableView.register(UINib(nibName: "AccountPromotionCell", bundle: nil), forCellReuseIdentifier: "AccountPromotionCell")
        self.myAccountTableView.register(UINib(nibName: "AccountCell", bundle: nil), forCellReuseIdentifier: "AccountCell")
        self.myAccountTableView.rowHeight = UITableView.automaticDimension
        self.myAccountTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.myAccountTableView.addSubview(refresher)
        self.myAccountTableView.isHidden = true
        
        self.showWaittingAlert()
        self.onFetchgRPCMyAccount(self.account!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.myAccounts_gRPC.count <= 0) {
            return 1
        } else {
            return self.myAccounts_gRPC.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.myAccounts_gRPC.count <= 0) {
            let cell:AccountPromotionCell? = tableView.dequeueReusableCell(withIdentifier:"AccountPromotionCell") as? AccountPromotionCell
            return cell!
            
        } else {
            let cell:AccountCell? = tableView.dequeueReusableCell(withIdentifier:"AccountCell") as? AccountCell
            let starnameAccount = myAccounts_gRPC[indexPath.row]
            cell?.starNameLabel.text = starnameAccount.name.value + "*" + starnameAccount.domain
            cell?.accountConnectedAddressLabel.text = String(starnameAccount.resources.count)
            let expireTime = starnameAccount.validUntil * 1000
            cell?.accountExpireTime.text = WDP.dpTime(expireTime)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let starnameAccount = myAccounts_gRPC[indexPath.row]
        let accountDetailVC = AccountDetailViewController(nibName: "AccountDetailViewController", bundle: nil)
        accountDetailVC.mMyDomain = starnameAccount.domain
        accountDetailVC.mMyAccount = starnameAccount.name.value
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(accountDetailVC, animated: true)
    }
    
    func onFetchFinished() {
        self.myAccountCnt.text = String(myAccounts_gRPC.count)
        self.myAccountTableView.reloadData()
        self.myAccountTableView.isHidden = false
        self.refresher.endRefreshing()
        self.hideWaittingAlert()
    }

    @IBAction func onClickBuy(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_STARNAME_REGISTER_ACCOUNT
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @objc func onRequestFetch() {
        self.myAccounts_gRPC.removeAll()
        self.onFetchgRPCMyAccount(self.account!)
    }
    
    func onFetchgRPCMyAccount(_ account:Account) {
//        print("onFetchgRPCMyAccount ", account.account_address)
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
                let req = Starnamed_X_Starname_V1beta1_QueryOwnerAccountsRequest.with { $0.owner = account.account_address; $0.pagination = page }
                if let response = try? Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).ownerAccounts(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
//                    print("onFetchgRPCMyAccount response ", response)
                    response.accounts.forEach { rawAccount in
                        if (!rawAccount.name.value.isEmpty) {
                            self.myAccounts_gRPC.append(rawAccount)
                        }
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCMyAccount failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
