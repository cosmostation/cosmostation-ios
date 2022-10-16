//
//  OtherValidatorViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 20/05/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class OtherValidatorViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var otherValidatorTableView: UITableView!
    @IBOutlet weak var otherValidatorLabel: UILabel!
    @IBOutlet weak var otherValidatorCnt: UILabel!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.otherValidatorTableView.delegate = self
        self.otherValidatorTableView.dataSource = self
        self.otherValidatorTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.otherValidatorTableView.register(UINib(nibName: "OtherValidatorCell", bundle: nil), forCellReuseIdentifier: "OtherValidatorCell")
        self.otherValidatorTableView.rowHeight = UITableView.automaticDimension
        self.otherValidatorTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.otherValidatorTableView.addSubview(refresher)
        
        self.otherValidatorLabel.text = NSLocalizedString("str_validators", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTabVC = ((self.parent)?.parent)?.parent as? MainTabViewController
        self.onSorting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSorting), name: Notification.Name("onSorting"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onSorting"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.onSorting()
        self.refresher.endRefreshing()
    }
    
    @objc func onSorting() {
        self.otherValidatorCnt.text = String(BaseData.instance.mUnbondValidators_gRPC.count)
        self.sortByPower()
        self.otherValidatorTableView.reloadData()
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BaseData.instance.mUnbondValidators_gRPC.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"OtherValidatorCell") as? OtherValidatorCell
        if (BaseData.instance.mUnbondValidators_gRPC.count > 0) {
            cell?.updateView(BaseData.instance.mUnbondValidators_gRPC[indexPath.row], self.chainConfig)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let validatorDetailVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VaildatorDetailViewController") as! VaildatorDetailViewController
        validatorDetailVC.mValidator_gRPC = BaseData.instance.mUnbondValidators_gRPC[indexPath.row]
        validatorDetailVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(validatorDetailVC, animated: true)
    }
    
    func sortByPower() {
        BaseData.instance.mUnbondValidators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return Double($0.tokens)! > Double($1.tokens)!
        }
    }
}
