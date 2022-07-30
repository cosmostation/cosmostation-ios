//
//  AuthzClaimReward1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzClaimReward1ViewController: BaseViewController {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var rewardFromLabel: UILabel!
    @IBOutlet weak var rewardToAddressTitle: UILabel!
    @IBOutlet weak var rewardToAddressLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var mDpDecimal: Int16 = 6
    var mFetchCnt = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        WUtils.setDenomTitle(pageHolderVC.chainType!, rewardDenomLabel)
        
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
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
