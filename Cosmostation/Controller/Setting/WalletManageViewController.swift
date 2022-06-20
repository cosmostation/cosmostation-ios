//
//  WalletManageViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 03/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class WalletManageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chainTableView: UITableView!
    @IBOutlet weak var accountTableView: UITableView!
    
    var displayChains = Array<ChainType>()
    var displayAccounts = Array<Account>()
    var selectedChain: ChainType!
    var toAddChain: ChainType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self
        self.accountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.accountTableView.register(UINib(nibName: "ManageAccountCell", bundle: nil), forCellReuseIdentifier: "ManageAccountCell")
        
        self.chainTableView.delegate = self
        self.chainTableView.dataSource = self
        self.chainTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.chainTableView.register(UINib(nibName: "ManageChainCell", bundle: nil), forCellReuseIdentifier: "ManageChainCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_wallet_manage", comment: "");
        self.navigationItem.title = NSLocalizedString("title_wallet_manage", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(onStartEdit))
        
        self.displayChains = BaseData.instance.dpSortedChains()
        self.selectedChain = BaseData.instance.getRecentChain()
        self.onRefechUserInfo()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.chainTableView.selectRow(at: IndexPath.init(item: self.displayChains.firstIndex(of: self.selectedChain) ?? 0, section: 0), animated: false, scrollPosition: .middle)
        })
    }
    
    @objc public func onStartEdit() {
        let walletEditVC = WalletChainEditViewController(nibName: "WalletChainEditViewController", bundle: nil)
        walletEditVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(walletEditVC, animated: true)
    }
    
    func onRefechUserInfo() {
        self.displayAccounts = BaseData.instance.selectAllAccountsByChain(selectedChain)
        self.sortWallet()
        self.chainTableView.reloadData()
        self.accountTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == chainTableView) {
            return displayChains.count
        } else if (tableView == accountTableView) {
            return displayAccounts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == chainTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"ManageChainCell") as? ManageChainCell
            let selected = displayChains[indexPath.row]
            guard let selectedConfig = ChainFactory().getChainConfig(selected) else {
                return cell!
            }
            cell?.chainImg.image = selectedConfig.chainImg
            cell?.chainName.text = selectedConfig.chainTitle2
            cell?.chainName.adjustsFontSizeToFitWidth = true
            if (selected == selectedChain) { cell?.onSetView(true) }
            else { cell?.onSetView(false) }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"ManageAccountCell") as? ManageAccountCell
            let account = displayAccounts[indexPath.row]
            let userChain = WUtils.getChainType(account.account_base_chain)
            guard let userChainConfig = ChainFactory().getChainConfig(userChain) else {
                return cell!
            }
            if (account.account_has_private) {
                cell?.keyImg.image = cell?.keyImg.image!.withRenderingMode(.alwaysTemplate)
                cell?.keyImg.tintColor = userChainConfig.chainColor
            } else {
                cell?.keyImg.tintColor = UIColor.init(named: "_font05")
            }
            cell?.nameLabel.text = account.getDpName()
            cell?.address.text = account.account_address
            WUtils.showCoinDp(userChainConfig.stakeDenom, account.account_last_total, cell!.amountDenom, cell!.amount, userChainConfig.chainType)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == chainTableView ) {
            selectedChain = displayChains[indexPath.row]
            self.onRefechUserInfo()
            
        } else if (tableView == accountTableView) {
            let walletDetailVC = WalletDetailViewController(nibName: "WalletDetailViewController", bundle: nil)
            walletDetailVC.hidesBottomBarWhenPushed = true
            walletDetailVC.selectedAccount = self.displayAccounts[indexPath.row]
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(walletDetailVC, animated: true)
        }
    }
    
    func sortWallet() {
        self.displayAccounts.sort{
            return $0.account_sort_order < $1.account_sort_order
        }
    }
    
}
