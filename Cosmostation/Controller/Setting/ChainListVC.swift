//
//  ChainListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class ChainListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addChainBtn: BaseButton!
    
    var allCosmosChains = [CosmosClass]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ManageChainCell", bundle: nil), forCellReuseIdentifier: "ManageChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onUpdateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isHidden = false
        addChainBtn.isHidden = false
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("setting_chain_title", comment: "")
        addChainBtn.setTitle(NSLocalizedString("str_add_custom_chain", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        allCosmosChains.removeAll()
        ALLCOSMOSCLASS().forEach { chain in
            allCosmosChains.append(chain)
        }
        tableView.reloadData()
    }

    @IBAction func onClickAddChain(_ sender: UIButton) {
    }

}

extension ChainListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCosmosChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ManageChainCell") as! ManageChainCell
        cell.bindCosmosClassChain(allCosmosChains[indexPath.row])
        return cell
    }
}
