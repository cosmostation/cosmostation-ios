//
//  KavaLiquidity1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class KavaLiquidity1ViewController: BaseViewController {
    
    @IBOutlet weak var amountTextField: AmountInputTextField!
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnAdd01: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btnHalf: UIButton!
    @IBOutlet weak var btnMax: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
    }
    
    
    @IBAction func onClickCancel(_ sender: UIButton) {
    }
    @IBAction func onClickNext(_ sender: UIButton) {
    }
    @IBAction func onClickClear(_ sender: UIButton) {
    }
    @IBAction func onClickAdd01(_ sender: UIButton) {
    }
    @IBAction func onClickAdd1(_ sender: UIButton) {
    }
    @IBAction func onClickAdd10(_ sender: UIButton) {
    }
    @IBAction func onClickAdd100(_ sender: UIButton) {
    }
    @IBAction func onClickHalf(_ sender: UIButton) {
    }
    @IBAction func onClickMax(_ sender: UIButton) {
    }

}
