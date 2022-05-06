//
//  WalletDeriveViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletDeriveViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var selectedHDPathLabel: UILabel!
    @IBOutlet weak var derivedWalletTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.derivedWalletTableView.delegate = self
        self.derivedWalletTableView.dataSource = self
        self.derivedWalletTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.derivedWalletTableView.register(UINib(nibName: "DeriveWalletCell", bundle: nil), forCellReuseIdentifier: "DeriveWalletCell")
        self.derivedWalletTableView.rowHeight = UITableView.automaticDimension
        self.derivedWalletTableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeriveWalletCell") as? DeriveWalletCell
        return cell!
    }

    @IBAction func onClickDerive(_ sender: UIButton) {
    }
}
