//
//  DomainDetailViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/28.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class DomainDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myDomainLabel: UILabel!
    @IBOutlet weak var myDomainType: UILabel!
    @IBOutlet weak var myDomainAddressCntLael: UILabel!
    @IBOutlet weak var myDomainExpireTimeLabel: UILabel!
    @IBOutlet weak var myDomainResourceTableView: UITableView!
    @IBOutlet weak var myDomainEmptyView: UIView!
    
    var mMyDomain: String?
    var mMyDomainInfo_gRPC: Starnamed_X_Starname_V1beta1_Domain?
    var mMyDomainResolve_gRPC: Starnamed_X_Starname_V1beta1_QueryStarnameResponse?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.balances = account!.account_balances
        
        self.myDomainResourceTableView.delegate = self
        self.myDomainResourceTableView.dataSource = self
        self.myDomainResourceTableView.register(UINib(nibName: "ResourceCell", bundle: nil), forCellReuseIdentifier: "ResourceCell")
        self.myDomainResourceTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.myDomainResourceTableView.rowHeight = UITableView.automaticDimension
        self.myDomainResourceTableView.estimatedRowHeight = UITableView.automaticDimension
        self.myDomainEmptyView.isHidden = true
        
        myDomainLabel.text = "*" + mMyDomain!
        self.onFetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_starname_domain_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_starname_domain_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mMyDomainResolve_gRPC?.account.resources.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ResourceCell? = tableView.dequeueReusableCell(withIdentifier:"ResourceCell") as? ResourceCell
        let resource = mMyDomainResolve_gRPC?.account.resources[indexPath.row]
        cell?.chainImg.af_setImage(withURL: getStarNameChainImgUrl(resource?.uri))
        cell?.chainName.text = getStarNameChainName(resource?.uri)
        cell?.chainAddress.text = resource?.resource
        return cell!
    }

    @IBAction func onClickDelete(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (mMyDomainInfo_gRPC?.type == "open") {
            self.onShowToast(NSLocalizedString("error_cannot_delete_open_domain", comment: ""))
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_STARNAME_DELETE_DOMAIN
        txVC.mStarnameDomain = mMyDomain
        txVC.mStarnameTime = mMyDomainInfo_gRPC?.validUntil
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @IBAction func onClickRenew(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let userAvailable = BaseData.instance.getAvailableAmount_gRPC(chainConfig!.stakeDenom)
        let starnameFee = WUtils.getStarNameRenewDomainFee(mMyDomain!, mMyDomainInfo_gRPC!.type)
        if (userAvailable.compare(starnameFee).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_starname_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_STARNAME_RENEW_DOMAIN
        txVC.mStarnameDomain = mMyDomain
        txVC.mStarnameTime = mMyDomainInfo_gRPC?.validUntil
        txVC.mStarnameDomainType = mMyDomainInfo_gRPC?.type
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @IBAction func onClickReplace(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let userAvailable = BaseData.instance.getAvailableAmount_gRPC(chainConfig!.stakeDenom)
        let starnameFee = WUtils.getReplaceFee()
        if (userAvailable.compare(starnameFee).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_starname_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_STARNAME_REPLACE_RESOURCE
        txVC.mStarnameDomain = mMyDomain
        txVC.mStarnameTime = mMyDomainInfo_gRPC?.validUntil
        txVC.mStarnameDomainType = mMyDomainInfo_gRPC?.type
        txVC.mStarnameResources_gRPC = mMyDomainResolve_gRPC?.account.resources ?? Array<Starnamed_X_Starname_V1beta1_Resource>()
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @IBAction func onClickProfile(_ sender: UIButton) {
        guard let url = URL(string: "https://starname.me/" + "*" + mMyDomain!) else { return }
        self.onShowSafariWeb(url)
    }
    
    var mFetchCnt = 0
    @objc func onFetchData() {
        if (self.mFetchCnt > 0)  {
            return
        }
        self.mFetchCnt = 2
        self.onFetchgRPCDomainInfo(mMyDomain!)
        self.onFetchgRPCResolve(mMyDomain!)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            if (mMyDomainResolve_gRPC?.hasAccount ?? false &&  mMyDomainResolve_gRPC?.account.resources.count ?? 0 > 0) {
                self.myDomainResourceTableView.reloadData()
                self.myDomainEmptyView.isHidden = true
                self.myDomainAddressCntLael.text = String(mMyDomainResolve_gRPC!.account.resources.count)
            } else {
                self.myDomainResourceTableView.isHidden = true
                self.myDomainEmptyView.isHidden = false
                self.myDomainAddressCntLael.text = "0"
            }
            let expireTime = mMyDomainInfo_gRPC!.validUntil * 1000
            myDomainExpireTimeLabel.text = WDP.dpTime(expireTime)
            
            myDomainType.text = mMyDomainInfo_gRPC?.type.uppercased()
            if (mMyDomainInfo_gRPC?.type == "open") {
                myDomainType.textColor = UIColor.init(named: "starname")
            } else {
                myDomainType.textColor = UIColor.init(named: "_font05")
            }
        }
    }
    
    func onFetchgRPCDomainInfo(_ domain: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Starname_V1beta1_QueryDomainRequest.with { $0.name = domain }
                if let response = try? Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).domain(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    print("onFetchDomainInfo_gRPC ", domain, " ", response)
                    self.mMyDomainInfo_gRPC = response.domain
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchDomainInfo_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCResolve(_ starname: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Starname_V1beta1_QueryStarnameRequest.with { $0.starname = "*" + starname }
                if let response = try? Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).starname(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    print("onFetchgRPCResolve ", starname, " ", response)
                    self.mMyDomainResolve_gRPC = response
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCResolve failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}
