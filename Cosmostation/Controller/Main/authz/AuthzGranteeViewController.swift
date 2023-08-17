//
//  AuthzGranteeViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AuthzGranteeViewController: BaseViewController {

    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var granteeTableView: UITableView!
    
    var mGrants = Array<(Bool, Cosmos_Authz_V1beta1_GrantAuthorization)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.granteeTableView.delegate = self
        self.granteeTableView.dataSource = self
        self.granteeTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.granteeTableView.register(UINib(nibName: "GranteeViewCell", bundle: nil), forCellReuseIdentifier: "GranteeViewCell")
        self.granteeTableView.register(UINib(nibName: "GranterEmptyViewCell", bundle: nil), forCellReuseIdentifier: "GranterEmptyViewCell")
        self.granteeTableView.rowHeight = UITableView.automaticDimension
        self.granteeTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.loadingImg.onStartAnimation()
        onFetchGranteeData()
    }
    
    func updateView() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        self.granteeTableView.isHidden = false
        self.granteeTableView.reloadData()
    }
    
    @IBAction func onClickRevoke(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        if (self.mGrants.filter({ $0.0 == true }).count <= 0 ) {
            self.onShowToast(NSLocalizedString("error_no_selected_grant", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_AUTHZ_REVOKE
        self.mGrants.forEach { (isSelected, grant) in
            if (isSelected == true) {
                txVC.mGrantees.append(grant)
            }
        }
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onFetchGranteeData() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Cosmos_Authz_V1beta1_QueryGranterGrantsRequest.with { $0.granter = self.account!.account_address }
                if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).granterGrants(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    let now = Date().millisecondsSince1970
                    response.grants.forEach { grant in
                        if (grant.expiration.seconds * 1000 >= now) {
                            self.mGrants.append((false, grant))
                        }
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchGranteeData failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.updateView() });
        }
    }
}

extension AuthzGranteeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.mGrants.count == 0) {
            return 1
        }
        return self.mGrants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.mGrants.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranterEmptyViewCell") as? GranterEmptyViewCell
            cell?.rootCardView.backgroundColor = chainConfig?.chainColorBG
            cell?.emptyGrantLabel.text = NSLocalizedString("msg_grantee_empty", comment: "")
            cell?.emptyGrantMsgLabel.text = NSLocalizedString("msg_grant_empty_msg", comment: "")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranteeViewCell") as? GranteeViewCell
            cell?.onBindView(mGrants[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.mGrants.count == 0) {
            return
        }
        self.mGrants[indexPath.row].0.toggle()
        self.granteeTableView.reloadRows(at: [indexPath], with: .none)
    }
}
