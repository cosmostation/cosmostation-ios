//
//  MainTabRewardViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class ValidatorListViewController: BaseViewController {
    
    @IBOutlet weak var chainBg: UIImageView!
    @IBOutlet weak var validatorSegment: UISegmentedControl!
    @IBOutlet weak var myValidatorView: UIView!
    @IBOutlet weak var allValidatorView: UIView!
    @IBOutlet weak var otherValidatorView: UIView!
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.myValidatorView.alpha = 1
            self.allValidatorView.alpha = 0
            self.otherValidatorView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            self.myValidatorView.alpha = 0
            self.allValidatorView.alpha = 1
            self.otherValidatorView.alpha = 0
        } else {
            self.myValidatorView.alpha = 0
            self.allValidatorView.alpha = 0
            self.otherValidatorView.alpha = 1
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.myValidatorView.alpha = 1
        self.allValidatorView.alpha = 0
        self.otherValidatorView.alpha = 0
    
        validatorSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        validatorSegment.setTitleTextAttributes([.foregroundColor: UIColor.font04], for: .normal)
        validatorSegment.selectedSegmentTintColor = chainConfig?.chainColor
            
        validatorSegment.setTitle(NSLocalizedString("str_my_validator", comment: ""), forSegmentAt: 0)
        validatorSegment.setTitle(NSLocalizedString("str_all_validator", comment: ""), forSegmentAt: 1)
        validatorSegment.setTitle(NSLocalizedString("str_other_validator", comment: ""), forSegmentAt: 2)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_validator_list", comment: "")
        self.navigationItem.title = NSLocalizedString("title_validator_list", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
