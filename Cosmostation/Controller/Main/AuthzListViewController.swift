//
//  AuthzListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var authzTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    var refresher: UIRefreshControl!
    var granters = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.authzTableView.delegate = self
        self.authzTableView.dataSource = self
        self.authzTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.authzTableView.register(UINib(nibName: "GranterViewCell", bundle: nil), forCellReuseIdentifier: "GranterViewCell")
        self.authzTableView.register(UINib(nibName: "GranterEmptyViewCell", bundle: nil), forCellReuseIdentifier: "GranterEmptyViewCell")
        self.authzTableView.rowHeight = UITableView.automaticDimension
        self.authzTableView.estimatedRowHeight = UITableView.automaticDimension
        self.authzTableView.isHidden = true
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchAuthz), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.authzTableView.addSubview(refresher)
        
        self.loadingImg.onStartAnimation()
        self.onFetchAuthz()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_authz_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_authz_list", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func onFetchAuthz() {
        self.onFetchGranter_gRPC(account!.account_address)
    }
    
    func onUpdateViews() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        self.authzTableView.isHidden = false
        self.authzTableView.reloadData()
        self.refresher.endRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (granters.count == 0) {
            return 1
        }
        return granters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (granters.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranterEmptyViewCell") as? GranterEmptyViewCell
            cell?.rootCardView.backgroundColor = chainConfig?.chainColorBG
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranterViewCell") as? GranterViewCell
            cell?.onBindView(chainConfig, granters[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (granters.count > 0) {
            let authzDetailVC = AuthzDetailViewController(nibName: "AuthzDetailViewController", bundle: nil)
            authzDetailVC.granterAddress = granters[indexPath.row]
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(authzDetailVC, animated: true)
        }
    }
    
    func onFetchGranter_gRPC(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                defer { try! channel.close().wait() }
                let req = Cosmos_Authz_V1beta1_QueryGranteeGrantsRequest.with { $0.grantee = address }
                if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).granteeGrants(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    response.grants.forEach { grant in
                        if (!self.granters.contains(grant.granter)) {
                            self.granters.append(grant.granter)
                        }
                    }
                }
                try channel.close().wait()

            } catch {
                print("onFetchGranter_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onUpdateViews() });
        }
    }
}
