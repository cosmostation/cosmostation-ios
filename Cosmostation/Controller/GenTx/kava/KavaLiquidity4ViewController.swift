//
//  KavaLiquidity4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class KavaLiquidity4ViewController: BaseViewController {
    
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var validatorTitleLabel: UILabel!
    @IBOutlet weak var validatorLabel: UILabel!
    @IBOutlet weak var liquidityTitleLabel: UILabel!
    @IBOutlet weak var liquidityAmountLabel: UILabel!
    @IBOutlet weak var liquidityDenomLabel: UILabel!
    @IBOutlet weak var memoTitleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
    }
    
    @IBAction func onClickBefore(_ sender: UIButton) {
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
    }

}
