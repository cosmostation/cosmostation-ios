//
//  MajorReceiveVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class MajorReceiveVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!

    var selectedChain: BaseChain!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ReceiveCell", bundle: nil), forCellReuseIdentifier: "ReceiveCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        setFooterView()
    }
    
    func setFooterView() {
        let footerLabel = UILabel()
        footerLabel.text = "Powered by COSMOSTATION"
        footerLabel.textColor = .color04
        footerLabel.font = .fontSize11Medium
        footerLabel.textAlignment = .center
        footerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20)
        
        tableView.tableFooterView = footerLabel
    }
}

extension MajorReceiveVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = "My Address"
        view.cntLabel.text = ""
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ReceiveCell") as! ReceiveCell
        cell.bindReceive(baseAccount, selectedChain, indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var toCopyAddress = ""
        if !selectedChain.mainAddress.isEmpty {
            toCopyAddress = selectedChain.mainAddress
        }
        
        UIPasteboard.general.string = toCopyAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.onShowToast(NSLocalizedString("address_copied", comment: ""))
    }
}
