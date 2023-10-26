//
//  CosmosAboutVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class CosmosAboutVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedChain: CosmosClass!
    var chainParam: JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AboutDescriptionCell", bundle: nil), forCellReuseIdentifier: "AboutDescriptionCell")
        tableView.register(UINib(nibName: "AboutStakingCell", bundle: nil), forCellReuseIdentifier: "AboutStakingCell")
        tableView.register(UINib(nibName: "AboutRewardAddressCell", bundle: nil), forCellReuseIdentifier: "AboutRewardAddressCell")
        tableView.register(UINib(nibName: "AboutSocialsCell", bundle: nil), forCellReuseIdentifier: "AboutSocialsCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        chainParam = selectedChain.mintscanChainParam
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchStakeDone(_:)), name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchStakeData"), object: nil)
    }
    
    @objc func onFetchStakeDone(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
            self.tableView.endUpdates()
        }
    }
}


extension CosmosAboutVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Description"
            view.cntLabel.text = ""
            
        } else if (section == 1) {
            view.titleLabel.text = "Staking Information"
            view.cntLabel.text = ""
            
        } else if (section == 2) {
            view.titleLabel.text = "Reward Address"
            view.cntLabel.text = ""
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 3) { return 0 }
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutDescriptionCell") as! AboutDescriptionCell
            let description = chainParam["params"]["chainlist_params"]["description"]
            cell.onBindDescription(selectedChain, description)
            return cell
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutStakingCell") as! AboutStakingCell
            cell.onBindStakingInfo(selectedChain, chainParam)
            return cell
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutRewardAddressCell") as! AboutRewardAddressCell
            cell.onBindStakingInfo(selectedChain)
            return cell
            
        } else if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutSocialsCell") as! AboutSocialsCell
            cell.vc = self
            cell.onBindSocial(selectedChain, chainParam)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2) {
            if (!selectedChain.rewardAddress.isEmpty) {
                UIPasteboard.general.string = selectedChain.rewardAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
        }
    }
}
