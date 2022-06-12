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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.selectedChain = WUtils.getChainType(account!.account_base_chain)
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self
        self.accountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.accountTableView.register(UINib(nibName: "SwitchAccountCell", bundle: nil), forCellReuseIdentifier: "SwitchAccountCell")
        
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
            let positionSection = self.chainAccounts.firstIndex(where: { $0.chainType == self.selectedChain }) ?? 0
            self.accountTableView.selectRow(at: IndexPath.init(item: 0, section: positionSection), animated: false, scrollPosition: .middle)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chainAccounts.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SwitchAccountHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.rootView.backgroundColor = WUtils.getChainBg(chainAccounts[section].chainType)
        view.chainImgView.image = WUtils.getChainImg(chainAccounts[section].chainType)
        view.chainNameLabel.text = WUtils.getChainTitle2(chainAccounts[section].chainType)
        view.chainAccountsCntLable.text = String(chainAccounts[section].accounts.count)
        view.actionTapHeader = {
            self.chainAccounts[section].opened = !self.chainAccounts[section].opened
            self.accountTableView.beginUpdates()
            self.accountTableView.reloadSections([section], with: .automatic)
            self.accountTableView.endUpdates()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = SwitchAccountFooter(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.rootView.backgroundColor = WUtils.getChainBg(chainAccounts[section].chainType)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (chainAccounts[section].opened) {
            return chainAccounts[section].accounts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchAccountCell") as! SwitchAccountCell
        cell.onBindChainAccounts(self.chainAccounts[indexPath.section], indexPath.row, self.account)
        cell.actionTapItem = {
            self.onSelectAccount(self.chainAccounts[indexPath.section].accounts[indexPath.row])
        }
        return cell
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
