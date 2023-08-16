//
//  AuthzRevoke1ViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AuthzRevoke1ViewController: BaseViewController {
    
    @IBOutlet weak var revokeTableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var toRevokeGrantees = Array<Cosmos_Authz_V1beta1_GrantAuthorization>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.revokeTableView.delegate = self
        self.revokeTableView.dataSource = self
        self.revokeTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.revokeTableView.register(UINib(nibName: "AuthzRevokeCell", bundle: nil), forCellReuseIdentifier: "AuthzRevokeCell")
        self.revokeTableView.rowHeight = UITableView.automaticDimension
        self.revokeTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.toRevokeGrantees = pageHolderVC.mGrantees
        
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
        cancelBtn.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
}

extension AuthzRevoke1ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toRevokeGrantees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AuthzRevokeCell") as? AuthzRevokeCell
        cell?.onBindView(toRevokeGrantees[indexPath.row])
        return cell!
    }
}
