//
//  AuthzGranterViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Combine

class AuthzGranterViewController: BaseViewController {
    
    @IBOutlet weak var granterTableView: UITableView!
    private let store: Store = .init(reducer: AuthzReducers.granteeGrants,
                                     serviceLocator: AuthzServiceLocatorImpl(),
                                     state: .init())
    private var subscriptions: Set<AnyCancellable> = .init()
    
    init() {
        super.init(nibName: "AuthzGranterViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.granterTableView.delegate = self
        self.granterTableView.dataSource = self
        self.granterTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.granterTableView.register(UINib(nibName: "GranterViewCell", bundle: nil), forCellReuseIdentifier: "GranterViewCell")
        self.granterTableView.register(UINib(nibName: "GranterEmptyViewCell", bundle: nil), forCellReuseIdentifier: "GranterEmptyViewCell")
        self.granterTableView.rowHeight = UITableView.automaticDimension
        self.granterTableView.estimatedRowHeight = UITableView.automaticDimension
        
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
        Task {
            await store.dispatch(action: .load)
        }
    }
    
    @objc private func startRefreshTask() {
        Task {
            await store.dispatch(action: .refresh)
        }
    }
    
    private func endLoadTask(_ state: GranteeGrantsState) {
        granterTableView.reloadData()
    }
}

extension AuthzGranterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (store.state.granters.count == 0) {
            return 1
        }
        return store.state.granters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chainConfig = store.state.chainConfig
        if (store.state.granters.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranterEmptyViewCell") as? GranterEmptyViewCell
            cell?.rootCardView.backgroundColor = chainConfig?.chainColorBG
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"GranterViewCell") as? GranterViewCell
            cell?.onBindView(chainConfig, store.state.granters[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (store.state.granters.count > 0) {
            let authzDetailVC = AuthzDetailViewController(nibName: "AuthzDetailViewController", bundle: nil)
            authzDetailVC.granterAddress = store.state.granters[indexPath.row]
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(authzDetailVC, animated: true)
        }
    }
}
