//
//  AllValidatorViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class AllValidatorViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allValidatorTableView: UITableView!
    @IBOutlet weak var allValidatorLabel: UILabel!
    @IBOutlet weak var allValidatorCnt: UILabel!
    @IBOutlet weak var btnSort: UIView!
    @IBOutlet weak var sortType: UILabel!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
                
        self.allValidatorTableView.delegate = self
        self.allValidatorTableView.dataSource = self
        self.allValidatorTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.allValidatorTableView.register(UINib(nibName: "AllValidatorCell", bundle: nil), forCellReuseIdentifier: "AllValidatorCell")
        self.allValidatorTableView.rowHeight = UITableView.automaticDimension
        self.allValidatorTableView.estimatedRowHeight = UITableView.automaticDimension
    
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.allValidatorTableView.addSubview(refresher)
        
        self.allValidatorLabel.text = NSLocalizedString("str_validators", comment: "")
        let tap = UITapGestureRecognizer(target: self, action: #selector(onStartSort))
        self.btnSort.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTabVC = ((self.parent)?.parent)?.parent as? MainTabViewController
        self.onSorting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.onSorting()
        self.refresher.endRefreshing()
    }
    
    @objc func onSorting() {
        self.allValidatorCnt.text = String(BaseData.instance.mBondedValidators_gRPC.count)
        if (BaseData.instance.getAllValidatorSort() == 0) {
            self.sortType.text = NSLocalizedString("sort_by_power", comment: "")
            sortByPower()
        } else if (BaseData.instance.getAllValidatorSort() == 1) {
            self.sortType.text = NSLocalizedString("sort_by_name", comment: "")
            sortByName()
        } else {
            self.sortType.text = NSLocalizedString("sort_by_yield", comment: "")
            sortByCommission()
        }
        self.allValidatorTableView.reloadData()
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BaseData.instance.mBondedValidators_gRPC.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AllValidatorCell") as? AllValidatorCell
        if (BaseData.instance.mBondedValidators_gRPC.count > 0) {
            cell?.updateView(BaseData.instance.mBondedValidators_gRPC[indexPath.row], self.chainConfig)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let validatorDetailVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VaildatorDetailViewController") as! VaildatorDetailViewController
        validatorDetailVC.mValidator_gRPC = BaseData.instance.mBondedValidators_gRPC[indexPath.row]
        validatorDetailVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(validatorDetailVC, animated: true)
    }
    
    @objc func onStartSort() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sort_by_name", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            BaseData.instance.setAllValidatorSort(1)
            self.onSorting()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sort_by_power", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            BaseData.instance.setAllValidatorSort(0)
            self.onSorting()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sort_by_yield", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            BaseData.instance.setAllValidatorSort(2)
            self.onSorting()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sortByName() {
        BaseData.instance.mBondedValidators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return $0.description_p.moniker < $1.description_p.moniker
        }
    }
    
    func sortByPower() {
        BaseData.instance.mBondedValidators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return Double($0.tokens)! > Double($1.tokens)!
        }
    }
    
    func sortByCommission() {
        BaseData.instance.mBondedValidators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return Double($0.commission.commissionRates.rate)! < Double($1.commission.commissionRates.rate)!
        }
    }

}
