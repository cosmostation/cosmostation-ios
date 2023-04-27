//
//  DaosListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class DaosListViewController: BaseViewController {
    
    @IBOutlet weak var daosListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension DaosListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
