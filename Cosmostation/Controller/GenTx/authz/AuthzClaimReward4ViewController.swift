//
//  AuthzClaimReward4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzClaimReward4ViewController: BaseViewController {
    
    @IBOutlet weak var rewardAmoutLaebl: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    
    @IBOutlet weak var fromValidatorLabel: UILabel!
    @IBOutlet weak var recipientTitleLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
    }
    
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
    }
}
