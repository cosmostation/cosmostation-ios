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

class AuthzListViewController: BaseViewController {

    @IBOutlet weak var authzTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var rolSegmentedControl: UISegmentedControl!
    private let refresher: UIRefreshControl = UIRefreshControl()
    
    private var grants: [Cosmos_Authz_V1beta1_GrantAuthorization] = .init()
    private var granters: [Cosmos_Authz_V1beta1_GrantAuthorization] = .init()
    private var grantees: [Cosmos_Authz_V1beta1_GrantAuthorization] = .init()
    private var hasFetchedGranters: Bool = false
    private var hasFetchedGrantees: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.authzTableView.delegate = self
        self.authzTableView.dataSource = self
        self.authzTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.authzTableView.register(UINib(nibName: "GranterViewCell", bundle: nil), forCellReuseIdentifier: "GranterViewCell")
        self.authzTableView.register(UINib(nibName: "GranteeViewCell", bundle: nil), forCellReuseIdentifier: "GranteeViewCell")
        self.authzTableView.register(UINib(nibName: "GrantEmptyViewCell", bundle: nil), forCellReuseIdentifier: "GrantEmptyViewCell")
        self.authzTableView.rowHeight = UITableView.automaticDimension
        self.authzTableView.estimatedRowHeight = UITableView.automaticDimension
        self.authzTableView.isHidden = true
        
        self.refresher.addTarget(self, action: #selector(onRefreshAuthz), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.authzTableView.addSubview(refresher)
        
        self.rolSegmentedControl.addTarget(self, action: #selector(onSelectedRol), for: .valueChanged)
                
        self.onSelectedRol()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_authz_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_authz_list", comment: "")
    }
    
    @objc private func onRefreshAuthz() {
        onFetchGrants_gRPC(refresh: true)
    }
    
    @objc private func onSelectedRol() {
        onFetchGrants_gRPC(refresh: false)
    }
    
    private func onFetchGrants_gRPC(refresh: Bool) {
        guard let address = account?.account_address else { return }
        switch rolSegmentedControl.selectedSegmentIndex {
            case 0:
                onFetchGrantees_gRPC(address, refresh: refresh)
            case 1:
                onFetchGranters_gRPC(address, refresh: refresh)
            default: break
        }
    }
    
    private func onUpdateViews() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        self.refresher.endRefreshing()
        self.authzTableView.isHidden = false
        self.authzTableView.reloadData()
        self.rolSegmentedControl.isEnabled = true
    }
    
    private func onFetchGranters_gRPC(_ address: String, refresh: Bool) {
        rolSegmentedControl.isEnabled = false
        if refresh {
            hasFetchedGranters = false
        } else {
            loadingImg.onStartAnimation()
            loadingImg.isHidden = false
            grants = .init()
            authzTableView.reloadData()
        }
        if hasFetchedGranters {
            grants = granters
            onUpdateViews()
        } else {
            DispatchQueue.global().async {
                var granters: [Cosmos_Authz_V1beta1_GrantAuthorization] = .init()
                do {
                    let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    defer { try! channel.close().wait() }
                    let req = Cosmos_Authz_V1beta1_QueryGranteeGrantsRequest.with { $0.grantee = address }
                    if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).granteeGrants(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                        response.grants.forEach { grant in
                            if (!granters.map{ $0.granter }.contains(grant.granter)) {
                                granters.append(grant)
                            }
                        }
                    }
                    try channel.close().wait()
                } catch {
                    print("onFetchGrantee_gRPC failed: \(error)")
                }
                DispatchQueue.main.async(execute: {
                    self.hasFetchedGranters = true
                    self.granters = granters
                    self.grants = granters
                    self.onUpdateViews()
                });
            }
        }
    }
    
    private func onFetchGrantees_gRPC(_ address: String, refresh: Bool) {
        rolSegmentedControl.isEnabled = false
        if refresh {
            hasFetchedGrantees = false
        } else {
            loadingImg.onStartAnimation()
            loadingImg.isHidden = false
            grants = .init()
            authzTableView.reloadData()
        }
        if hasFetchedGrantees {
            grants = grantees
            onUpdateViews()
        } else {
            DispatchQueue.global().async {
                var grantees: [Cosmos_Authz_V1beta1_GrantAuthorization] = .init()
                do {
                    let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    defer { try! channel.close().wait() }
                    let req = Cosmos_Authz_V1beta1_QueryGranterGrantsRequest.with { $0.granter = address }
                    if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).granterGrants(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                        grantees = response.grants
                    }
                    try channel.close().wait()
                } catch {
                    print("onFetchGranter_gRPC failed: \(error)")
                }
                DispatchQueue.main.async(execute: {
                    self.hasFetchedGrantees = true
                    self.grantees = grantees
                    self.grants = grantees
                    self.onUpdateViews()
                });
            }
        }
    }
}

extension AuthzListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if grants.isEmpty && loadingImg.isHidden && !refresher.isRefreshing {
            return 1
        }
        return grants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (grants.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GrantEmptyViewCell") as? GrantEmptyViewCell
            cell?.rootCardView.backgroundColor = chainConfig?.chainColorBG
            return cell!
        } else if rolSegmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranteeViewCell") as! GranteeViewCell
            cell.onBindView(grants[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranterViewCell") as? GranterViewCell
            cell?.onBindView(chainConfig, grants[indexPath.row].granter)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard grants.count > 0 else { return }
        if rolSegmentedControl.selectedSegmentIndex == 1 {
            let authzDetailVC = AuthzDetailViewController(nibName: "AuthzDetailViewController", bundle: nil)
            authzDetailVC.granterAddress = grants[indexPath.row].granter
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(authzDetailVC, animated: true)
        }
    }
}
