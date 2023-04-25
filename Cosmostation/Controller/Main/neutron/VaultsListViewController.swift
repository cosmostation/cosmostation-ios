//
//  VaultsListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class VaultsListViewController: BaseViewController {

    @IBOutlet weak var vaultsListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.vaultsListTableView.delegate = self
        self.vaultsListTableView.dataSource = self
        self.vaultsListTableView.register(UINib(nibName: "MainVaultCell", bundle: nil), forCellReuseIdentifier: "MainVaultCell")
        self.vaultsListTableView.register(UINib(nibName: "SubVaultCell", bundle: nil), forCellReuseIdentifier: "SubVaultCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_vaults_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_vaults_list", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func onCheckDeposit(_ position: Int) {
        //TODO fee check
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_NEUTRON_VAULTE_DEPOSIT
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCheckWithdraw(_ position: Int) {
        //TODO validate check
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_NEUTRON_VAULTE_WITHDRAW
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }

}

extension VaultsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BaseData.instance.mNeutronVaults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"MainVaultCell") as? MainVaultCell
            cell?.onBindView(chainConfig!, indexPath.row)
            cell?.actionDeposit = { self.onCheckDeposit(indexPath.row) }
            cell?.actionWithdraw = { self.onCheckWithdraw(indexPath.row) }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SubVaultCell") as? SubVaultCell
            return cell!
        }
    }
    
    
}
