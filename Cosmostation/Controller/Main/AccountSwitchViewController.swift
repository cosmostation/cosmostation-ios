//
//  AccountSwitchViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/10/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class AccountSwitchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var accountTableView: UITableView!
    
    var resultDelegate: AccountSwitchDelegate?
    var chainAccounts = Array<ChainAccounts>()
    var selectedChain: ChainType!
    var toAddChain: ChainType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.selectedChain = BaseData.instance.getRecentChain()
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self
        self.accountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.accountTableView.register(UINib(nibName: "ManageChainAccoutsCell", bundle: nil), forCellReuseIdentifier: "ManageChainAccoutsCell")
        
        let dismissTap1 = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.accountTableView.backgroundView?.addGestureRecognizer(dismissTap1)
        
        self.onRefechUserInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var expenedChains = Array<ChainType>()
        chainAccounts.forEach { chainAccount in
            if (chainAccount.opened) {
                expenedChains.append(chainAccount.chainType!)
            }
        }
        BaseData.instance.setExpendedChains(expenedChains)
    }
    
    @objc public func tableTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func onRefechUserInfo() {
        let displayChains = BaseData.instance.dpSortedChains()
        let expenedChains = BaseData.instance.getExpendedChains()
        displayChains.forEach { chain in
            if (expenedChains.contains(chain) || self.selectedChain == chain) {
                chainAccounts.append(ChainAccounts.init(opened: true, chainType: chain, accounts: BaseData.instance.selectAllAccountsByChain(chain)))
            } else {
                chainAccounts.append(ChainAccounts.init(opened: false, chainType: chain, accounts: BaseData.instance.selectAllAccountsByChain(chain)))
            }
        }
        self.accountTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            self.accountTableView.selectRow(at: IndexPath.init(item: self.chainAccounts.firstIndex(where: { $0.chainType ==  self.selectedChain }) ?? 0, section: 0), animated: false, scrollPosition: .middle)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chainAccounts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ManageChainAccoutsCell") as? ManageChainAccoutsCell
        cell?.onBindChainAccounts(self.chainAccounts[indexPath.row], self.account)
        cell?.actionSelect0 = { self.onSelectAccount(self.chainAccounts[indexPath.row].accounts[0]) }
        cell?.actionSelect1 = { self.onSelectAccount(self.chainAccounts[indexPath.row].accounts[1]) }
        cell?.actionSelect2 = { self.onSelectAccount(self.chainAccounts[indexPath.row].accounts[2]) }
        cell?.actionSelect3 = { self.onSelectAccount(self.chainAccounts[indexPath.row].accounts[3]) }
        cell?.actionSelect4 = { self.onSelectAccount(self.chainAccounts[indexPath.row].accounts[4]) }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chainAccounts[indexPath.row].opened = !self.chainAccounts[indexPath.row].opened
        self.accountTableView.reloadSections([indexPath.section], with: .automatic)
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func onSelectAccount(_ account: Account) {
        BaseData.instance.setRecentChain(WUtils.getChainType(account.account_base_chain)!)
        self.resultDelegate?.accountSelected(account.account_id)
        self.dismiss(animated: false, completion: nil)
    }
}

protocol AccountSwitchDelegate {
    func accountSelected (_ id: Int64)
    func addAccount(_ chain: ChainType)
}

struct ChainAccounts {
    var opened = false
    var chainType: ChainType?
    var accounts = Array<Account>()
}
