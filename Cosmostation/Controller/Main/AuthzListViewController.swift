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
import Combine

class AuthzListViewController: BaseViewController {

    @IBOutlet weak var authzTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    private let store: Store = .init(reducer: AuthzReducers.granteeGrants, serviceLocator: AuthzServiceLocatorImpl())
    private var subscriptions: Set<AnyCancellable> = .init()
    private let refresher: UIRefreshControl = UIRefreshControl()
    private var granters = Array<String>()
    
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
        
        self.refresher.addTarget(self, action: #selector(startRefreshTask), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.authzTableView.addSubview(refresher)
        
        observeStateTask()
        startLoadTask()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_authz_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_authz_list", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func observeStateTask() {
        Task {
            await store.$state
                .sink { [weak self] in self?.endLoadTask($0) }
                .store(in: &subscriptions)
        }
    }
    
    private func startLoadTask() {
        guard let account = account else { return }
        Task {
            await store.dispatch(action: .load(granteeAddress: account.account_address))
        }
    }
    
    @objc private func startRefreshTask() {
        guard let account = account else { return }
        Task {
            await store.dispatch(action: .refresh(granteeAddress: account.account_address))
        }
    }
    
    private func endLoadTask(_ state: GranteeGrantsState) {
        loadingImg.animated = state.load.isLoading
        loadingImg.isHidden = !state.load.isLoading
        authzTableView.isHidden = state.load.isLoading
        refresher.animate(state.load.isRefreshing)
        granters = state.granters
        authzTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AuthzListViewController: UITableViewDelegate, UITableViewDataSource {

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
}

