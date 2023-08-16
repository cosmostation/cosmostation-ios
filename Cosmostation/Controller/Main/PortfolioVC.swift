//
//  PortfolioVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PortfolioVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)),
                                               name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"),
                                                  object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let getValue = notification.object as! String
        print("onFetchDone ", getValue)
    }
    
    func initData() {
        let account = BaseData.instance.getLastAccount()
        print("account ", account)
        account?.setAddressInfo()
        
        navigationItem.leftBarButtonItem = leftBarButton(account?.name)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(clickSearch))
    }
    
    @objc func clickSearch() {
        print("clickSearch")
        self.navigationItem.searchController = self.searchController
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
            self.searchController.searchBar.becomeFirstResponder()
        })
        self.searchController.searchBar.delegate = self
    }

}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell")
        return cell!
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar ", searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        UIView.animate(withDuration: 0.05, animations: {
            self.navigationItem.searchController?.isActive = false
            self.navigationItem.searchController = nil
        })
    }
}
