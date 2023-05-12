//
//  NeuVaultsListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class NeuVaultsListViewController: BaseViewController {

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
        
        let explorerBtn = UIButton(type: .system)
        explorerBtn.setImage(UIImage(named: "btnExplorer"), for: .normal)
        explorerBtn.sizeToFit()
        explorerBtn.addTarget(self, action: #selector(onExplorer(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: explorerBtn)
    }
    
    @objc func onExplorer(_ button: UIButton) {
        let link = chainConfig!.explorerUrl + "dao/vault"
        guard let url = URL(string: link) else { return }
        onShowSafariWeb(url)
    }
    
    func onCheckDeposit(_ position: Int) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (BaseData.instance.getAvailableAmount_gRPC(chainConfig!.stakeDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_available", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.neutronVault = BaseData.instance.mNeutronVaults[position]
        txVC.mType = TASK_TYPE_NEUTRON_VAULTE_DEPOSIT
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onCheckWithdraw(_ position: Int) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (BaseData.instance.mNeutronVaultDeposit.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_to_withdraw", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.neutronVault = BaseData.instance.mNeutronVaults[position]
        txVC.mType = TASK_TYPE_NEUTRON_VAULTE_WITHDRAW
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }

}

extension NeuVaultsListViewController: UITableViewDelegate, UITableViewDataSource {
    
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
