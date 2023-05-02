//
//  NeuProposalListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NeuProposalListViewController: BaseViewController {
    
    @IBOutlet weak var proposalListTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var refresher: UIRefreshControl!
    
    var neutronDao: NeutronDao!
    var neutronProposals = Array<(String, [JSON])>()
    var fetchCnt = 0
    var isShowAll = false
    var btnShowAll: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.proposalListTableView.delegate = self
        self.proposalListTableView.dataSource = self
        self.proposalListTableView.register(UINib(nibName: "DaoProposalCell", bundle: nil), forCellReuseIdentifier: "DaoProposalCell")
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.proposalListTableView.addSubview(refresher)
        
        self.onRequestFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_daos_proposal_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_daos_proposal_list", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let showAllBtn = UIButton(type: .system)
        if (isShowAll) { showAllBtn.setImage(UIImage(named: "iconCheckBox"), for: .normal) }
        else { showAllBtn.setImage(UIImage(named: "iconUnCheckedBox"), for: .normal) }
        showAllBtn.setTitle("Show All", for: .normal)
        showAllBtn.titleLabel?.font = Font_13_footnote
        showAllBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        showAllBtn.sizeToFit()
        showAllBtn.addTarget(self, action: #selector(onToggleShow(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: showAllBtn)
    }
    
    @objc func onToggleShow(_ button: UIButton) {
        isShowAll = !isShowAll
        if (isShowAll) { button.setImage(UIImage(named: "iconCheckBox"), for: .normal) }
        else { button.setImage(UIImage(named: "iconUnCheckedBox"), for: .normal) }
    }
    
    func onFetchFinished() {
        fetchCnt = fetchCnt - 1
        if (fetchCnt <= 0) {
            refresher.endRefreshing()
            proposalListTableView.reloadData()
            if let _ = neutronProposals.filter({ $0.1.count > 0 }).first {
                emptyView.isHidden = true
            } else {
                emptyView.isHidden = false
            }
        }
    }
    
    @objc func onRequestFetch() {
        fetchCnt = neutronDao.proposal_modules.count
        neutronDao.proposal_modules.forEach { module in
            self.onFetchProposalList(module.address!)
        }
    }
    
    func onFetchProposalList(_ contAddress: String) {
        neutronProposals.removeAll()
        DispatchQueue.global().async {
            do {
                let query: JSON = ["reverse_proposals" : JSON()]
                let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
                
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = contAddress
                    $0.queryData = Data(base64Encoded: queryBase64)!
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if let result = try? JSONDecoder().decode(JSON.self, from: response.data) {
                        self.neutronProposals.append((contAddress, result["proposals"].arrayValue))
                    }
                }
                try channel.close().wait()

            } catch {
                print("onFetchProposalList failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }

}


extension NeuProposalListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return neutronDao.proposal_modules.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let proposalModule = neutronDao.proposal_modules[section]
        if let proposals = neutronProposals.filter({ $0.0 == proposalModule.address }).first {
            if (proposals.1.count > 0) { return 30 }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let proposalModule = neutronDao.proposal_modules[section]
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if let proposals = neutronProposals.filter({ $0.0 == proposalModule.address }).first {
            view.headerTitleLabel.text = proposalModule.name
            view.headerCntLabel.text = String(proposals.1.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let proposalModule = neutronDao.proposal_modules[section]
        if let proposals = neutronProposals.filter({ $0.0 == proposalModule.address }).first {
            return proposals.1.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DaoProposalCell") as? DaoProposalCell
        let proposalModule = neutronDao.proposal_modules[indexPath.section]
        if let proposals = neutronProposals.filter({ $0.0 == proposalModule.address }).first {
            cell?.onBindView(proposalModule, proposals.1[indexPath.row])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let proposalModule = neutronDao.proposal_modules[indexPath.section]
        if let proposals = neutronProposals.filter({ $0.0 == proposalModule.address }).first {
            let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            txVC.neutronProposalModule = proposalModule
            txVC.neutronProposal = proposals.1[indexPath.row]
            if (proposalModule.prefix == "A") {
                txVC.mType = TASK_TYPE_NEUTRON_VOTE_SINGLE
            } else if (proposalModule.prefix == "B") {
                txVC.mType = TASK_TYPE_NEUTRON_VOTE_MULTI
            } else if (proposalModule.prefix == "C") {
                txVC.mType = TASK_TYPE_NEUTRON_VOTE_OVERRULE
            }
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(txVC, animated: true)
        }
    }
}
