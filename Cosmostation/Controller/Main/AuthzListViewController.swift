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
    @IBOutlet weak var authzEmptyView: UILabel!
    @IBOutlet weak var loadingImg: LoadingImageView!
    var refresher: UIRefreshControl!
    
    var authorizations = Array<Cosmos_Authz_V1beta1_GrantAuthorization>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.authzTableView.delegate = self
        self.authzTableView.dataSource = self
        self.authzTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.authzTableView.register(UINib(nibName: "ProposalVotingPeriodCell", bundle: nil), forCellReuseIdentifier: "ProposalVotingPeriodCell")
        self.authzTableView.rowHeight = UITableView.automaticDimension
        self.authzTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchAuthz), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.authzTableView.addSubview(refresher)
        
        self.loadingImg.onStartAnimation()
        self.onFetchAuthz()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_authz_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_authz_list", comment: "")
    }
    
    @objc func onFetchAuthz() {
//        self.mVotingPeriods.removeAll()
//        self.mEtcPeriods.removeAll()
        self.onFetchGranter_gRPC(account!.account_address)
    }
    
    func onUpdateViews() {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ProposalVotingPeriodCell") as? ProposalVotingPeriodCell
        return cell!
    }
    
    
    func onFetchGranter_gRPC(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                defer { try! channel.close().wait() }
                
                let req = Cosmos_Authz_V1beta1_QueryGranteeGrantsRequest.with { $0.grantee = address }
                if let response = try? Cosmos_Authz_V1beta1_QueryClient(channel: channel).granteeGrants(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    print("response", response.grants.count)
                    self.authorizations = response.grants
                }
                try channel.close().wait()

            } catch {
                print("onFetchGranter_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onUpdateViews() });
        }
    }
}
