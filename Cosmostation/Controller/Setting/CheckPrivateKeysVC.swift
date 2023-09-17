//
//  CheckPrivateKeysVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CheckPrivateKeysVC: BaseVC {
    
    @IBOutlet weak var nameCardView: CardView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastPathLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkBtn: BaseButton!
    
    var toCheckAccount: BaseAccount!
    var allCosmosChain = [CosmosClass]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CheckPrivateKeyCell", bundle: nil), forCellReuseIdentifier: "CheckPrivateKeyCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0

        onUpdateView()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("str_check_each_private_keys", comment: "")
        checkBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        nameLabel.text = toCheckAccount.name
        if (toCheckAccount.lastHDPath != "0") {
            lastPathLabel.text = "Last HD Path : " + toCheckAccount.lastHDPath
            lastPathLabel.isHidden = false
        }
        
        Task {
            allCosmosChain = await toCheckAccount.initOnyKeyData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CheckPrivateKeysVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCosmosChain.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CheckPrivateKeyCell") as! CheckPrivateKeyCell
        cell.bindCosmosClassPrivateKey(toCheckAccount, allCosmosChain[indexPath.row])
        return cell
    }
    
}
