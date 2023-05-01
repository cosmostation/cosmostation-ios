//
//  NeuDaosListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class NeuDaosListViewController: BaseViewController {
    
    @IBOutlet weak var daosListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.daosListTableView.delegate = self
        self.daosListTableView.dataSource = self
        self.daosListTableView.register(UINib(nibName: "MainDaoCell", bundle: nil), forCellReuseIdentifier: "MainDaoCell")
        self.daosListTableView.register(UINib(nibName: "SubDaoCell", bundle: nil), forCellReuseIdentifier: "SubDaoCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_daos_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_daos_list", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}


extension NeuDaosListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BaseData.instance.mNeutronDaos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"MainDaoCell") as? MainDaoCell
            cell?.onBindView(chainConfig!, indexPath.row)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SubDaoCell") as? SubDaoCell
            cell?.onBindView(chainConfig!, indexPath.row)
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let proposalListVC = NeuProposalListViewController(nibName: "NeuProposalListViewController", bundle: nil)
        proposalListVC.neutronDao = BaseData.instance.mNeutronDaos[indexPath.row]
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(proposalListVC, animated: true)
        return
    }
}
