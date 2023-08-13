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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        
        
        navigationItem.leftBarButtonItem = leftBarButton("AAA")
        
        initData()
    }
    
    func initData() {
        let account = BaseData.instance.getLastAccount()
        print("account ", account)
        account?.setPrivateKeys()
        
        
        
        navigationItem.leftBarButtonItem = leftBarButton(account?.name)
    }

}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell")
        return cell!
    }
}
