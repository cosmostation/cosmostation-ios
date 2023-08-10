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
        
//        self.navigationController?.hidesBarsOnSwipe = true
//        print("PortfolioVC ", self.navigationController?.hidesBarsOnSwipe)
//        self.navigationController?.navigationBar.tintColor = .white
//        self.navigationController?.title = "Hello"
//        self.navigationItem.title = "asdasd"
//        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)]
//        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)]
//        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
