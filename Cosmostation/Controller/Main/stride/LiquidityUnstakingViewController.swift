//
//  LiquidityUnstakingViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class LiquidityUnstakingViewController: UIViewController {
    
    var pageHolderVC: StrideDappViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)\
        self.pageHolderVC = self.parent as? StrideDappViewController

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onStrideFetchDone(_:)), name: Notification.Name("strideFetchDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("strideFetchDone"), object: nil)
    }
    
    @objc func onStrideFetchDone(_ notification: NSNotification) {
        print("LiquidityUnstakingViewController onStrideFetchDone")
    }

}
