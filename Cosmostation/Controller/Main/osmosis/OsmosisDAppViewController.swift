//
//  OsmosisDAppViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/10.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class OsmosisDAppViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var swapView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        swapView.alpha = 1
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            swapView.alpha = 1
        } else if sender.selectedSegmentIndex == 1 {
            swapView.alpha = 0
        } else if sender.selectedSegmentIndex == 2 {
            swapView.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_dapp_osmosis", comment: "");
        self.navigationItem.title = NSLocalizedString("title_dapp_osmosis", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

}
