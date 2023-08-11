//
//  AuthzGrantListViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AuthzGrantListViewController: BaseViewController {
    
    @IBOutlet weak var AuthzSegment: UISegmentedControl!
    @IBOutlet weak var granteeView: UIView!
    @IBOutlet weak var granterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        granteeView.alpha = 1
        granterView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.AuthzSegment.selectedSegmentTintColor = chainConfig?.chainColor
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            granteeView.alpha = 1
            granterView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            granteeView.alpha = 0
            granterView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_liquid_staking", comment: "");
        self.navigationItem.title = NSLocalizedString("title_liquid_staking", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}

extension WUtils {
    
}
