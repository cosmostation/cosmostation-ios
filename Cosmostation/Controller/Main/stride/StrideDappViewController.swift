//
//  StrideDappViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class StrideDappViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var stakingView: UIView!
    @IBOutlet weak var unstakingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        stakingView.alpha = 1
        unstakingView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            stakingView.alpha = 1
            unstakingView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            stakingView.alpha = 0
            unstakingView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_liquidity_staking", comment: "");
        self.navigationItem.title = NSLocalizedString("title_liquidity_staking", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

}
